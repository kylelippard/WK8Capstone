//
//  Device.swift
//  POS2
//
//  Created by Kyle Lippard on 10/7/25.
//
import Foundation
import GRDB

struct Device: Codable, FetchableRecord, PersistableRecord, Identifiable, Hashable {
    var id: Int64?
    var device: String?
    var imei: String
    var iccid: String?
   // var is5G: Bool
    
    static let databaseTableName = "devices"
    
    enum CodingKeys: String, CodingKey {
        case id
        case device
        case imei
        case iccid
        //case is5G = "is_5g"
    }
}

extension Device {
    enum Columns: String, ColumnExpression {
        case id
        case device
        case imei
        case iccid
      //  case is5G = "is_5g"
    }
}
// In Device.swift:
extension Device {
    static let lines = hasMany(Line.self, using: ForeignKey(["device_imei"], to: ["imei"]))
}
