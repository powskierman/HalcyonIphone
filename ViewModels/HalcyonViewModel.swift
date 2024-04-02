import Foundation
import Combine
import HassFramework

class HalcyonViewModel: ObservableObject {
    static let shared = HalcyonViewModel()
    
    // Observable properties
    @Published var currentEntityId: String = ""
    @Published var roomStates: [Room: (temperature: Double, mode: HvacModes)] = [:]
    @Published var temperaturesForRooms: [Room: Double] = Room.allCases.reduce(into: [:]) { $0[$1] = 22 }
    @Published var hvacModesForRooms: [Room: HvacModes] = Room.allCases.reduce(into: [:]) { $0[$1] = .off }
    @Published var temperature: String = "Loading..."
    @Published var humidity: String = "Loading..."
    @Published var tempSet: Int = 32
    @Published var fanSpeed: String = "auto"
    @Published var halcyonMode: HvacModes = .cool
    @Published var minTemperatureForRooms: [Room: Double] = Room.allCases.reduce(into: [:]) { $0[$1] = 17.0 }
    @Published var maxTemperatureForRooms: [Room: Double] = Room.allCases.reduce(into: [:]) { $0[$1] = 23.0 }
    @Published var lowerValue: CGFloat = 0.3
    @Published var upperValue: CGFloat = 0.7
    @Published var isFetchingInitialStates: Bool = false
    
    @Published var currentTemperature: Double = 0 {
        willSet(newTemperature) {
            print("Updating temperature from \(currentTemperature) to \(newTemperature)")
        }
    }


    let minValue: CGFloat = 12.0
    let maxValue: CGFloat = 30.0
    @Published var errorMessage: String?
    
    private let clientService: HassAPIService
    private var updateTimer: Timer?
    private let debounceInterval: TimeInterval = 0.5
    
    init(clientService: HassAPIService = .shared) {
        self.clientService = clientService
    }
    
    // Function to update temperature and optionally HVAC mode in Home Assistant
    public func sendTemperatureUpdate(entityId: String, mode: HvacModes, temperature: Int) {
        // Debounce temperature update to prevent rapid sending of commands
        updateTimer?.invalidate()
        updateTimer = Timer.scheduledTimer(withTimeInterval: debounceInterval, repeats: false) { [weak self] _ in
            guard let self = self else { return }

            // Prepare the command data including the temperature
            let commandData: [String: HassRestClient.AnyEncodable] = [
                "entity_id": HassRestClient.AnyEncodable(entityId),
                "hvac_mode": HassRestClient.AnyEncodable(mode.rawValue),
                "temperature": HassRestClient.AnyEncodable(temperature)
            ]

            self.clientService.sendCommand(entityId: entityId, service: "climate.set_temperature", data: commandData) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(_):
                        print("Temperature and mode set successfully for \(entityId)")
                    case .failure(let error):
                        print("Failed to set temperature and mode for \(entityId): \(error)")
                        self.errorMessage = "Failed to set temperature and mode for \(entityId): \(error.localizedDescription)"
                    }
                }
            }
        }
    }
    
    func fetchSensorStates() {
        let sensorIds = ["sensor.nhtemp_temperature", "sensor.nhtemp_humidity"]
        let dispatchGroup = DispatchGroup()

        sensorIds.forEach { entityId in
            dispatchGroup.enter()
            HassAPIService.shared.fetchEntityState(entityId: entityId) { [weak self] result in
                DispatchQueue.main.async {
                    defer { dispatchGroup.leave() }
                    switch result {
                    case .success(let entity):
                        if entityId.contains("temperature") {
                            // Convert the state to Double and format it with one decimal place
                            if let temperatureValue = Double(entity.state) {
                                self?.temperature = String(format: "%.1f°", temperatureValue)
                            } else {
                                self?.temperature = "Invalid"
                            }
                        } else if entityId.contains("humidity") {
                            // Convert the state to Double and format it with one decimal place
                            if let humidityValue = Double(entity.state) {
                                self?.humidity = String(format: "%.1f%%", humidityValue)
                            } else {
                                self?.humidity = "Invalid"
                            }
                        }
                    case .failure(let error):
                        print("Error fetching state for \(entityId): \(error)")
                        if entityId.contains("temperature") {
                            self?.temperature = "Error"
                        } else if entityId.contains("humidity") {
                            self?.humidity = "Error"
                        }
                    }
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            print("Finished fetching all sensor states.")
            // Here, you might update UI or state to indicate loading is complete.
        }
    }
    
    
    
    // Add other necessary functions from WatchManager if needed
}


extension HalcyonViewModel {
    public func updateHvacMode(entityId: String, newMode: HvacModes) {
        // Prepare the command data for updating the HVAC mode
        let commandData: [String: HassRestClient.AnyEncodable] = [
            "entity_id": HassRestClient.AnyEncodable(entityId),
            "hvac_mode": HassRestClient.AnyEncodable(newMode.rawValue)
        ]
        
        self.clientService.sendCommand(entityId: entityId, service: "climate.set_hvac_mode", data: commandData) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    print("HVAC mode updated successfully for \(entityId)")
                case .failure(let error):
                    print("Failed to update HVAC mode for \(entityId): \(error)")
                    self.errorMessage = "Failed to update HVAC mode for \(entityId): \(error.localizedDescription)"
                }
            }
        }
    }
}

