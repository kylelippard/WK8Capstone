//
//  FeatureShopView.swift
//  POS2
//
//  Created by Kyle Lippard on 10/19/25.
//

import SwiftUI

struct FeatureShopView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedFeatures: Set<String>
    
    let availableFeatures = [
        ("100GB Premium Data", "$10/mo", "100GB of premium high-speed data"),
        ("50GB Premium Data", "$5/mo", "50GB of premium high-speed data"),
        ("4K Streaming", "$15/mo", "Ultra HD video streaming quality"),
        ("HD Streaming", "$7/mo", "High definition video streaming"),
        ("Mobile Secure Plus", "$12/mo", "Advanced security & identity protection"),
        ("International Roaming", "$10/day", "Use your plan internationally"),
        ("Unlimited Data", "$30/mo", "Truly unlimited high-speed data"),
        ("High-Speed 5G", "$20/mo", "Access to 5G Ultra Wideband"),
        ("GPS Tracking", "$5/mo", "Track your device location"),
        ("Mobile Hotspot", "$10/mo", "Share your data as WiFi hotspot")
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                List {
                    ForEach(availableFeatures, id: \.0) { feature in
                        FeatureShopRow(
                            featureName: feature.0,
                            price: feature.1,
                            description: feature.2,
                            isSelected: selectedFeatures.contains(feature.0)
                        ) {
                            toggleFeature(feature.0)
                        }
                    }
                }
                .listStyle(.insetGrouped)
                
                // Bottom bar with Done button
                VStack(spacing: 0) {
                    Divider()
                    
                    HStack {
                        Text("\(selectedFeatures.count) features selected")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Button("Done") {
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }
                .background(Color(.systemBackground))
            }
            .navigationTitle("Shop Features")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !selectedFeatures.isEmpty {
                        Button("Clear All") {
                            selectedFeatures.removeAll()
                        }
                        .foregroundColor(.red)
                    }
                }
            }
        }
    }
    
    private func toggleFeature(_ feature: String) {
        if selectedFeatures.contains(feature) {
            selectedFeatures.remove(feature)
        } else {
            selectedFeatures.insert(feature)
        }
    }
}

struct FeatureShopRow: View {
    let featureName: String
    let price: String
    let description: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? .green : .gray)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(featureName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Text(price)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    FeatureShopView(selectedFeatures: .constant(["100GB Premium Data", "HD Streaming"]))
}
