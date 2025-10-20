//
//  ReasonForVisitView.swift
//  POS
//
//  Created by Kyle Lippard on 9/3/25.
//

import SwiftUI

struct CheckInRowView: View {
    let rowItem: MenuItem
    
    var body: some View {
        Button {
            // Notify MainTabView to show CheckInView for this reason
            NotificationCenter.default.post(
                name: .reasonSelected,
                object: rowItem
            )
        } label: {
            HStack {
                Image(systemName: rowItem.icon)
                Text(rowItem.name)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
    }
}

struct MenuGroupView: View {
    let group: MenuItem
    @State private var isExpanded: Bool = false
    
    var body: some View {
        DisclosureGroup(
            isExpanded: $isExpanded,
            content: {
                ForEach(group.items ?? []) { row in
                    CheckInRowView(rowItem: row)
                }
            },
            label: {
                HStack {
                    Image(systemName: group.icon)
                    Text(group.name)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }
            }
        )
    }
}

struct ReasonForVisitView: View {
    @StateObject private var viewModel = MenuViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.menuItems) { group in
                MenuGroupView(group: group)
            }
        }
    }
}

#Preview {
    ReasonForVisitView()
}
