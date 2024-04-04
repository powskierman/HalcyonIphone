import Foundation
import Combine
import HassFramework

class HalcyonViewModel: ObservableObject {
    static let shared = HalcyonViewModel()
    
    // Observable properties
 //   @Published var currentEntityId: String = ""
    @Published var roomStates: [Room: (temperature: Double, mode: HvacModes)] = [:]
//    @Published var temperaturesForRooms: [Room: Double] = Room.allCases.reduce(into: [:]) { $0[$1] = 22 }
//    @Published var hvacModesForRooms: [Room: HvacModes] = Room.allCases.reduce(into: [:]) { $0[$1] = .off }
    @Published var temperature: String = "Loading..."
    @Published var humidity: String = "Loading..."
//    @Published var tempSet: Int = 32
//    @Published var fanSpeed: String = "auto"
//    @Published var halcyonMode: HvacModes = .cool
//    @Published var minTemperatureForRooms: [Room: Double] = Room.allCases.reduce(into: [:]) { $0[$1] = 17.0 }
//    @Published var maxTemperatureForRooms: [Room: Double] = Room.allCases.reduce(into: [:]) { $0[$1] = 23.0 }
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
    
    var hasFetchedInitialStates = false

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
                        self?.handleSuccess(entity: entity, for: entityId)
                    case .failure(let error):
                        print("Error fetching state for \(entityId): \(error)")
                        self?.handleError(for: entityId)
                    }
                }
            }
        }
    }

    private func handleSuccess(entity: HAEntity, for entityId: String) {
        if entityId.contains("temperature"), let temperatureValue = Double(entity.state) {
            temperature = String(format: "%.1f°", temperatureValue)
        } else if entityId.contains("humidity"), let humidityValue = Double(entity.state) {
            humidity = String(format: "%.1f%%", humidityValue)
        }
    }

    private func handleError(for entityId: String) {
        // Update UI or notify user appropriately
        if entityId.contains("temperature") {
            // Possibly update an error message or log appropriately
        } else if entityId.contains("humidity") {
            // Possibly update an error message or log appropriately
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
        guard !isFetchingInitialStates else { return }
        isFetchingInitialStates = true
        let dispatchGroup = DispatchGroup()
        
        Room.allCases.forEach { room in
            let entityId = room.entityId
            
            dispatchGroup.enter() // Assume every entityId is valid and proceed
            
            clientService.fetchEntityState(entityId: entityId) { [weak self] result in
                defer { dispatchGroup.leave() } // Notify completion in all cases
                
                DispatchQueue.main.async {
                    switch result {
                    case .success(let haEntity):
                        let climateModel = ClimateModel(climateEntity: haEntity)
                        print("Successfully fetched climate data for \(climateModel.friendlyName)")

                        // Now that we're using ClimateModel, extract the needed data
                        let temperature = climateModel.temperature
                        let mode = climateModel.hvacMode
                        
                        print("Updating \(room): Temp=\(temperature), Mode=\(mode)")
                        self?.roomStates[room] = (temperature, mode)
                        
                    case .failure(let error):
                        print("Error fetching state for \(entityId): \(error)")
                    }
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.isFetchingInitialStates = false // Indicate loading has finished
            print("Finished fetching initial states for all rooms.")
            self.refreshUIAfterStateUpdate()
        }
        hasFetchedInitialStates = true
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
