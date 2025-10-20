//
//  DeviceCardView.swift
//  POS2
//
//  Created by Kyle Lippard on 10/19/25.
//

import SwiftUI

struct DeviceCard: View {
    let device: Device
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: getDeviceIcon(for: device.device))
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
                    .frame(height: 80)
                
                VStack(spacing: 4) {
                    Text(device.device ?? "Unknown")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    Text(device.imei.prefix(8) + "...")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func getDeviceIcon(for deviceName: String?) -> String {
        guard let device = deviceName?.lowercased() else { return "iphone" }
        if device.contains("iphone") { return "iphone" }
        if device.contains("ipad") { return "ipad" }
        if device.contains("watch") { return "applewatch" }
        if device.contains("samsung") || device.contains("galaxy") { return "smartphone" }
        if device.contains("pixel") { return "smartphone" }
        return "iphone"
    }
}

#Preview {
    DevicePickerView(
        selectedDevice: .constant(nil),
        availableDevices: [
            Device(id: 1, device: "iPhone 15 Pro", imei: "123456789012345", iccid: "1234"),
            Device(id: 2, device: "iPhone 15", imei: "234567890123456", iccid: "2345"),
            Device(id: 3, device: "Samsung Galaxy S24", imei: "345678901234567", iccid: "3456"),
            Device(id: 4, device: "Google Pixel 8", imei: "456789012345678", iccid: "4567")
        ]
    )
}
