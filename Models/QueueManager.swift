//
//  QueueManager.swift
//  POS2
//
//  Created by Kyle Lippard on 10/7/25.
//
import Foundation
import Combine

class QueueManager: ObservableObject {
    static let shared = QueueManager()
    
    @Published var queueItems: [QueueItem] = []
    
    private init() {
        // Set up notification observer
        setupNotificationObserver()
    }
    
    @MainActor  // ← Add this
    func addToQueue(customer: Customer, reason: String) {
        let item = QueueItem(
            customer: customer,
            reason: reason,
            addedTime: Date()
        )
        queueItems.append(item)
    }
    
    @MainActor  // ← Add this too
    func removeFromQueue(item: QueueItem) {
        queueItems.removeAll { $0.id == item.id }
    }
    
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            forName: .customerAddedToQueue,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let data = notification.object as? [String: String],
               let mdn = data["mdn"],
               let reason = data["reason"] {
                Task { @MainActor in
                    // Look up customer using database directly
                    do {
                        if let customer = try await DatabaseManager.shared.performRead({ db in
                            try Customer.fetchOne(db, sql: """
                                SELECT DISTINCT c.* 
                                FROM customers c
                                JOIN lines l ON c.account_number = l.account_number
                                WHERE l.mdn = ?
                                """, arguments: [mdn])
                        }) {
                            self?.addToQueue(customer: customer, reason: reason)
                        }
                    } catch {
                        print("Error looking up customer for queue: \(error)")
                    }
                }
            }
        }
    }
}

struct QueueItem: Identifiable, Equatable {
    let id = UUID()
    let customer: Customer
    let reason: String
    let addedTime: Date
    
    var waitTime: String {
        let minutes = Int(Date().timeIntervalSince(addedTime) / 60)
        return "\(minutes) mins"
    }
    
    // Equatable conformance
    static func == (lhs: QueueItem, rhs: QueueItem) -> Bool {
        lhs.id == rhs.id
    }
}
