//
//  LineView.swift
//  POS
//
//  Created by Kyle Lippard on 9/27/25.
//

import SwiftUI
import UIKit

struct LineView: View {
    @EnvironmentObject var customerAccountViewModel: CustomerAccountViewModel
    @Environment(\.dismiss) private var dismiss
    
    let line: Line
    
    @State private var isExpanded: Bool = false
    @State private var device: Device?
    @State private var isLoadingDevice: Bool = false
    @State private var showEditDevice = false
    @State private var showManageLines = false
    var onEditTapped: (() -> Void)?
    var onManageTapped: (() -> Void)?
    
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: 10) {
                Divider()
                
                LineGroupView(label: "IMEI", value: line.imei ?? "n/a", icon: "ellipsis.rectangle")
                LineGroupView(label: "ICCID", value: device?.iccid ?? "n/a", icon: "ellipsis.rectangle.fill")
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Features & Add-ons:")
                        .font(.caption.bold())
                        .foregroundColor(.gray)
                    
                    if line.features.isEmpty {
                        Text("No features added")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .italic()
                    } else {
                        ForEach(line.features, id: \.self) { feature in
                            Label(feature, systemImage: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                }
                .padding(.top, 5)
                
                // Buttons section moved here
                Divider()
                    .padding(.top, 10)
                
                HStack(spacing: 20) {
                    Button {
                        showEditDevice = true
                    } label: {
                        Label("Edit Device & Plan", systemImage: "pencil.circle.fill")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        showManageLines = true
                    } label: {
                        Label("Manage Account Lines", systemImage: "phone.connection")
                            .font(.subheadline)
                            .foregroundColor(.green)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 10)
            }
            .padding(.vertical, 5)
            .animation(.easeInOut(duration: 0.2), value: isExpanded)
            
        } label: {
            HStack {
                Image(systemName: getDeviceIcon(for: device?.device))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.blue)
                    .padding(.trailing, 8)
                
                VStack(alignment: .leading) {
                    Text(line.name ?? "Line \(line.mdn)")
                        .font(.headline)
                    Text(device?.device ?? "Unknown Device")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if let plan = line.plan {
                    Text(plan)
                        .font(.caption)
                        .lineLimit(2)
                        .frame(maxWidth: 100)
                }
                
                Spacer()
                
                var formattedMDN: String {
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
                Text(formattedMDN)
                    .font(.subheadline)
                
                if let plan = line.plan {
                    Text(plan.contains("Pro") ? "PRO" : "STD")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(plan.contains("Pro") ? .white : .secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(plan.contains("Pro") ? Color.orange : Color.secondary.opacity(0.1)))
                }
            }
        }
        .listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
        .task(id: line.imei) {
            await loadDevice()
        }
        .navigationDestination(isPresented: $showEditDevice) {
            LineEditContainerView(line: line)
                .environmentObject(customerAccountViewModel)
        }
        .navigationDestination(isPresented: $showManageLines) {
            LinesManagementContainerView(initialLine: nil)
        }
    }
    
    private func loadDevice() async {
        guard let imei = line.imei else {
            print("⚠️ No IMEI for line: \(line.mdn)")
            return
        }
        
        isLoadingDevice = true
        
        do {
            let foundDevice = try await DatabaseManager.shared.dbWriter.read { db in
                try Device.fetchOne(db, sql: """
                                SELECT * FROM devices 
                                WHERE imei = ?
                                """, arguments: [imei])
            }
            
            device = foundDevice
            
            if let foundDevice = foundDevice {
                print("✅ Found device: \(foundDevice.device ?? "No name") for line \(line.mdn)")
            } else {
                print("❌ No device found with IMEI: \(imei) for line \(line.mdn)")
            }
        } catch {
            print("❌ Error loading device for line \(line.mdn): \(error)")
        }
        
        isLoadingDevice = false
    }
    
    private func getDeviceIcon(for deviceName: String?) -> String {
        guard let device = deviceName?.lowercased() else { return "apps.iphone" }
        
        if device.contains("iphone") { return "apps.iphone" }
        if device.contains("ipad") { return "ipad" }
        if device.contains("watch") { return "applewatch" }
        if device.contains("samsung") || device.contains("galaxy") { return "smartphone" }
        if device.contains("router") || device.contains("internet") { return "wifi.router" }
        
        return "apps.iphone"
    }
}

#Preview {
    LineView(line: DummyData.mockLines[0])
        .environmentObject(DummyData.createMockViewModel())
}
