//
//  DeviceShopView.swift
//  POS
//

import SwiftUI

struct DeviceShopView: View {
    @EnvironmentObject var customerAccountViewModel: CustomerAccountViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var devicesForSale: [DeviceForSale] = []
    @State private var filteredDevices: [DeviceForSale] = []
    @State private var searchText = ""
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var selectedDevice: DeviceForSale?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // Completion handler to pass selected device back
    var onDeviceSelected: ((DeviceForSale, String) -> Void)?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
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
                
                // Device list
                if isLoading {
                    Spacer()
                    ProgressView("Loading devices...")
                    Spacer()
                } else if let error = errorMessage {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        Text("Error Loading Devices")
                            .font(.headline)
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        Button("Retry") {
                            Task {
                                await loadDevices()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    Spacer()
                } else if filteredDevices.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No devices found")
                            .font(.headline)
                        Text("Try a different search term")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(filteredDevices) { device in
                            DeviceForSaleRow(device: device)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    Task {
                                        await selectDevice(device)
                                    }
                                }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Device Shop")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .alert("Device Selection", isPresented: $showingAlert) {
                Button("OK") {
                    if selectedDevice != nil {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
        .task {
            await loadDevices()
        }
        .onChange(of: searchText) { _, _ in
            filterDevices()
        }
    }
    
    private func loadDevices() async {
        isLoading = true
        errorMessage = nil
        
        do {
          // devicesForSale = try await DatabaseManager.shared.fetchAllDevicesForSale()
            devicesForSale = try await DatabaseManager.shared.fetchAllDevicesForSaleNoFilter()
            print("📱 Loaded \(devicesForSale.count) devices for sale")
            print("📱 Devices: \(devicesForSale.map { $0.device })")
            filterDevices()
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Error loading devices for sale: \(error)")
        }
        
        isLoading = false
    }
    
    private func filterDevices() {
        if searchText.isEmpty {
            filteredDevices = devicesForSale
        } else {
            filteredDevices = devicesForSale.filter {
                $0.device.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private func selectDevice(_ device: DeviceForSale) async {
        do {
            // Get a random available IMEI (one that's not assigned to any line)
            guard let imei = try await DatabaseManager.shared.getRandomAvailableIMEI() else {
                alertMessage = "No available devices in inventory. All IMEIs are currently assigned to lines."
                showingAlert = true
                return
            }
            
            print("✅ Selected \(device.device) with IMEI: \(imei)")
            
            selectedDevice = device
            alertMessage = "Device \(device.device) selected with IMEI: \(imei)"
            
            // Call completion handler if provided
            onDeviceSelected?(device, imei)
            
            showingAlert = true
            
        } catch {
            alertMessage = "Error selecting device: \(error.localizedDescription)"
            showingAlert = true
            print("❌ Error selecting device: \(error)")
        }
    }
}

// MARK: - Device Row View
struct DeviceForSaleRow: View {
    let device: DeviceForSale
    
    var body: some View {
        HStack(spacing: 12) {
            // Device image or icon
            if let imageUrl = device.imageUrl {
                Image(imageUrl)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .cornerRadius(8)
            } else {
                Image(systemName: getDeviceIcon(for: device.device))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.blue)
                    .padding(8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }
            
            // Device info
            VStack(alignment: .leading, spacing: 4) {
                Text(device.device)
                    .font(.headline)
                
                Text("$\(device.price, specifier: "%.2f")")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding(.vertical, 8)
    }
    
    private func getDeviceIcon(for deviceName: String) -> String {
        let name = deviceName.lowercased()
        
        if name.contains("iphone") { return "apps.iphone" }
        if name.contains("ipad") { return "ipad" }
        if name.contains("watch") { return "applewatch" }
        if name.contains("samsung") || name.contains("galaxy") || name.contains("pixel") { return "smartphone" }
        if name.contains("airpods") { return "airpodspro" }
        
        return "apps.iphone"
    }
}

#Preview {
    DeviceShopView()
        .environmentObject(DummyData.createMockViewModel())
}
