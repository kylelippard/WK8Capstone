//
//  Line.swift
//  POS
//
//  Created by Kyle Lippard on 9/12/25.
//

import Foundation
import GRDB

struct Line: Codable, Identifiable {
    var id: Int64?
    var account_number: Int?
    var name: String?
    var imei: String?  // Foreign key to devices table
    var mdn: String
    var plan: String?
    var features: [String]
    
    enum CodingKeys: String, CodingKey {
        case id
        case account_number
        case name
        case imei
        case mdn
        case plan
        case features
    }
}

// MARK: - GRDB Persistence
extension Line: FetchableRecord, MutablePersistableRecord {
    // Define the database table name
    static let databaseTableName = "lines"
    
    // GRDB will automatically use CodingKeys for column mapping
    
    // update() method
    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}

// MARK: - Custom Decodable for features array
extension Line {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decodeIfPresent(Int64.self, forKey: .id)
        account_number = try container.decodeIfPresent(Int.self, forKey: .account_number)
        mdn = try container.decode(String.self, forKey: .mdn)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        imei = try container.decodeIfPresent(String.self, forKey: .imei)
        plan = try container.decodeIfPresent(String.self, forKey: .plan)
        
        // Decode features - might be stored as JSON string in database
        if let featuresString = try container.decodeIfPresent(String.self, forKey: .features) {
            // Try to parse as JSON array
            if let data = featuresString.data(using: .utf8),
               let array = try? JSONDecoder().decode([String].self, from: data) {
                features = array
            } else {
                // Fallback: split by comma or treat as single item
                features = featuresString.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
            }
        } else {
            features = []
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(account_number, forKey: .account_number)
        try container.encode(mdn, forKey: .mdn)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(imei, forKey: .imei)
        try container.encodeIfPresent(plan, forKey: .plan)
        
        // Encode features as JSON string
        if !features.isEmpty {
            let jsonData = try JSONEncoder().encode(features)
            let jsonString = String(data: jsonData, encoding: .utf8)
            try container.encode(jsonString, forKey: .features)
        } else {
            try container.encode("[]", forKey: .features)
        }
    }
}
