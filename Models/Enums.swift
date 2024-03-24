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
    
    var entityId: String {
        switch self {
        case .chambre:
            return "climate.halcyon_chambre"
        case .tvRoom:
            return "climate.halcyon_tvRoom"
        case .cuisine:
            return "climate.halcyon_cuisine"
        case .salon:
            return "climate.halcyon_salon"
        case .amis:
            return "climate.halcyon_amis"
        }
    }
}

enum Setting: String, CaseIterable {
    case fan = "Fan"
    case power = "Powerful"
    case eco = "Eco"
    case swing = "Swing"
    case set = "Set"
    
//    var entityId: String {
//        switch self {
//        case .fan:
//            return "climate.set_fan_mode"
//        case .tvRoom:
//            return "climate.halcyon_tvRoom"
//        case .cuisine:
//            return "climate.halcyon_cuisine"
//        case .salon:
//            return "climate.halcyon_salon"
//        case .amis:
//            return "climate.halcyon_amis"
//        }
//    }
}

enum FanMode: String, CaseIterable, Identifiable {
    case off = "quiet"
    case auto = "auto"
    case low = "low"
    case medium = "medium"
    case high = "high"

    var id: String { self.rawValue }
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

