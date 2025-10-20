//
//  LineGroupView.swift
//  POS2
//
//  Created by Kyle Lippard on 10/19/25.
//
import SwiftUI

struct LineGroupView: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(value)
                    .font(.subheadline)
            }
            
            Spacer()
        }
    }
}

#Preview {
    LineEditContainerView(line: DummyData.mockLines[0])
        .environmentObject(DummyData.createMockViewModel())
}
