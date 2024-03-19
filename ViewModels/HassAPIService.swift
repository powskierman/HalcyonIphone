//
//  HassClientService.swift
//  Halcyon 2.0 Watch App
//
//  Created by Michel Lapointe on 2024-02-15.
//

import Foundation
import HassFramework

class HassAPIService: ObservableObject {
    static let shared = HassAPIService()
    private var restClient: HassRestClient

    init() {
        self.restClient = HassRestClient.shared
    }

    func sendCommand(entityId: String, hvacMode: HvacModes, temperature: Int, completion: @escaping (Result<HAEntity, Error>) -> Void) {
        // Prepare the JSON payload directly
        let payload: [String: Any] = [
            "entity_id": entityId,
            "temperature": temperature,
            "hvac_mode": hvacMode.rawValue
        ]

        // Convert payload to Data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload, options: []) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to encode request body"])))
            return
        }

        // Make sure to use the correct endpoint
        let correctEndpoint = "api/services/climate/set_temperature"

        // Directly call performRequest on HassRestClient
        HassRestClient.shared.performRequest(endpoint: correctEndpoint, method: "POST", body: jsonData) { (result: Result<HAEntity, Error>) in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    // Additional functionalities leveraging HassRestClient
    func fetchDeviceState(deviceId: String, completion: @escaping (Result<HassRestClient.DeviceState, Error>) -> Void) {
        restClient.fetchDeviceState(deviceId: deviceId, completion: completion)
    }

    func callScript(entityId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        restClient.callScript(entityId: entityId, completion: completion)
    }
    
    func setHvacModeAndTemperature(for room: Room, mode: HvacModes, temperature: Int) {
        // Prepare the command data including the temperature
        let commandData: [String: HassRestClient.AnyEncodable] = [
            "entity_id": HassRestClient.AnyEncodable(room.entityId),
            "hvac_mode": HassRestClient.AnyEncodable(mode.rawValue),
            "temperature": HassRestClient.AnyEncodable(temperature)
        ]
        
        // Note: The service to set both the HVAC mode and temperature might differ or require separate calls
        // depending on your Home Assistant setup. Assuming 'climate.set_temperature' can also accept 'hvac_mode':
        _ = HassRestClient.DeviceCommand(service: "climate.set_temperature", entityId: room.entityId, data: commandData)
        
        // Use HassAPIService to send the command
        HassAPIService.shared.sendCommand(entityId: room.entityId, hvacMode: mode, temperature: temperature) { result in

            switch result {
            case .success(_):
                print("Successfully set \(room.rawValue) to \(mode.rawValue) at \(temperature)°C.")
            case .failure(let error):
                print("Failed to set HVAC mode and temperature for \(room.rawValue): \(error)")
            }
        }
    }
}
