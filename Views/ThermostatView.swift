import SwiftUI

struct ThermostatView: View {
    @Binding var temperature: Double
    @Binding var mode: HvacModes
    var room: Room
    @EnvironmentObject var climateService: HalcyonViewModel
    
    private let baseRingSize: CGFloat = 340
    private let baseOuterDialSize: CGFloat = 320
    private let minTemperature: CGFloat = 10
    private let maxTemperature: CGFloat = 30
    
    var ringValue: CGFloat {
        temperature / 40
    }
    
    private var ringSize: CGFloat { baseRingSize }
    private var outerDialSize: CGFloat { baseOuterDialSize }
    
    init(temperature: Binding<Double>, mode: Binding<HvacModes>, room: Room) {
        self._temperature = temperature
        self._mode = mode
        self.room = room
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ThermometerScaleView()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                Circle()
                    .trim(from: 0.25, to: min(ringValue, 0.75))
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
                    .animation(.linear(duration: 1), value: ringValue)
                
                ThermometerDialView(outerDialSize: outerDialSize, degrees: CGFloat(temperature) / 40 * 360)
                    .focusable()
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let x = min(max(value.location.x, 0), outerDialSize)
                                let y = min(max(value.location.y, 0), outerDialSize)
                                
                                let endPoint = CGPoint(x: x, y: y)
                                let centerPoint = CGPoint(x: outerDialSize / 2, y: outerDialSize / 2)
                                
                                let angle = calculateAngle(centerPoint: centerPoint, endPoint: endPoint)
                                
                                if angle < 90 || angle > 270 { return } // Constraint to specific angles if necessary
                                
                                let degrees = angle - angle.remainder(dividingBy: 9)
                                let newTemperature = min(max(degrees / 360 * 40, minTemperature), maxTemperature)
                                temperature = Double(newTemperature)
                            }
                    )
                
                ThermostatModeView(
                    temperature: CGFloat(temperature),
                    entityId: room.entityId, // Make sure your Room type can provide an entityId
                    mode: $mode
                )
                .onChange(of: temperature) { newTemperature in
                    postTemperatureUpdate(newTemperature: newTemperature)
                }
            }
        }
    }

    private func postTemperatureUpdate(newTemperature: Double) {
        let entityId = room.entityId
        climateService.sendTemperatureUpdate(entityId: entityId, mode: mode, temperature: Int(newTemperature))
    }

    private func calculateAngle(centerPoint: CGPoint, endPoint: CGPoint) -> CGFloat {
        let radians = atan2(endPoint.x - centerPoint.x, centerPoint.y - endPoint.y)
        let degrees = 180 + (radians * 180 / .pi)
        return degrees
    }
}

struct ThermometerView_Previews: PreviewProvider {
    static var previews: some View {
        ThermostatView(
            temperature: .constant(22.0),
            mode: .constant(.fan_only),
            room: .chambre
        )
        .environmentObject(HalcyonViewModel())
    }
}
