//
//  CustomerAccountViewModel.swift
//  POS
//
//  Created by Kyle Lippard on 9/18/25.
//
import SwiftUI
import GRDB

@MainActor
class CustomerAccountViewModel: ObservableObject {
    @Published var currentCustomer: Customer?
    @Published var currentLines: [Line] = []
    @Published var isAccountFound: Bool = false
    @Published var isLoading: Bool = false
    
    // Method 1: Look up customer name only (async)
    func lookupCustomerName(by name: String) async -> String? {
        do {
            return try await DatabaseManager.shared.dbWriter.read { db in
                try String.fetchOne(db, sql: """
                    SELECT c.name 
                    FROM customers c
                    JOIN lines l ON c.account_number = l.account_number
                    WHERE l.mdn = ?
                    LIMIT 1
                    """, arguments: [name])
            }
        } catch {
            print("Error looking up customer name: \(error)")
            return nil
        }
    }
    
    // Method 2: Look up full customer object (async)
    func lookupCustomer(by mdn: String) async -> Customer? {
        do {
            return try await DatabaseManager.shared.dbWriter.read { db in
                try Customer.fetchOne(db, sql: """
                    SELECT DISTINCT c.* 
                    FROM customers c
                    JOIN lines l ON c.account_number = l.account_number
                    WHERE l.mdn = ?
                    """, arguments: [mdn])
            }
        } catch {
            print("Error looking up customer: \(error)")
            return nil
        }
    }
    
    // Method 3: Find customer and load account (async)
    func findCustomer(by mdn: String) {
        Task { @MainActor in
            isLoading = true
            isAccountFound = false  // Added this line to reset before searching
            
            do {
                let customer = try await DatabaseManager.shared.dbWriter.read { db in
                    try Customer.fetchOne(db, sql: """
                        SELECT DISTINCT c.* 
                        FROM customers c
                        JOIN lines l ON c.account_number = l.account_number
                        WHERE l.mdn = ?
                        """, arguments: [mdn])
                }
                
                if let customer = customer {
                    print("✅ Found customer: \(customer.name)")
                    await loadCustomerAccount(customer)
                } else {
                    print("❌ No customer found with MDN: \(mdn)")
                    isAccountFound = false
                }
            } catch {
                print("❌ Error finding customer: \(error)")
                isAccountFound = false
            }
            
            isLoading = false
        }
    }
    
    // Method 4: Load full customer account with lines (async)
    @MainActor
    func loadCustomerAccount(_ customer: Customer) async {
        do {
            let lines = try await DatabaseManager.shared.dbWriter.read { db in
                try Line.fetchAll(db, sql: """
                    SELECT * FROM lines 
                    WHERE account_number = ?
                    """, arguments: [customer.account_number])
            }
            
            print("✅ Loaded \(lines.count) lines for account \(customer.account_number ?? 0)")
            
            self.currentCustomer = customer
            self.currentLines = lines
            self.isAccountFound = true
        } catch {
            print("Error loading customer account: \(error)")
            self.isAccountFound = false
        }
    }
}
