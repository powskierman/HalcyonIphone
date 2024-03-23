//
//  HeatPumpRangeSlider.swift
//  HalcyonIphone
//
//  Created by Michel Lapointe on 2024-03-17.
//

import SwiftUI

struct HeatPumpRangeSlider: View {
    @Binding var lowerValue: CGFloat
    @Binding var upperValue: CGFloat
    let minValue: CGFloat
    let maxValue: CGFloat

    var body: some View {
        VStack {
            GeometryReader { geometry in
                
                ZStack(alignment: .leading) {
                    // Red section adjusted
                RoundedRectangle(cornerRadius: 3)
                        .frame(width: max(0, lowerValue * geometry.size.width - 35), height: 6)
                        .foregroundColor(.red)
                        .zIndex(1) // Ensure red is over gray

                    // Blue section adjusted
                    RoundedRectangle(cornerRadius: 3)
                        .frame(width: max(0, geometry.size.width * (1 - upperValue) - 40), height: 6)
                        .foregroundColor(.blue)
                        .offset(x: upperValue * geometry.size.width + 35) // Adjusting the start point
                        .zIndex(1) // Ensure blue is over gray

                    // Handles
                    HeatPumpHandle(
                        value: $lowerValue,
                        otherHandleValue: $upperValue,
                        geometrySize: geometry.size.width,
                        minValue: minValue,  // Pass the minValue from HeatPumpRangeSlider
                        maxValue: maxValue   // Pass the maxValue from HeatPumpRangeSlider
                    )

                    HeatPumpHandle(
                        value: $upperValue,
                        otherHandleValue: $lowerValue,
                        geometrySize: geometry.size.width,
                        minValue: minValue,  // Pass the minValue from HeatPumpRangeSlider
                        maxValue: maxValue   // Pass the maxValue from HeatPumpRangeSlider
                    )         }
            }
            .frame(height: 40)
        }
    }
}

// HeatPumpHandle view remains unchanged


struct HeatPumpHandle: View {
    @Binding var value: CGFloat
    @Binding var otherHandleValue: CGFloat // Changed to @Binding
    let geometrySize: CGFloat
    let minValue: CGFloat
    let maxValue: CGFloat
    var label: String {
          "\(Int(minValue + value * (maxValue - minValue)))°"
      }
    
    var body: some View {
        ZStack {
            // HalcyonButtonView is used here with the correct binding
            HalcyonButtonView(text: label, outerButtonSize: 70)
                .offset(x: value * geometrySize - 35) // Assuming handle center is at 'value * geometrySize'
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            let newSliderPosition = gesture.location.x / geometrySize
                            print("DragGesture onChanged triggered")
                            print("Gesture location.x: \(gesture.location.x)")
                            print("Geometry size width: \(geometrySize)")
                            print("New slider position (raw): \(newSliderPosition)")

                            // Ensuring the handle moves within the slider's bounds and does not cross the other handle
                            if value < otherHandleValue {
                                let clampedValue = min(max(0, newSliderPosition), otherHandleValue)
                                print("Adjusting lowerValue to: \(clampedValue)")
                                self.value = clampedValue
                            } else {
                                let clampedValue = min(max(otherHandleValue, newSliderPosition), 1)
                                print("Adjusting upperValue to: \(clampedValue)")
                                self.value = clampedValue
                            }

                            print("Updated value after clamping: \(self.value)")
                            print("Calculated temperature label: \(Int(minValue + self.value * (maxValue - minValue)))°")
                        
                        }
                )
        }
    }
}

struct HeatPumpRangeSlider_Previews: PreviewProvider {
    static var previews: some View {
        HeatPumpRangeSlider(
            lowerValue: .constant(0.3),
            upperValue: .constant(0.7),
            minValue: 0.0,
            maxValue: 1.0
        )
    }
}
