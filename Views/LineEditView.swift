//
//  LineEditView.swift
//  POS2
//
//  Created by Kyle Lippard on 10/12/25.
//

import SwiftUI
import GRDB

struct LineEditView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var customerAccountViewModel: CustomerAccountViewModel
    
    let originalLine: Line
    
    @State private var name: String
    @State private var imei: String
    @State private var mdn: String
    @State private var plan: String
    @State private var selectedFeatures: Set<String>
    
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var isSaving: Bool = false
    
    // Available features
    let availableFeatures = [
        "100GB Premium Data",
        "50GB Premium Data",
        "4K Streaming",
        "HD Streaming",
        "Mobile Secure Plus",
        "International Roaming",
        "Unlimited Data",
        "High-Speed 5G",
        "GPS Tracking",
        "Shared Data"
    ]
    
    init(line: Line) {
        self.originalLine = line
        _name = State(initialValue: line.name ?? "")
        _imei = State(initialValue: line.imei ?? "")
        _mdn = State(initialValue: line.mdn)
        _plan = State(initialValue: line.plan ?? "")
        _selectedFeatures = State(initialValue: Set(line.features))
    }
    
    var body: some View {
        Form {
            // Loading indicator at the top
            if isSaving {
                Section {
                    HStack {
                        ProgressView()
                        Text("Saving changes...")
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Section(header: Text("Line Information")) {
                TextField("Line Name", text: $name)
                    .textFieldStyle(.plain)
                
                TextField("Mobile Number (MDN)", text: $mdn)
                    .keyboardType(.numberPad)
                    .disabled(true) // MDN should not be changed
                    .foregroundColor(.gray)
            }
            
            Section(header: Text("Device")) {
                TextField("IMEI", text: $imei)
                    .textFieldStyle(.plain)
                
                if !imei.isEmpty && imei.count != 15 {
                    Text("IMEI must be exactly 15 digits")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            Section(header: Text("Plan")) {
                TextField("Plan Name", text: $plan)
                    .textFieldStyle(.plain)
            }
            
            Section(header: Text("Features & Add-ons")) {
                ForEach(availableFeatures, id: \.self) { feature in
                    Toggle(feature, isOn: Binding(
                        get: { selectedFeatures.contains(feature) },
                        set: { isSelected in
                            if isSelected {
                                selectedFeatures.insert(feature)
                            } else {
                                selectedFeatures.remove(feature)
                            }
                        }
                    ))
                }
            }
            
            if showError {
                Section {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
        }
        .navigationTitle("Edit Line")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    Task {
                        await saveLine()
                    }
                }
                .disabled(isSaving)
            }
        }
    }
    
    private func isValidInput() -> Bool {
        // Check required fields
        guard !mdn.isEmpty else { return false }
        
        // Check IMEI format if provided
        if !imei.isEmpty && imei.count != 15 {
            return false
        }
        
        return true
    }
    
    private func saveLine() async {
        await MainActor.run {
            isSaving = true
            showError = false
        }
        
        // Validate IMEI is not in use by another line
        if !imei.isEmpty && imei != originalLine.imei {
            if await isIMEIInUse(imei: imei, excludingMDN: mdn) {
                await MainActor.run {
                    errorMessage = "This IMEI is already in use by another line"
                    showError = true
                    isSaving = false
                }
                return
            }
        }
        
        var updatedLine = originalLine
        updatedLine.name = name.isEmpty ? nil : name
        updatedLine.imei = imei.isEmpty ? nil : imei
        updatedLine.plan = plan.isEmpty ? nil : plan
        updatedLine.features = Array(selectedFeatures)
        
        let lineToSave = updatedLine
        
        // ← Add debug prints here
        print("🔍 Attempting to save line:")
        print("   MDN: \(lineToSave.mdn)")
        print("   IMEI: \(lineToSave.imei ?? "nil")")
        print("   Name: \(lineToSave.name ?? "nil")")
        
        // Save to database using helper method
        do {
            try await DatabaseManager.shared.performWrite { db in
                try lineToSave.update(db)
                print("✅ Database update completed")
            }
            
            print("🔄 Reloading customer account...")
            
            // Reload customer account to refresh the view
            if let customer = await MainActor.run(body: { customerAccountViewModel.currentCustomer }) {
                await customerAccountViewModel.loadCustomerAccount(customer)
                print("✅ Account reloaded")
            }
            
            await MainActor.run {
                isSaving = false
                print("✅ Save complete")
            }
            
        } catch {
            print("❌ Save failed: \(error)")
            await MainActor.run {
                errorMessage = "Failed to save changes: \(error.localizedDescription)"
                showError = true
                isSaving = false
            }
        }
    }
    private func isIMEIInUse(imei: String, excludingMDN: String) async -> Bool {
        do {
            let count = try await DatabaseManager.shared.performRead { db in
                try Int.fetchOne(db, sql: """
                    SELECT COUNT(*) FROM lines 
                    WHERE imei = ? AND mdn != ?
                    """, arguments: [imei, excludingMDN])
            }
            return (count ?? 0) > 0
        } catch {
            print("Error checking IMEI: \(error)")
            return false
        }
    }
}

#Preview {
    let mockLine = Line(
        id: 1,
        account_number: 123456,
        name: "John's iPhone",
        imei: "123456789012345",
        mdn: "3125550001",
        plan: "Unlimited Plus",
        features: ["100GB Premium Data", "4K Streaming"]
    )
    
   NavigationStack {
        LineEditView(line: mockLine)
            .environmentObject(CustomerAccountViewModel())
    }
}
