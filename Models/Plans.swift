//
//  Plans.swift
//  POS
//
//  Created by Kyle Lippard on 9/27/25.
//

import Foundation
import Combine
import SwiftUI

// MARK: Tiered Plan Model

// Defines a mobile plan with explicit tiered pricing based on the number of lines (1, 2, 3, or 4+).
struct Plan: Identifiable, Hashable {
    let id: String // Corresponds to the first column (e.g., "0123")
    let plan: String // Corresponds to the plan name (e.g., "Unlimited Ultimate")
    let l1: Double   // 1 line price
    let l2: Double   // 2 line price
    let l3: Double   // 3 line price
    let l4: Double   // 4+ lines price
    
    // Helper function to get the correct price based on the number of lines.
    func price(for lineCount: Int) -> Double {
        switch lineCount {
        case 1:
            return l1
        case 2:
            return l2
        case 3:
            return l3
        default: // Covers 4 and above
            return l4
        }
    }
}

// Provides mock Plan data loaded from the CSV.
final class PlansViewModel: ObservableObject {
    @Published var availablePlans: [Plan] = [
        Plan(id: "0123", plan: "Unlimited Ultimate", l1: 100.0, l2: 90.0, l3: 75.0, l4: 65.0),
        Plan(id: "4567", plan: "Unlimited Plus", l1: 90.0, l2: 80.0, l3: 65.0, l4: 55.0),
        Plan(id: "8901", plan: "Unlimited Welcome", l1: 75.0, l2: 65.0, l3: 50.0, l4: 40.0)
    ]
    
    // Placeholder to demonstrate using the price function
    func getPriceExample() {
        if let ultimatePlan = availablePlans.first(where: { $0.plan == "Unlimited Ultimate" }) {
            print("Ultimate Plan (1 line): $\(ultimatePlan.price(for: 1))") // Prints $100.0
            print("Ultimate Plan (5 lines): $\(ultimatePlan.price(for: 5))") // Prints $65.0
        }
    }
}
