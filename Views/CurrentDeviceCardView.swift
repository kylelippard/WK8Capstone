//
//  CurrentDeviceCardView.swift
//  POS2
//
//  Created by Kyle Lippard on 10/19/25.
//

import SwiftUI


struct CurrentDeviceCard: View {
    let imei: String
    @State private var device: Device?
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: getDeviceIcon(for: device?.device))
                .font(.system(size: 40))
                .foregroundColor(.gray)
                .frame(width: 60, height: 60)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(device?.device ?? "Loading...")
                    .font(.headline)
                
                Text("IMEI: \(imei)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(10)
        .task {
            await loadDevice()
        }
    }
    
    private func loadDevice() async {
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
        return "iphone"
    }
}

struct SelectedDeviceCard: View {
    let device: Device
    let onChangeTap: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: getDeviceIcon(for: device.device))
                .font(.system(size: 40))
                .foregroundColor(.blue)
                .frame(width: 60, height: 60)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(device.device ?? "Unknown Device")
                    .font(.headline)
                
                if let iccid = device.iccid {
                    Text("ICCID: \(iccid)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Button("Change") {
                onChangeTap()
            }
            .font(.subheadline)
            .foregroundColor(.blue)
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.blue, lineWidth: 2)
        )
    }
    
    private func getDeviceIcon(for deviceName: String?) -> String {
        guard let device = deviceName?.lowercased() else { return "iphone" }
        if device.contains("iphone") { return "iphone" }
        if device.contains("ipad") { return "ipad" }
        if device.contains("watch") { return "applewatch" }
        if device.contains("samsung") || device.contains("galaxy") { return "smartphone" }
        return "iphone"
    }
}


#Preview {
    CurrentDeviceCard(imei: "350000000000001")
}
