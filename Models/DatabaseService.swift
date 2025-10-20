//
//  DatabaseService.swift
//  POS
//
//  Created by Kyle Lippard on 9/18/25.
//

import Foundation
import GRDB

class DatabaseService {
    
    // An instance of DatabasePool or DatabaseQueue
    var dbWriter: DatabaseWriter
    
    // An initializer that takes a DatabaseWriter, which allows for dependency injection
    init(_ dbWriter: DatabaseWriter) throws {
        self.dbWriter = dbWriter
        try self.migrator.migrate(dbWriter)
    }
    
    // The Database migrator defines the database schema.
    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
        // This is where all your table migrations are added.
        // The migrator ensures each migration runs only once.
        migrator.registerMigration("createCustomerTable") { db in
            try Customer.createTable(in: db)
        }
        
        return migrator
    }
    
    // A function to open and create the database file
    static func openDatabaseFile() throws -> DatabaseService {
        // Path to the database file in the documents directory
        let databasePath = try FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("db.sqlite")
            .path
        
        // Open the database with a DatabaseQueue for thread-safe access
        let dbQueue = try DatabaseQueue(path: databasePath)
        return try DatabaseService(dbQueue)
    }
    
    // A function to create and open an in-memory database for testing
    static func openInMemoryDatabase() throws -> DatabaseService {
        // Use :memory: to create an in-memory database
        let dbQueue = try DatabaseQueue(path: ":memory:")
        return try DatabaseService(dbQueue)
    }
}
