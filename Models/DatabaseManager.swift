//
//  DatabaseManager.swift
//  POS
//
//  Created by Kyle Lippard on 9/15/25.
//

import Foundation
import GRDB

actor DatabaseManager {
    
    // The single, shared instance of the DatabaseManager
    static let shared = DatabaseManager()
    
    // The database writer
    var dbWriter: DatabaseQueue!
    
    private var isInitialized = false
    
    // Empty private init - no heavy work here
    private init() {
        print("⏱️ DatabaseManager: Instance created (not yet initialized)")
    }
    
    // Async initialization method
    func initialize() async throws {
        // Actor ensures thread-safe access automatically
        guard !isInitialized else {
            print("⏱️ DatabaseManager: Already initialized, skipping")
            return
        }
        
        let initStart = CFAbsoluteTimeGetCurrent()
        print("⏱️ DatabaseManager: Starting initialization...")
        
        let fileManager = FileManager.default
        
        let dbPath = try fileManager
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("posdatabase.sqlite")
            .path
        
        // Copy database from bundle if it doesn't exist
        if !fileManager.fileExists(atPath: dbPath) {
            guard let dbResourcePath = Bundle.main.path(forResource: "posdatabase", ofType: "sqlite") else {
                throw DatabaseError.bundleDatabaseMissing
            }
            
            try fileManager.copyItem(atPath: dbResourcePath, toPath: dbPath)
            print("✅ Database copied from bundle")
        } else {
            print("ℹ️ Database already exists, using existing file")
        }
        
        // Initialize dbWriter
        let queue = try DatabaseQueue(path: dbPath)
        self.dbWriter = queue
        print("✅ Database opened at: \(dbPath)")
        
        // Check database size
        if let attrs = try? fileManager.attributesOfItem(atPath: dbPath),
           let fileSize = attrs[.size] as? Int64 {
            let sizeMB = Double(fileSize) / 1024.0 / 1024.0
            print("📊 Database size: \(String(format: "%.2f", sizeMB))MB")
        }
        
        // Create devices_for_sale table if it doesn't exist
        try await createDevicesForSaleTable(queue)
        
        // Verify database structure
        try await verifyDatabaseStructure(queue)
        
        let initDiff = CFAbsoluteTimeGetCurrent() - initStart
        print("⏱️ Total DatabaseManager init: \(String(format: "%.3f", initDiff))s")
        
        // Mark as initialized
        isInitialized = true
    }
    
    // Create devices_for_sale table if it doesn't exist
    private func createDevicesForSaleTable(_ queue: DatabaseQueue) async throws {
        try await queue.write { db in
            try db.create(table: "devices_for_sale", ifNotExists: true) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("device", .text).notNull()
                t.column("price", .double).notNull().defaults(to: 0.0)
                t.column("imageUrl", .text)
                t.column("is_available", .boolean).notNull().defaults(to: true)
            }
            
            // Check if table is empty and seed data
            let count = try DeviceForSale.fetchCount(db)
            if count == 0 {
                try seedDevicesForSale(db)
            }
        }
        print("✅ devices_for_sale table ready")
    }
    
    // Seed sample devices for sale
    private nonisolated func seedDevicesForSale(_ db: Database) throws {
        let sampleDevices = [
            DeviceForSale(device: "iPhone 17", price: 899.99, imageUrl: "iPhone 17", isAvailable: true),
            DeviceForSale(device: "iPhone 17 Pro Max", price: 1199.99, imageUrl: "iPhone 17 Pro Max", isAvailable: true),
            DeviceForSale(device: "iPhone Air", price: 799.99, imageUrl: "iPhone Air", isAvailable: true),
            DeviceForSale(device: "Samsung Galaxy Z Fold 7", price: 1799.99, imageUrl: "Samsung Galaxy Z Fold 7", isAvailable: true),
            DeviceForSale(device: "Samsung Galaxy Z Flip 7", price: 999.99, imageUrl: "Samsung Galaxy Z Flip 7", isAvailable: true)
        ]
        
        for device in sampleDevices {
            try device.insert(db)
        }
        
        print("✅ Seeded \(sampleDevices.count) devices for sale")
    }
    
    // Verify that required tables and indexes exist
    private func verifyDatabaseStructure(_ queue: DatabaseQueue) async throws {
        try await queue.read { db in
            // Get all tables
            let tables = try String.fetchAll(db, sql: """
                SELECT name FROM sqlite_master 
                WHERE type='table' AND name NOT LIKE 'sqlite_%'
                ORDER BY name
                """)
            print("📊 Tables in database: \(tables)")
            
            // Verify required tables exist
            let requiredTables = ["customers", "devices", "lines", "devices_for_sale"]
            for table in requiredTables {
                guard tables.contains(table) else {
                    throw DatabaseError.missingTable(table)
                }
            }
            
            // Get all indexes
            let indexes = try String.fetchAll(db, sql: """
                SELECT name FROM sqlite_master 
                WHERE type='index' AND name NOT LIKE 'sqlite_%'
                ORDER BY name
                """)
            print("📊 Indexes in database: \(indexes)")
            
            // Verify recommended indexes exist
            let recommendedIndexes = [
                "idx_lines_mdn",
                "idx_lines_account",
                "idx_customers_account",
                "idx_devices_imei"
            ]
            
            let missingIndexes = recommendedIndexes.filter { !indexes.contains($0) }
            if !missingIndexes.isEmpty {
                print("⚠️ Warning: Missing recommended indexes: \(missingIndexes)")
                print("   Performance may be degraded. Consider adding these indexes to your bundle database.")
            }
            
            // Get row counts
            let customerCount = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM customers") ?? 0
            let lineCount = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM lines") ?? 0
            let deviceCount = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM devices") ?? 0
            let devicesForSaleCount = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM devices_for_sale") ?? 0
            
            print("📊 Row counts - Customers: \(customerCount), Lines: \(lineCount), Devices: \(deviceCount), Devices for Sale: \(devicesForSaleCount)")
            
            // Warn if database is empty
            if customerCount == 0 && lineCount == 0 {
                print("⚠️ Warning: Database contains no data")
            }
        }
    }
    
    // Provide access to the database
    func getDatabase() throws -> DatabaseQueue {
        guard isInitialized, let db = dbWriter else {
            throw DatabaseError.notInitialized
        }
        return db
    }
}

