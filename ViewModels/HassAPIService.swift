import Foundation
import HassFramework

class HassAPIService: ObservableObject {
    static let shared = HassAPIService()
    private var restClient: HassRestClient
    
    init() {
        self.restClient = HassRestClient.shared
    }
    
    // This method allows sending commands with data that conforms to Encodable or is already a dictionary
    func sendCommand(entityId: String, service: String, data: Any, completion: @escaping (Result<Void, Error>) -> Void) {
        var jsonData: Data?
        
        if let data = data as? [String: HassRestClient.AnyEncodable] {
            jsonData = try? JSONEncoder().encode(data)
        } else if let data = data as? [String: Any] {
            jsonData = try? JSONSerialization.data(withJSONObject: data, options: [])
        }
        
        guard let jsonDataUnwrapped = jsonData else {
            completion(.failure(NSError(domain: "HassAPIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to encode data to JSON"])))
            return
        }
        
        let endpoint = "api/services/\(service.replacingOccurrences(of: ".", with: "/"))"
        
        restClient.performRequest(endpoint: endpoint, method: "POST", body: jsonDataUnwrapped, expectingResponse: false) { (result: Result<EmptyResponse, Error>) in
            switch result {
            case .success(_):
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Example method for updating temperature thresholds
    func updateTemperatureThreshold(entityId: String, temperature: CGFloat, completion: @escaping (Result<Void, Error>) -> Void) {
        let temperatureInt = Int(temperature)
        
        let commandData: [String: Any] = [
            "entity_id": entityId,
            "value": temperatureInt
        ]
        
        sendCommand(entityId: entityId, service: "input_number.set_value", data: commandData, completion: completion)
    }
    
    // Example method for updating fan mode
    func updateFanModeForRoom(entityId: String, fanMode: FanMode, completion: @escaping (Result<Void, Error>) -> Void) {
        let commandData: [String: Any] = [
            "entity_id": entityId,
            "fan_mode": fanMode.rawValue
        ]
        
        sendCommand(entityId: entityId, service: "climate.set_fan_mode", data: commandData, completion: completion)
    }
    
    // Additional functionalities leveraging HassRestClient
    func fetchDeviceState(deviceId: String, completion: @escaping (Result<HassRestClient.DeviceState, Error>) -> Void) {
        restClient.fetchDeviceState(deviceId: deviceId, completion: completion)
    }
    
    func fetchEntityState(entityId: String, completion: @escaping (Result<HAEntity, Error>) -> Void) {
        restClient.fetchState(entityId: entityId, completion: completion)
    }
    
    func callScript(entityId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let commandData: [String: Any] = ["entity_id": entityId]
        sendCommand(entityId: entityId, service: "script.turn_on", data: commandData, completion: completion)
    }
    
    struct EmptyResponse: Decodable {}
}
