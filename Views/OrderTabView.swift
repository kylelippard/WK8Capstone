//
//  OrderTabView.swift
//  POS2
//
//  Created by Kyle Lippard on 10/19/25.
//

import SwiftUI

struct OrderTabView: View {
    @EnvironmentObject var customerAccountViewModel: CustomerAccountViewModel
    
    @State private var selectedDevice: Device?
    @State private var orderItems: [OrderItem] = []
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Left Panel - Device Shop (70%)
                DeviceShopContentView(selectedDevice: $selectedDevice)
                    .frame(width: geometry.size.width * 0.7)
                
                Divider()
                
                // Right Panel - Order Cart (30%)
                OrderCartView(selectedDevice: $selectedDevice, orderItems: $orderItems)
                    .frame(width: geometry.size.width * 0.3)
            }
        }
    }
}

// Device Shop without NavigationView wrapper
struct DeviceShopContentView: View {
    @Binding var selectedDevice: Device?
    
    @State private var availableDevices: [Device] = []
    @State private var searchText: String = ""
    @State private var isLoading: Bool = true
    
    var filteredDevices: [Device] {
        if searchText.isEmpty {
            return availableDevices
        }
        return availableDevices.filter { device in
            device.device?.localizedCaseInsensitiveContains(searchText) ?? false ||
            device.imei.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var groupedDevices: [String: [Device]] {
        Dictionary(grouping: filteredDevices) { device in
            if let name = device.device?.lowercased() {
                if name.contains("iphone") { return "Apple iPhone" }
                if name.contains("ipad") { return "Apple iPad" }
                if name.contains("watch") { return "Apple Watch" }
                if name.contains("samsung") || name.contains("galaxy") { return "Samsung" }
                if name.contains("google") || name.contains("pixel") { return "Google Pixel" }
            }
            return "Other"
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Shop Devices")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            
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
            
            if isLoading {
                ProgressView("Loading devices...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
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
        }
        .task {
            await loadDevices()
        }
    }
    
    private func loadDevices() async {
        isLoading = true
        
        do {
            availableDevices = try await DatabaseManager.shared.performRead { db in
                try Device.fetchAll(db, sql: "SELECT * FROM devices ORDER BY name")
            }
        } catch {
            print("Error loading devices: \(error)")
        }
        
        isLoading = false
    }
}

// Order Cart Panel
struct OrderCartView: View {
    @Binding var selectedDevice: Device?
    @Binding var orderItems: [OrderItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Order")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            
            Divider()
            
            if let device = selectedDevice {
                ScrollView {
                    VStack(spacing: 16) {
                        // Selected Device
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Selected Device")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            HStack(spacing: 12) {
                                Image(systemName: getDeviceIcon(for: device.device))
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(device.device ?? "Unknown")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    Text(device.imei.prefix(8) + "...")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Button {
                                    selectedDevice = nil
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(10)
                        }
                        
                        Spacer()
                        
                        // Add to Order Button
                        Button {
                            addToOrder()
                        } label: {
                            Text("Add to Order")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                }
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "cart")
                        .font(.system(size: 60))
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Text("Select a device to begin")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    private func addToOrder() {
        // Add order logic here
        print("Add device to order")
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

struct OrderItem: Identifiable {
    let id = UUID()
    let device: Device
    var quantity: Int = 1
}

#Preview {
    OrderTabView()
        .environmentObject(CustomerAccountViewModel())
}
