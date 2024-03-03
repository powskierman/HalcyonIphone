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
