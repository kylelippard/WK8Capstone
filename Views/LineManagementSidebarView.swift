//
//  LineManagementSidebarView.swift
//  POS2
//
//  Created by Kyle Lippard on 10/19/25.
//

import SwiftUI

struct LinesManagementSidebarView: View {
    @EnvironmentObject var customerAccountViewModel: CustomerAccountViewModel
    
    @Binding var selectedLine: Line?
    @Binding var isAddingNewLine: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with Account Number
            VStack(alignment: .leading, spacing: 4) {
                Text(customerAccountViewModel.currentCustomer?.name ?? "Customer")
                    .font(.headline)
                
                if let accountNumber = customerAccountViewModel.currentCustomer?.account_number {
                    Text("Account #\(accountNumber)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGroupedBackground))
            
            Divider()
            
            // Add Line Button
            Button {
                selectedLine = nil
                isAddingNewLine = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.green)
                    Text("Add Line")
                        .fontWeight(.medium)
                    Spacer()
                }
                .padding()
                .background(isAddingNewLine ? Color.green.opacity(0.1) : Color(.secondarySystemGroupedBackground))
                .cornerRadius(10)
            }
            .buttonStyle(.plain)
            .padding()
            
            // Lines List
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(Array(customerAccountViewModel.currentLines.enumerated()), id: \.element.mdn) { index, line in
                        LineItemRow(
                            lineNumber: index + 1,
                            line: line,
                            isSelected: selectedLine?.mdn == line.mdn && !isAddingNewLine
                        ) {
                            selectedLine = line
                            isAddingNewLine = false
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
    }
}

struct LineItemRow: View {
    let lineNumber: Int
    let line: Line
    let isSelected: Bool
    let action: () -> Void
    
    @State private var device: Device?
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Line number badge
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 32, height: 32)
                    
                    Text("\(lineNumber)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(isSelected ? .white : .gray)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(line.name ?? "Line \(lineNumber)")
                        .font(.subheadline)
                        .fontWeight(isSelected ? .semibold : .regular)
                        .foregroundColor(isSelected ? .blue : .primary)
                    
                    Text(formattedMDN)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    if let deviceName = device?.device {
                        Text(deviceName)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color(.tertiarySystemGroupedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
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
        
        var result = ""
        for (index, char) in cleanMDN.enumerated() {
            if index == 3 || index == 6 {
                result.append(".")
            }
            result.append(char)
        }
        return result
    }
    
    private func loadDevice() async {
        guard let imei = line.imei, !imei.isEmpty else { return }
        
        do {
            device = try await DatabaseManager.shared.performRead { db in
                try Device.fetchOne(db, sql: "SELECT * FROM devices WHERE imei = ?", arguments: [imei])
            }
        } catch {
            print("Error loading device: \(error)")
        }
    }
}

#Preview {
    LinesManagementSidebarView(
        selectedLine: .constant(nil),
        isAddingNewLine: .constant(false)
    )
    .environmentObject(DummyData.createMockViewModel())
    .frame(width: 300)
}
