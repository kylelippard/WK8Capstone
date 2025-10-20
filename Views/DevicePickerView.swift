//
//  DevicePickerView.swift
//  POS2
//
//  Created by Kyle Lippard on 10/17/25.
//


import SwiftUI

struct DevicePickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedDevice: Device?
    let availableDevices: [Device]
    
    @State private var searchText = ""
    
    var filteredDevices: [Device] {
        if searchText.isEmpty {
            return availableDevices
        } else {
            return availableDevices.filter { device in
                device.device?.localizedCaseInsensitiveContains(searchText) ?? false ||
                device.imei.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // Group devices by manufacturer
    var groupedDevices: [String: [Device]] {
        Dictionary(grouping: filteredDevices) { device in
            if let device = device.device?.lowercased() {
                if device.contains("iphone") { return "Apple iPhone" }
                if device.contains("ipad") { return "Apple iPad" }
                if device.contains("watch") { return "Apple Watch" }
                if device.contains("samsung") || device.contains("galaxy") { return "Samsung" }
                if device.contains("google") || device.contains("pixel") { return "Google Pixel" }
            }
            return "Other"
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search devices...", text: $searchText)
                        .textFieldStyle(.plain)
                    
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding()
                
                // Device Grid
                ScrollView {
                    LazyVStack(spacing: 20, pinnedViews: [.sectionHeaders]) {
                        ForEach(groupedDevices.keys.sorted(), id: \.self) { manufacturer in
                            Section {
                                LazyVGrid(columns: [
                                    GridItem(.adaptive(minimum: 150), spacing: 16)
                                ], spacing: 16) {
                                    ForEach(groupedDevices[manufacturer] ?? [], id: \.imei) { device in
                                        DeviceCard(device: device) {
                                            selectedDevice = device
                                            dismiss()
                                        }
                                    }
                                }
                            } header: {
                                HStack {
                                    Text(manufacturer)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .background(Color(.systemBackground))
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Select Device")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
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
