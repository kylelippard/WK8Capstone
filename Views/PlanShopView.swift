//
//  PlanShopView.swift
//  POS2
//
//  Created by Kyle Lippard on 10/19/25.
//

import SwiftUI

struct PlanShopView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedPlan: String
    
    let availablePlans = [
        ("Unlimited Welcome", "$65/mo", "Basic unlimited with SD streaming"),
        ("Unlimited Plus", "$80/mo", "Premium unlimited with HD streaming"),
        ("Unlimited Ultimate", "$90/mo", "Top-tier with 4K streaming & hotspot"),
        ("5GB Plan", "$35/mo", "5GB high-speed data"),
        ("15GB Plan", "$50/mo", "15GB high-speed data"),
        ("Unlimited Premium", "$100/mo", "Everything unlimited + international")
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(availablePlans, id: \.0) { plan in
                    PlanShopRow(
                        planName: plan.0,
                        price: plan.1,
                        description: plan.2,
                        isSelected: selectedPlan.contains(plan.0)
                    ) {
                        selectedPlan = "\(plan.0) - \(plan.1)"
                        dismiss()
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Shop Plans")
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

struct PlanShopRow: View {
    let planName: String
    let price: String
    let description: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(planName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(price)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.purple)
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.purple)
                    }
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PlanShopView(selectedPlan: .constant("Unlimited Plus - $80/mo"))
}
