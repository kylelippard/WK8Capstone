//
//  QueueView.swift
//  POS
//
//  Created by Kyle Lippard on 9/3/25.
//

import SwiftUI

struct QueueView: View {
    @ObservedObject var queueManager = QueueManager.shared
    @State private var selectedQueueItem: QueueItem?
    
    var body: some View {
        VStack(alignment: .leading) {
            if queueManager.queueItems.isEmpty {
                ContentUnavailableView(
                    "No Customers in Queue",
                    systemImage: "person.3",
                    description: Text("Add customers from Check In")
                )
            } else {
                Table(queueManager.queueItems) {
                    TableColumn("Name") { item in
                        VStack(alignment: .leading) {
                            Text(item.customer.name)
                            Text(item.reason)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    TableColumn("Account #") { item in
                        if let accountNum = item.customer.account_number {
                            Text("\(String(accountNum))")
                        }
                    }
                    TableColumn("Wait Time") { item in
                        Text(item.waitTime)
                    }
                    TableColumn("Action") { item in
                        Button("Select") {
                            selectedQueueItem = item
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
        }
        .navigationTitle("Queue")
        .onChange(of: selectedQueueItem) { _, newValue in
            if newValue != nil {
                // Notify MainTabView to show options
                NotificationCenter.default.post(
                    name: .queueItemSelected,
                    object: newValue
                )
            }
        }
    }
}


#Preview {
    let mockQueueManager = QueueManager.shared
   // mockQueueManager.queueItems.removeAll()
    
//    mockQueueManager.queueItems = [
//        QueueItem(
//            customer: DummyData.mockQueueCustomers[0],
//            reason: "Upgrade",
//            addedTime: Date().addingTimeInterval(-600)
//        ),
//        QueueItem(
//            customer: DummyData.mockQueueCustomers[1],
//            reason: "New Line",
//            addedTime: Date().addingTimeInterval(-300)
//        ),
//        QueueItem(
//            customer: DummyData.mockQueueCustomers[2],
//            reason: "Technical Support",
//            addedTime: Date().addingTimeInterval(-120)
//        )
//    ]
    
    QueueView()
        .environmentObject(DummyData.createMockViewModel())
}
