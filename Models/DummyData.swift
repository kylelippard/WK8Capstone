//
//  DummyData.swift
//  POS
//
//  Created by Kyle Lippard on 9/28/25.
//

import Foundation

struct DummyData {
    
    // MARK: - Mock Customer
    static let mockCustomer = Customer(
        name: "Acme Corporation"
      //  account_number: 12345
    )
    
    // MARK: - Mock Devices
    static let mockDevices = [
        Device(
            device: "iPhone 15 Pro Max",
            imei: "356938035643809",
            iccid: "8901260851234567890"
           // is5G: true
        ),
        Device(
            device: "iPad Pro",
            imei: "490154203237518",
            iccid: "8901410391234567890"
          //  is5G: true
        ),
        Device(
            device: "Verizon 5G Router",
            imei: "352099001761481",
            iccid: "8944501234567890123"
          //  is5G: true
        ),
        Device(
            device: "Samsung S24 Ultra",
            imei: "358240051111110",
            iccid: "8901240112345678901"
          //  is5G: true
        ),
        Device(
            device: "Apple Watch Ultra",
            imei: "490154203237526",
            iccid: "8901410892345678901"
         //   is5G: false
        )
    ]
    
    // MARK: - Mock Lines (only store IMEI reference)
    static var mockLines: [Line] {
        var line1 = Line(
            account_number: 12345,
            name: "Alice Johnson",
            imei: "356938035643809",  // Reference to iPhone device
            mdn: "5551234567",
            plan: "Business Unlimited Pro 5G",
            features: ["100GB Premium Data", "4K Streaming", "Mobile Secure Plus"]
        )
        
        var line2 = Line(
            account_number: 12345,
            name: "Bob Williams",
            imei: "490154203237518",  // Reference to iPad device
            mdn: "5559876543",
            plan: "Tablet Unlimited",
            features: ["50GB Premium Data", "HD Streaming"]
        )
        
        var line3 = Line(
            account_number: 12345,
            name: "Charlie Brown",
            imei: "352099001761481",  // Reference to Router device
            mdn: "5555551234",
            plan: "Home Internet Pro",
            features: ["Unlimited Data", "High-Speed 5G"]
        )
       
        var line4 = Line(
            account_number: 12345,
            name: "Diana Garcia",
            imei: "358240051111110",  // Reference to Samsung device
            mdn: "5552223333",
            plan: "Unlimited Plus",
            features: ["50GB Premium Data", "International Roaming"]
        )
        
        var line5 = Line(
            account_number: 12345,
            name: "Ethan Davis",
            imei: "490154203237526",  // Reference to Apple Watch device
            mdn: "5558889999",
            plan: "Watch Connected",
            features: ["Shared Data", "GPS Tracking"]
        )
        
        return [line1, line2, line3, line4, line5]
    }
    
    // MARK: - Mock ViewModel Setup
    @MainActor static func createMockViewModel() -> CustomerAccountViewModel {
        let viewModel = CustomerAccountViewModel()
        viewModel.currentCustomer = mockCustomer
        viewModel.currentLines = mockLines
        viewModel.isAccountFound = true
        return viewModel
    }
    
    // MARK: - Additional Mock Data (for QueueView, etc.)
    static let mockQueueCustomers = [
        Customer(name: "Tech Solutions Inc"),
        Customer(name: "Global Industries"),
        Customer(name: "Local Business LLC")
    ]
}
