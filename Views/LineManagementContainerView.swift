//
//  LineManagementContainerView.swift
//  POS2
//
//  Created by Kyle Lippard on 10/19/25.

import SwiftUI

struct LinesManagementContainerView: View {
    @EnvironmentObject var customerAccountViewModel: CustomerAccountViewModel
    @Environment(\.dismiss) var dismiss
    
    let initialLine: Line?  // ← Add this parameter
    
    @State private var selectedLine: Line?
    @State private var isAddingNewLine: Bool = false
    
    init(initialLine: Line? = nil) {  // ← Add initializer
        self.initialLine = initialLine
        _selectedLine = State(initialValue: initialLine)
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Left Panel - 30%
                LinesManagementSidebarView(
                    selectedLine: $selectedLine,
                    isAddingNewLine: $isAddingNewLine
                )
                .frame(width: geometry.size.width * 0.3)
                .background(Color(.systemBackground))
                
                Divider()
                
                // Right Panel - 70%
                LinesManagementMainView(
                    selectedLine: $selectedLine,
                    isAddingNewLine: $isAddingNewLine
                )
                .frame(width: geometry.size.width * 0.7)
            }
        }
        .navigationTitle("Manage Lines")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        LinesManagementContainerView()
            .environmentObject(DummyData.createMockViewModel())
    }
}
