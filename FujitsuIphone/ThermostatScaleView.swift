import SwiftUI

struct ThermometerScaleView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<40) { index in
                    if index == 10 {
                        temperatureMarking(text: "20", at: 270, geometry: geometry)
                    } else if index == 20 {
                        temperatureMarking(text: "10", at: 180, geometry: geometry)
                    } else if index == 30 {
                        temperatureMarking(text: "30", at: 360, geometry: geometry)
                    } else {
                        tickMark(forIndex: index, totalTicks: 40, geometry: geometry)
                    }
                }
            }
        }
    }

    private func tickMark(forIndex index: Int, totalTicks: Int, geometry: GeometryProxy) -> some View {
        let outerMargin: CGFloat = 10 // Margin outside the ThermometerDialView
        let scaleDiameter = min(geometry.size.width, geometry.size.height) + outerMargin
        let radius = scaleDiameter / 2
        let angle = (Double(index) / Double(totalTicks)) * 360.0 + 180
        let tickRotation = Angle(degrees: angle)

        return Rectangle()
            .fill(Color.white)
            .frame(width: scaleDiameter * 0.008, height: scaleDiameter * 0.04)
            .offset(x: 0, y: -radius)
            .rotationEffect(tickRotation)
    }

    private func temperatureMarking(text: String, at angle: Double, geometry: GeometryProxy) -> some View {
        let outerMargin: CGFloat = 10 // Adjust this margin to move the digits further out if needed
        let scaleDiameter = min(geometry.size.width, geometry.size.height) // Diameter of the scale
        let radius = (scaleDiameter / 2) + outerMargin // Increase radius for text positioning
        let adjustedAngle = angle.truncatingRemainder(dividingBy: 360)
        let angleRadians = adjustedAngle * Double.pi / 180
        // Calculate x and y positions based on the adjusted radius
        let xPosition = radius * cos(angleRadians) + geometry.size.width / 2
        let yPosition = radius * sin(angleRadians) + geometry.size.height / 2

        return Text(text)
            .font(.system(size: scaleDiameter * 0.05)) // Adjust font size based on your needs
            .foregroundColor(.white)
            .position(x: xPosition, y: yPosition)
    }
}

struct ThermometerScaleView_Previews: PreviewProvider {
    static var previews: some View {
        ThermometerScaleView()
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
