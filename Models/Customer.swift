//
//  CustomersTable.swift
//  POS
//
//  Created by Kyle Lippard on 9/18/25.
//

import Foundation
import GRDB

// Make the Customer struct conform to Codable for easy mapping
struct Customer: Codable, FetchableRecord, PersistableRecord, Identifiable, Hashable {
   
    var id: Int64? { account_number.map { Int64($0) } }
    var account_number: Int? // Primary Key
    var name: String
    var email: String?
    var device: String?
    var mdn: Int?
    
    // Define table name
    static let databaseTableName = "customers"
    // Implement the primary key, so GRDB knows what to update and delete
    static let primaryKey: Column = Column("account_number")
    
    // An array to hold the associated lines (not stored in the DB directly)
    var lines: [Line]?
    // A Customer has many Lines
   // static let lines = hasMany(Line.self)
    // Equatable conformance (if not auto-generated)
    static func == (lhs: Customer, rhs: Customer) -> Bool {
        lhs.id == rhs.id && lhs.account_number == rhs.account_number
    }
    // Custom hash (optional - only if you need custom logic)
     func hash(into hasher: inout Hasher) {
         hasher.combine(account_number)
     }
    
    // Define the table mapping
    enum Columns {
        static let account_number = Column(CodingKeys.account_number)
        static let name = Column(CodingKeys.name)
        static let email = Column(CodingKeys.email)
        static let device = Column(CodingKeys.device)
        static let mdn = Column(CodingKeys.mdn)
    }
    
    // You can add an initializer to help with creating new customers
    init(name: String, email: String? = nil, device: String? = nil, mdn: Int? = nil) {
        self.name = name
        self.email = email
        self.device = device
        self.mdn = mdn
        self.account_number = nil // Let the database handle the primary key generation
    }
    
    // A copy method can be useful for modifying records while keeping the original intact
    func with(accountNumber: Int) -> Customer {
        var copy = self
        copy.account_number = accountNumber
        return copy
    }
    
    // This method is required by PersistableRecord to handle optional primary keys
    mutating func didInsert(with rowID: Int64, for column: String?) {
        account_number = Int(rowID)
    }
}

extension Customer {
    // You can define a migration to create the table
    static func createTable(in db: Database) throws {
        try db.create(table: "customers", ifNotExists: true) { t in
            t.column("account_number", .integer).primaryKey()
            t.column("name", .text).notNull()
            t.column("email", .text)
            t.column("device", .text)
            t.column("mdn", .integer)
        }
    }
}

extension Customer {
    // Define relationship: Customer has many Lines
    static let lines = hasMany(Line.self, using: ForeignKey(["account_number"]))
}


