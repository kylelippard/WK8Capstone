//
//  DeviceDisplayCardView.swift
//  POS2
//
//  Created by Kyle Lippard on 10/19/25.
//

import SwiftUI

// MARK: - Device Display Card
struct DeviceDisplayCard: View {
    let device: Device
    
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
                
                Text("IMEI: \(device.imei)")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                if let iccid = device.iccid {
                    Text("ICCID: \(iccid)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(10)
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

// MARK: - Empty Device Card
struct EmptyDeviceCard: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "plus.circle")
                    .font(.title2)
                    .foregroundColor(.gray)
                
                Text("Select a device")
                    .foregroundColor(.gray)
                
                Spacer()
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [5]))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Plan Display Card
struct PlanDisplayCard: View {
    let planName: String
    
    private var planComponents: (name: String, price: String) {
        let parts = planName.components(separatedBy: " - ")
        return (parts.first ?? planName, parts.last ?? "")
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "antenna.radiowaves.left.and.right")
                .font(.system(size: 32))
                .foregroundColor(.purple)
                .frame(width: 50, height: 50)
                .background(Color.purple.opacity(0.1))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(planComponents.name)
                    .font(.headline)
                
                Text(planComponents.price)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(10)
    }
}

// MARK: - Feature Display Card
struct FeatureDisplayCard: View {
    let featureName: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            
            Text(featureName)
                .font(.subheadline)
            
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(8)
    }
}

// MARK: - Empty Features Card
struct EmptyFeaturesCard: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "plus.circle")
                    .font(.title3)
                    .foregroundColor(.gray)
                
                Text("Add features")
                    .foregroundColor(.gray)
                
                Spacer()
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [5]))
            )
        }
        .buttonStyle(.plain)
    }
}
