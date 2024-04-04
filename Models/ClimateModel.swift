//
//  ClimateModel.swift
//  HalcyonIphone
//
//  Created by Michel Lapointe on 2024-04-03.
//

import Foundation
import HassFramework

struct ClimateModel {
    let climateEntity: HAEntity
    
    var entityId: String {
        climateEntity.entityId
    }
    
    var state: String {
        climateEntity.state
    }
    
    var hvacModes: [String] {
        climateEntity.attributes.additionalAttributes["hvac_modes"] as? [String] ?? []
    }
    
    var minTemp: Double {
        climateEntity.attributes.additionalAttributes["min_temp"] as? Double ?? 0
    }
    
    var maxTemp: Double {
        climateEntity.attributes.additionalAttributes["max_temp"] as? Double ?? 0
    }
    
    var targetTempStep: Double {
        climateEntity.attributes.additionalAttributes["target_temp_step"] as? Double ?? 0
    }
    
    var fanModes: [String] {
        climateEntity.attributes.additionalAttributes["fan_modes"] as? [String] ?? []
    }
    
    var swingModes: [String] {
        climateEntity.attributes.additionalAttributes["swing_modes"] as? [String] ?? []
    }
    
    var currentTemperature: Double {
        climateEntity.attributes.additionalAttributes["current_temperature"] as? Double ?? 0
    }
    
    var temperature: Double {
        if let temp = climateEntity.attributes.additionalAttributes["temperature"] as? Double {
            print("Temperature (Double) for \(climateEntity.entityId): \(temp)")
            return temp
        } else if let tempInt = climateEntity.attributes.additionalAttributes["temperature"] as? Int {
            print("Temperature (Int) for \(climateEntity.entityId): \(tempInt)")
            return Double(tempInt)
        } else if let tempStr = climateEntity.attributes.additionalAttributes["temperature"] as? String, let temp = Double(tempStr) {
            print("Temperature (String) for \(climateEntity.entityId): \(temp)")
            return temp
        } else {
            print("Temperature attribute not found or not a valid number. Defaulting to 30.")
            return 30
        }
    }
    
    var hvacMode: HvacModes {
        HvacModes(rawValue: state) ?? .off
    }
    
    // Corrected the fanMode to properly fetch the "fan_mode" attribute
    var fanMode: FanModes {
        let fanModeString = climateEntity.attributes.additionalAttributes["fan_mode"] as? String ?? "auto"
        return FanModes(rawValue: fanModeString) ?? .auto
    }
    
    var swingMode: String {
        climateEntity.attributes.additionalAttributes["swing_mode"] as? String ?? "off"
    }
    
    var friendlyName: String {
        climateEntity.attributes.friendlyName ?? "Unnamed"
    }
}
