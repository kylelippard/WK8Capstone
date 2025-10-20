//
//  KeyPadButton.swift
//  POS
//
//  Created by Kyle Lippard on 9/21/25.
//
import SwiftUI

struct KeyPad: View {
    @Binding var string: String
    
    // Change the layout - replace "-" with "CLR"
    private let layout = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["CLEAR", "0", "⌫"]  // ← Changed "-" to "CLR"
    ]
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(layout, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(row, id: \.self) { key in
                        KeyPadButton(key: key) {
                            handleKeyPress(key)
                        }
                    }
                }
            }
        }
        .padding()
    }
    
    private func handleKeyPress(_ key: String) {
        if key == "⌫" {
            handleDelete()
        } else if key == "CLEAR" {
            handleClear()
        } else {
            handleInput(key)
        }
    }
    
    private func handleInput(_ key: String) {
        // Reset placeholder
        if string == "Enter MDN" {
            string = ""
        }
        
        // Don't allow more than 10 digits
        let digitCount = string.filter(\.isNumber).count
        if digitCount >= 10 { return }
        
        // Add the key
        string += key
        
        // Auto-format with dots
        let digits = string.filter(\.isNumber)
        if digits.count == 3 || digits.count == 6 {
            string += "."
        }
    }
    
    private func handleDelete() {
        if string.isEmpty || string == "Enter MDN" { return }
        
        string.removeLast()
        
        // Remove trailing dot if present
        if string.hasSuffix(".") {
            string.removeLast()
        }
        
        // Reset to placeholder if empty
        if string.isEmpty {
            string = "Enter MDN"
        }
    }
    
    private func handleClear() {
        string = "Enter MDN"
    }
}

struct KeyPadButton: View {
    let key: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(key)
                .font(key == "CLEAR" ? .headline : .title2)  // ← Slightly smaller font for CLR
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .background(key == "CLEAR" ? Color.red.opacity(0.2) : Color.gray.opacity(0.2))  // ← Red background for clear
                .foregroundColor(key == "CLEAR" ? .red : .primary)  // ← Red text for clear
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let mockReason = MenuItem(name: "Upgrade", icon: "arrow.up")
    NavigationView {
        CheckInView(selectedReason: mockReason)
            .environmentObject(CustomerAccountViewModel())
    }
}
