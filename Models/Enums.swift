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
}

enum FanModes: String, CaseIterable, Identifiable {
    case off = "quiet"
    case auto = "auto"
    case low = "low"
    case medium = "medium"
    case high = "high"

    var id: String { self.rawValue }
}

enum SwingModes: String, CaseIterable, Identifiable {
    case off = "off"
    case both = "both"
    case vertical = "vertical"
    case horizontal = "horizontal"

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
