import Foundation
import Combine
import HassFramework

class ClimateViewModel: ObservableObject {
    static let shared = ClimateViewModel()
    
    // Observable properties
    @Published var currentEntityId: String = ""
    @Published var tempSet: Int = 22
    @Published var fanSpeed: String = "auto"
    @Published var halcyonMode: HvacModes = .cool
    @Published var errorMessage: String?
    @Published var lastCallStatus: CallStatus = .pending
    @Published var hasErrorOccurred: Bool = false
    
    private let clientService: HassAPIService
    private var cancellables = Set<AnyCancellable>()
    
    // Timer for debouncing temperature updates
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
            self?.clientService.sendCommand(entityId: entityId, hvacMode: mode, temperature: temperature) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(_):
                        print("Temperature and mode set successfully for \(entityId)")
                    case .failure(let error):
                        print("Failed to set temperature and mode for \(entityId): \(error)")
                        self?.errorMessage = "Failed to set temperature and mode for \(entityId): \(error.localizedDescription)"
                    }
                }
            }
        }
    }
    
    // Add other necessary functions from WatchManager if needed
}
extension ClimateViewModel {
    public func updateHvacMode(entityId: String, newMode: HvacModes) {
        // Assuming you have a method in HassAPIService to specifically update HVAC mode
        // This method will likely differ; adjust according to your actual implementation
        self.clientService.sendCommand(entityId: entityId, hvacMode: newMode, temperature: self.tempSet) { result in
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