// MARK: - Helper Methods
extension DatabaseManager {
    nonisolated func performWrite(_ block: @escaping @Sendable (Database) throws -> Void) async throws {
        guard let writer = await dbWriter else {
            throw DatabaseError.notInitialized
        }
        try await writer.write(block)
    }
    
    nonisolated func performRead<T>(_ block: @escaping @Sendable (Database) throws -> T) async throws -> T {
        guard let writer = await dbWriter else {
            throw DatabaseError.notInitialized
        }
        return try await writer.read(block)
    }
}
extension DatabaseManager {
    nonisolated func fetchAllDevicesForSaleNoFilter() async throws -> [DeviceForSale] {
        try await performRead { db in
            try DeviceForSale
                .order(DeviceForSale.Columns.device)
                .fetchAll(db)
        }
    }
}

// MARK: - DeviceForSale Operations
extension DatabaseManager {
    nonisolated func fetchAllDevicesForSale() async throws -> [DeviceForSale] {
        try await performRead { db in
            try DeviceForSale
                .filter(DeviceForSale.Columns.isAvailable == true)
                .order(DeviceForSale.Columns.device)
                .fetchAll(db)
        }
    }
    
    nonisolated func searchDevicesForSale(query: String) async throws -> [DeviceForSale] {
        try await performRead { db in
            try DeviceForSale
                .filter(DeviceForSale.Columns.device.like("%\(query)%"))
                .filter(DeviceForSale.Columns.isAvailable == true)
                .order(DeviceForSale.Columns.device)
                .fetchAll(db)
        }
    }
    
    nonisolated func insertDeviceForSale(_ device: DeviceForSale) async throws {
        try await performWrite { db in
            try device.insert(db)
        }
    }
    
    nonisolated func updateDeviceForSale(_ device: DeviceForSale) async throws {
        try await performWrite { db in
            try device.update(db)
        }
    }
    
    nonisolated func deleteDeviceForSale(_ device: DeviceForSale) async throws {
        try await performWrite { db in
            try device.delete(db)
        }
    }
    
    nonisolated func fetchDeviceForSale(by id: Int64) async throws -> DeviceForSale? {
        try await performRead { db in
            try DeviceForSale.fetchOne(db, key: id)
        }
    }
}

// MARK: - Device IMEI Operations
extension DatabaseManager {
    nonisolated func fetchAvailableIMEIs() async throws -> [String] {
        try await performRead { db in
            // Get all IMEIs from devices table
            let allIMEIs = try String.fetchAll(db, sql: "SELECT imei FROM devices")
            
            // Get IMEIs that are already assigned to lines
            let assignedIMEIs = try String.fetchAll(db, sql: "SELECT imei FROM lines WHERE imei IS NOT NULL")
            
            // Return IMEIs that are not assigned
            return allIMEIs.filter { !assignedIMEIs.contains($0) }
        }
    }
    
    nonisolated func getRandomAvailableIMEI() async throws -> String? {
        let availableIMEIs = try await fetchAvailableIMEIs()
        return availableIMEIs.randomElement()
    }
    
    // Check if an IMEI is available (not assigned to any line)
    nonisolated func isIMEIAvailable(_ imei: String) async throws -> Bool {
        try await performRead { db in
            let count = try Int.fetchOne(db, sql: """
                SELECT COUNT(*) FROM lines WHERE imei = ?
                """, arguments: [imei]) ?? 0
            return count == 0
        }
    }
}

// MARK: - Error Types
enum DatabaseError: Error {
    case notInitialized
    case bundleDatabaseMissing
    case missingTable(String)
    
    var localizedDescription: String {
        switch self {
        case .notInitialized:
            return "Database not initialized. Call initialize() first."
        case .bundleDatabaseMissing:
            return "Required database file 'posdatabase.sqlite' is missing from app bundle."
        case .missingTable(let table):
            return "Required table '\(table)' is missing from database. The bundle database may be corrupted."
        }
    }
}
