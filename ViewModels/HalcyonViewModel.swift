import Foundation
import Combine
import HassFramework

class HalcyonViewModel: ObservableObject {
    static let shared = HalcyonViewModel()
    
    // Observable properties
    @Published var currentEntityId: String = ""
    @Published var temperature: String = "Loading..."
    @Published var humidity: String = "Loading..."
    @Published var tempSet: Int = 22
    @Published var fanSpeed: String = "auto"
    @Published var halcyonMode: HvacModes = .cool
    @Published var minTemperatureForRooms: [Room: Double] = Room.allCases.reduce(into: [:]) { $0[$1] = 17.0 }
    @Published var maxTemperatureForRooms: [Room: Double] = Room.allCases.reduce(into: [:]) { $0[$1] = 23.0 }
    @Published var lowerValue: CGFloat = 0.3
    @Published var upperValue: CGFloat = 0.7
    let minValue: CGFloat = 12.0
    let maxValue: CGFloat = 30.0
    @Published var errorMessage: String?
    @Published var lastCallStatus: CallStatus = .pending
    @Published var hasErrorOccurred: Bool = false
    
    private let clientService: HassAPIService
    private var cancellables = Set<AnyCancellable>()
    
    private var updateTimer: Timer?
    private let debounceInterval: TimeInterval = 0.5
    
    init(clientService: HassAPIService = .shared) {
        self.clientService = clientService
    }
    
    // Function to cycle to the next HVAC mode and send an update to Home Assistant
    public func nextHvacMode() {
        halcyonMode = halcyonMode.next
        sendTemperatureUpdate(entityId: currentEntityId, mode: halcyonMode, temperature: tempSet)
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
    
     // Function to save the temperature value for a room from a slider position
    func setTemperature(_ temperature: Double, for room: Room, isMinTemperature: Bool) {
         if isMinTemperature {
             minTemperatureForRooms[room] = temperature
         } else {
             maxTemperatureForRooms[room] = temperature
         }
     }
     
     func getTemperature(for room: Room, isMinTemperature: Bool) -> Double {
         if isMinTemperature {
             return minTemperatureForRooms[room] ?? 17.0 // Provide a default value if needed
         } else {
             return maxTemperatureForRooms[room] ?? 23.0 // Provide a default value if needed
         }
     }
     
    
     // Method to fetch the min and max temperature for a room
     func getMinAndMaxTemperature(for room: Room) -> (min: Double, max: Double) {
         let min = minTemperatureForRooms[room] ?? 17.0 // Provide a default value
         let max = maxTemperatureForRooms[room] ?? 23.0 // Provide a default value
         return (min, max)
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
