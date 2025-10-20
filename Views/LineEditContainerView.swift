//
//  LineEditContainerView.swift
//  POS2
//
//  Created by Kyle Lippard on [Date]
//

import SwiftUI

struct LineEditContainerView: View {
    @EnvironmentObject var customerAccountViewModel: CustomerAccountViewModel
    @Environment(\.dismiss) var dismiss
    
    let selectedLine: Line
    @State private var currentEditingLine: Line
    
    init(line: Line) {
        self.selectedLine = line
        _currentEditingLine = State(initialValue: line)
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Left Panel - Lines List (30%)
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text(customerAccountViewModel.currentCustomer?.name ?? "Customer")
                                .font(.headline)
                            Text("Account Lines")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemGroupedBackground))
                    
                    Divider()
                    
                    // Lines List
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(customerAccountViewModel.currentLines, id: \.mdn) { line in
                                LineEditSidebarRow(
                                    line: line,
                                    isSelected: line.mdn == currentEditingLine.mdn
                                ) {
                                    currentEditingLine = line
                                }
                            }
                        }
                        .padding()
                    }
                }
                .frame(width: geometry.size.width * 0.3)
                .background(Color(.systemBackground))
                
                Divider()
                
                // Right Panel - Edit Form (70%)
                LineEditView(line: currentEditingLine)
                    .id(currentEditingLine.mdn)  // Use MDN as ID
                    .environmentObject(customerAccountViewModel)
                    .frame(width: geometry.size.width * 0.7)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Edit Line")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}

// Sidebar row component
struct LineEditSidebarRow: View {
    let line: Line
    let isSelected: Bool
    let action: () -> Void
    
    @State private var device: Device?
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Device icon
                Image(systemName: getDeviceIcon(for: device?.device))
                    .font(.title2)
                    .foregroundColor(isSelected ? .blue : .gray)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(line.name ?? "Line \(formattedMDN)")
                        .font(.subheadline)
                        .fontWeight(isSelected ? .semibold : .regular)
                        .foregroundColor(isSelected ? .blue : .primary)
                    
                    Text(device?.device ?? "Unknown Device")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(formattedMDN)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .task {
            await loadDevice()
        }
    }
    
    private var formattedMDN: String {
        let cleanMDN = line.mdn.filter(\.isNumber)
        guard cleanMDN.count >= 10 else { return line.mdn }
        
        var mdnWseparator = ""
        for (index, char) in cleanMDN.enumerated() {
            if index == 3 || index == 6 {
                mdnWseparator.append(".")
            }
            mdnWseparator.append(char)
        }
        return mdnWseparator
    }
    
    private func loadDevice() async {
        guard let imei = line.imei, !imei.isEmpty else { return }
        
        do {
            let foundDevice = try await DatabaseManager.shared.performRead { db in
                try Device.fetchOne(db, sql: "SELECT * FROM devices WHERE imei = ?", arguments: [imei])
            }
            device = foundDevice
        } catch {
            print("Error loading device: \(error)")
        }
    }
    
    private func getDeviceIcon(for deviceName: String?) -> String {
        guard let device = deviceName?.lowercased() else { return "iphone" }
        
        if device.contains("iphone") { return "iphone" }
        if device.contains("ipad") { return "ipad" }
        if device.contains("watch") { return "applewatch" }
        if device.contains("samsung") || device.contains("galaxy") { return "smartphone" }
        if device.contains("router") || device.contains("internet") { return "wifi.router" }
        
        return "iphone"
    }
}

#Preview {
    NavigationStack {
        LineEditContainerView(line: DummyData.mockLines[0])
            .environmentObject(DummyData.createMockViewModel())
    }
}
