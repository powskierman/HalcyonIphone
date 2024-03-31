//
//  HalcyonExtensions.swift
//  HalcyonIphone
//
//  Created by Michel Lapointe on 2024-03-30.
//

import Foundation
import HassFramework

extension HAEntity {
    var currentTemperature: Double? {
        return attributes.additionalAttributes["current_temperature"] as? Double
    }

    var temperature: Double? {
        return attributes.additionalAttributes["temperature"] as? Double
    }

    var fanMode: String? {
        return attributes.additionalAttributes["fan_mode"] as? String
    }

    var swingMode: String? {
        return attributes.additionalAttributes["swing_mode"] as? String
    }
}

extension HAAttributes {
    var temperature: Double? {
        get {
            return self.additionalAttributes["temperature"] as? Double
        }
    }
    
    var currentTemperature: Double? {
        get {
            return self.additionalAttributes["current_temperature"] as? Double
        }
    }

    var fanMode: String? {
        get {
            return self.additionalAttributes["fan_mode"] as? String
        }
    }

    var swingMode: String? {
        get {
            return self.additionalAttributes["swing_mode"] as? String
        }
    }
}
