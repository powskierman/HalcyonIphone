//
//  Enums.swift
//  Halcyon 2.0 Watch App
//
//  Created by Michel Lapointe on 2024-02-13.
//

import Foundation

enum entityType {
    case room(Room)
}

enum Room: String, CaseIterable {
    case chambre = "Chambre"
    case tvRoom = "TV Room"
    case cuisine = "Cuisine"
    case salon = "Salon"
    case amis = "Amis"
    
    public var entityId: String {
        "climate.halcyon_\(self.rawValue.lowercased())"
    }
}

enum HvacModes: String, CaseIterable {
    case off, heat, cool, dry, fan_only

    var next: HvacModes {
        let allModes = HvacModes.allCases
        let currentIndex = allModes.firstIndex(of: self) ?? 0
        let nextIndex = (currentIndex + 1) % allModes.count
        return allModes[nextIndex]
    }

    var systemImageName: String {
        switch self {
        case .off: return "power"
        case .heat: return "thermometer.sun"
        case .cool: return "thermometer.snowflake"
        case .dry: return "drop.fill"
        case .fan_only: return "wind"
        }
    }
}

enum fanSpeed {
    case auto
    case low
    case medium
    case high
    case quiet
}

// Enum to represent the status of a REST API call
enum CallStatus {
    case success
    case failure
    case pending
}

public enum ParameterValue: Encodable {
    case string(String)
    case integer(Int)
    case double(Double) // Add this line if it's missing

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let stringValue):
            try container.encode(stringValue)
        case .integer(let intValue):
            try container.encode(intValue)
        case .double(let doubleValue): // Handle encoding for the double case
            try container.encode(doubleValue)
        }
    }
}