extension HalcyonViewModel {
    func fetchAndSetInitialStates() {
        isFetchingInitialStates = true // Indicate loading has started
        let dispatchGroup = DispatchGroup()

        Room.allCases.forEach { room in
            let entityId = room.entityId
            
            // Check if the entityId corresponds to an existing entity
            // For now, let's assume 'climate.halcyon_chambre' is the only existing entity
            if entityId == "climate.halcyon_chambre" {
                dispatchGroup.enter() // Enter only if entity exists
                
                clientService.fetchEntityState(entityId: entityId) { [weak self] result in
                    DispatchQueue.main.async {
                        defer { dispatchGroup.leave() } // Ensure the group is notified upon completion
                        
                        switch result {
                        case .success(let entity):
                            print("Successfully fetched entity: \(entity)")
                            
                            // Debugging: Check what's inside additionalAttributes
                            print("Debugging - additionalAttributes: \(entity.attributes.additionalAttributes)")
                            
                            // Attempt to fetch the temperature
 //                           if entityId.contains("climate.") {
//                                var desiredTemperature: Double = entity.attributes.additionalAttributes["temperature"] {
//                                     print("Successfully extracted desired temperature: \(desiredTemperature)")
//                                     // Update the UI or internal state with the extracted temperature
//                                     // For example:
  //                                   self?.updateThermostatSetting(to: desiredTemperature)
//                                     let mode = HvacModes(rawValue: entity.state) ?? .off // Default to .off if nil
//                                     print("Updating \(room): Temp=\(String(describing: desiredTemperature)), Mode=\(mode)") // This will print the correct temperature
 //                                    self?.roomStates[room] = (temperature, mode)
//                                } else {
//                                     print("Failed to extract desired temperature. Using default value.")
//                                     // Handle the failure case, e.g., by using a default value or showing an error
//                                 }
//                             }
                            
                            let temperature = entity.attributes.additionalAttributes["temperature"] as? Double ?? 33 // Default to 33 if nil
                            let mode = HvacModes(rawValue: entity.state) ?? .off // Default to .off if nil
                            
                            print("Updating \(room): Temp=\(temperature), Mode=\(mode)") // This will print the correct temperature
                            
                            self?.roomStates[room] = (temperature, mode)
                        case .failure(let error):
                            print("Error fetching state for \(entityId): \(error)")
                        }
                    }
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            self.isFetchingInitialStates = false // Indicate loading has finished
            print("Finished fetching all sensor states.")
        }
    }
}

extension HalcyonViewModel {
    // Call this method after updating roomStates to refresh the UI
    func refreshUIAfterStateUpdate() {
        // Notify the UI to refresh by triggering an update on an @Published property
        // This is just a trigger, you might already have a better property to observe
        self.objectWillChange.send()
    }
}

extension HAAttributes {
    var temperature: Double? {
        get {
            return self.additionalAttributes["temperature"] as? Double
        }
    }
}
