//
//  DeviceForSale.swift
//  POS
//
//  Created by Kyle Lippard on 10/19/25.
//
import Foundation
import GRDB

struct DeviceForSale: Codable, FetchableRecord, PersistableRecord, Identifiable {
    var id: Int64?
    var device: String
    var price: Double
    var imageUrl: String?
    var isAvailable: Bool
    
    static let databaseTableName = "devices_for_sale"
    
    // Map Swift property names to database column names
    enum CodingKeys: String, CodingKey {
        case id
        case device
        case price
        case imageUrl
        case isAvailable = "is_available"  // Map to database column name
    }
    
    // Define columns for type-safe queries
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let device = Column(CodingKeys.device)
        static let price = Column(CodingKeys.price)
        static let imageUrl = Column(CodingKeys.imageUrl)
        static let isAvailable = Column(CodingKeys.isAvailable)
    }
}
