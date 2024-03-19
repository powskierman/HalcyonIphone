//
//  SliderTestView.swift
//  HalcyonIphone
//
//  Created by Michel Lapointe on 2024-03-17.
//

import SwiftUI

struct HeatPumpRangeSlider: View {
    @State private var lowerValue: CGFloat = 0.3
    @State private var upperValue: CGFloat = 0.7
    let minValue: CGFloat = 15
    let maxValue: CGFloat = 30

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
                    HeatPumpHandle(value: $lowerValue, otherHandleValue: $upperValue, geometrySize: geometry.size.width, label: "\(Int(minValue + lowerValue * (maxValue - minValue)))°")

                    HeatPumpHandle(value: $upperValue, otherHandleValue: $lowerValue, geometrySize: geometry.size.width, label: "\(Int(minValue + upperValue * (maxValue - minValue)))°")                }
            }
            .frame(height: 40)
        }
    }
}

// HeatPumpHandle view remains unchanged


struct HeatPumpHandle: View {
    @Binding var value: CGFloat
    @Binding var otherHandleValue: CGFloat // Changed to @Binding

    var geometrySize: CGFloat
    var label: String

    var body: some View {
        ZStack {
            // HalcyonButtonView is used here with the correct binding
            HalcyonButtonView(text: label, outerButtonSize: 70)
                .offset(x: value * geometrySize - 35) // Assuming handle center is at 'value * geometrySize'
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            let newSliderPosition = gesture.location.x / geometrySize
                            // This ensures the handle moves within the slider's bounds and does not cross the other handle
                            if value < $otherHandleValue.wrappedValue {
                                self.value = min(max(0, newSliderPosition), $otherHandleValue.wrappedValue)
                             } else {
                                 self.value = min(max($otherHandleValue.wrappedValue, newSliderPosition), 1)
                             }
                        }
                )
        }
    }
}

struct HeatPumpRangeSlider_Previews: PreviewProvider {
    static var previews: some View {
        HeatPumpRangeSlider()
    }
}
