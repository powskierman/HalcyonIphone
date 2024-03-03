import SwiftUI

struct ThermostatView: View {
    @Binding var temperature: Double
    @Binding var mode: HvacModes // Add binding for HVAC mode
    var room: Room
    var screenSize: CGSize
    @EnvironmentObject var climateService: ClimateViewModel
    
    private let baseRingSize: CGFloat = 340
    private let baseOuterDialSize: CGFloat = 320
    private let minTemperature: CGFloat = 10
    private let maxTemperature: CGFloat = 30

    @State private var currentTemperature: CGFloat = 0
    @State private var degrees: CGFloat = 36
    @State private var showStatus = false
    @State private var crownRotationValue: Double = 0 // Track digital crown rotation
    
    private var ringSize: CGFloat { baseRingSize }
    private var outerDialSize: CGFloat { baseOuterDialSize }
    
    init(temperature: Binding<Double>, mode: Binding<HvacModes>, room: Room) {
         self._temperature = temperature
         self._mode = mode // Initialize the mode binding
         self.room = room
        self.screenSize = CGSize.zero
     }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ThermometerScaleView()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                Circle()
                    .trim(from: 0.25, to: min(CGFloat(temperature) / 40, 0.75))
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color("Temperature Ring 1"), Color("Temperature Ring 2")]),
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round)
                    )
                    .frame(width: ringSize, height: ringSize)
                    .rotationEffect(.degrees(90))
                    .animation(.linear(duration: 1), value: CGFloat(temperature) / 40)
                
                ThermometerDialView(outerDialSize: outerDialSize, degrees: CGFloat(temperature) / 40 * 360)
                ThermostatModeView(temperature: CGFloat(temperature), mode: $mode)
            }
            .focusable()

            .onChange(of: temperature) { newTemperature in
                postTemperatureUpdate(newTemperature: newTemperature)
            }
        }
    }

   private func postTemperatureUpdate(newTemperature: Double) {
        let entityId = room.entityId
        climateService.sendTemperatureUpdate(entityId: entityId, mode: mode, temperature: Int(newTemperature))
    }
}

    private func calculateAngle(centerPoint: CGPoint, endPoint: CGPoint) -> CGFloat {
        let radians = atan2(endPoint.x - centerPoint.x, centerPoint.y - endPoint.y)
        let degrees = 180 + (radians * 180 / .pi)
        return degrees
    }

struct ThermostatView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            // Assuming `HvacModes.fan_only` is a valid enum case and `.chambre` is a valid `Room` case
            ThermostatView(
                temperature: .constant(22.0),
                mode: .constant(.fan_only), // Assuming HvacModes.fan_only is correct
                room: .chambre // Assuming .chambre is a valid Room value
            )
            .environmentObject(ClimateViewModel()) // Assuming ClimateViewModel is the correct type
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("Background"))
        }
    }
}
