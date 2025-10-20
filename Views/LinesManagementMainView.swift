//
//  OrderView.swift
//  POS2
//
//  Created by Kyle Lippard on 10/5/25.
//

import SwiftUI

struct LinesManagementMainView: View {
        @EnvironmentObject var customerAccountViewModel: CustomerAccountViewModel
        
        @Binding var selectedLine: Line?
        @Binding var isAddingNewLine: Bool
        
        @State private var mdn: String = ""
        @State private var lineName: String = ""
        @State private var selectedDevice: Device?
        @State private var selectedPlan: String = "Unlimited Plus - $80/mo"
        @State private var selectedFeatures: Set<String> = []
        
        @State private var showDeviceShop: Bool = false
        @State private var showPlanShop: Bool = false
        @State private var showFeatureShop: Bool = false
        
        @State private var isSaving: Bool = false
        @State private var showError: Bool = false
        @State private var errorMessage: String = ""
        
        var body: some View {
            VStack(spacing: 0) {
                if isAddingNewLine {
                    addNewLineContent
                } else if let line = selectedLine {
                    modifyLineContent(line: line)
                } else {
                    emptyStateContent
                }
            }
        }
        
        // MARK: - Add New Line Content
        private var addNewLineContent: some View {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 24) {
                        // New Line Info Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("New Line Information")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            VStack(spacing: 16) {
                                TextField("Phone Number (10 digits)", text: $mdn)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(.plain)
                                    .padding()
                                    .background(Color(.secondarySystemGroupedBackground))
                                    .cornerRadius(8)
                                
                                TextField("Line Name (Optional)", text: $lineName)
                                    .textFieldStyle(.plain)
                                    .padding()
                                    .background(Color(.secondarySystemGroupedBackground))
                                    .cornerRadius(8)
                            }
                        }
                        .padding()
                        .background(Color(.systemGroupedBackground))
                        .cornerRadius(12)
                        
                        deviceSection
                        planSection
                        featuresSection
                        
                        if showError {
                            errorView
                        }
                    }
                    .padding()
                }
                
                orderReviewButton(action: addNewLine, isEnabled: isAddFormValid)
            }
        }
        
        // MARK: - Modify Line Content
        private func modifyLineContent(line: Line) -> some View {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 24) {
                        deviceSection
                        planSection
                        featuresSection
                        
                        if showError {
                            errorView
                        }
                    }
                    .padding()
                }
                
                orderReviewButton(action: updateLine, isEnabled: selectedDevice != nil)
            }
            .onAppear {
                loadLineData(line: line)
            }
        }
        
        // MARK: - Device Section
        private var deviceSection: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Device")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button {
                        showDeviceShop = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "cart")
                            Text("Shop Devices")
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    }
                }
                
                if let device = selectedDevice {
                    DeviceDisplayCard(device: device)
                } else {
                    EmptyDeviceCard {
                        showDeviceShop = true
                    }
                }
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            .cornerRadius(12)
            .sheet(isPresented: $showDeviceShop) {
                DeviceShopView()
            }
        }
        
        // MARK: - Plan Section
        private var planSection: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Plan")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button {
                        showPlanShop = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "cart")
                            Text("Shop Plans")
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    }
                }
                
                PlanDisplayCard(planName: selectedPlan)
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            .cornerRadius(12)
            .sheet(isPresented: $showPlanShop) {
                PlanShopView(selectedPlan: $selectedPlan)
            }
        }
        
        // MARK: - Features Section
        private var featuresSection: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Features")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button {
                        showFeatureShop = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "cart")
                            Text("Shop Features")
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    }
                }
                
                if selectedFeatures.isEmpty {
                    EmptyFeaturesCard {
                        showFeatureShop = true
                    }
                } else {
                    VStack(spacing: 8) {
                        ForEach(Array(selectedFeatures).sorted(), id: \.self) { feature in
                            FeatureDisplayCard(featureName: feature)
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            .cornerRadius(12)
            .sheet(isPresented: $showFeatureShop) {
                FeatureShopView(selectedFeatures: $selectedFeatures)
            }
        }
        
        // MARK: - Empty State
        private var emptyStateContent: some View {
            VStack(spacing: 20) {
                Image(systemName: "phone.connection")
                    .font(.system(size: 80))
                    .foregroundColor(.gray.opacity(0.5))
                
                Text("Select a line or add a new one")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        
        // MARK: - Error View
        private var errorView: some View {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.subheadline)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.red.opacity(0.1))
            .cornerRadius(8)
        }
        
        // MARK: - Order Review Button
        private func orderReviewButton(action: @escaping () -> Void, isEnabled: Bool) -> some View {
            VStack(spacing: 0) {
                Divider()
                
                Button {
                    action()
                } label: {
                    HStack {
                        if isSaving {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                        Text(isSaving ? "Processing..." : "Review Order")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isEnabled ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(!isEnabled || isSaving)
                .padding()
            }
            .background(Color(.systemBackground))
        }
        
        // MARK: - Helper Properties
        private var isAddFormValid: Bool {
            let cleanMDN = mdn.filter(\.isNumber)
            return cleanMDN.count == 10 && selectedDevice != nil
        }
        
        // MARK: - Helper Functions
        private func loadLineData(line: Line) {
            selectedPlan = line.plan ?? "Unlimited Plus - $80/mo"
            selectedFeatures = Set(line.features)
            
            if let imei = line.imei {
                Task {
                    do {
                        selectedDevice = try await DatabaseManager.shared.performRead { db in
                            try Device.fetchOne(db, sql: "SELECT * FROM devices WHERE imei = ?", arguments: [imei])
                        }
                    } catch {
                        print("Error loading device: \(error)")
                    }
                }
            }
        }
        
        private func addNewLine() {
            guard let customer = customerAccountViewModel.currentCustomer else { return }
            let cleanMDN = mdn.filter(\.isNumber)
            
            isSaving = true
            showError = false
            
            Task {
                do {
                    // Check for duplicate MDN
                    let exists = try await DatabaseManager.shared.performRead { db in
                        try Line.fetchOne(db, sql: "SELECT * FROM lines WHERE mdn = ?", arguments: [cleanMDN])
                    }
                    
                    if exists != nil {
                        await MainActor.run {
                            errorMessage = "A line with this number already exists"
                            showError = true
                            isSaving = false
                        }
                        return
                    }
                    
                    // Create new line
                    let newLine = Line(
                        id: nil,
                        account_number: customer.account_number,
                        name: lineName.isEmpty ? nil : lineName,
                        imei: selectedDevice?.imei,
                        mdn: cleanMDN,
                        plan: selectedPlan,
                        features: Array(selectedFeatures)
                    )
                    
                    try await DatabaseManager.shared.performWrite { db in
                        var line = newLine
                        try line.insert(db)
                    }
                    
                    await customerAccountViewModel.loadCustomerAccount(customer)
                    
                    await MainActor.run {
                        isSaving = false
                        isAddingNewLine = false
                        resetForm()
                    }
                } catch {
                    await MainActor.run {
                        errorMessage = "Failed to add line: \(error.localizedDescription)"
                        showError = true
                        isSaving = false
                    }
                }
            }
        }
        
        private func updateLine() {
            guard let line = selectedLine,
                  let customer = customerAccountViewModel.currentCustomer else { return }
            
            isSaving = true
            showError = false
            
            Task {
                do {
                    var updatedLine = line
                    updatedLine.imei = selectedDevice?.imei
                    updatedLine.plan = selectedPlan
                    updatedLine.features = Array(selectedFeatures)
                    
                    try await DatabaseManager.shared.performWrite { db in
                        try updatedLine.update(db)
                    }
                    
                    await customerAccountViewModel.loadCustomerAccount(customer)
                    
                    await MainActor.run {
                        isSaving = false
                    }
                } catch {
                    await MainActor.run {
                        errorMessage = "Failed to update line: \(error.localizedDescription)"
                        showError = true
                        isSaving = false
                    }
                }
            }
        }
        
        private func resetForm() {
            mdn = ""
            lineName = ""
            selectedDevice = nil
            selectedPlan = "Unlimited Plus - $80/mo"
            selectedFeatures = []
        }
    }

    #Preview {
        LinesManagementMainView(
            selectedLine: .constant(DummyData.mockLines[0]),
            isAddingNewLine: .constant(false)
        )
        .environmentObject(DummyData.createMockViewModel())
    }
