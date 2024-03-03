//
//  ThermostatModeView.swift
//  SmartHomeThermostat
//

import SwiftUI

struct ThermostatModeView: View {
    var temperature: CGFloat
    @Binding var mode: HvacModes // Assuming you've updated this view to use a binding for mode as suggested

    var body: some View {
        VStack {
            // Display the temperature
            Text("\(temperature, specifier: "%.0f")°")
                .font(.system(size: 54))
                .foregroundColor(.white)
  
            // Display the mode with an interactive element that allows changing the mode
            // Here, we use the mode binding directly instead of accessing it through a viewModel
            Image(systemName: mode.systemImageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .padding()
                .onTapGesture {
                    // Cycle to the next HVAC mode
                    mode = mode.next
                }
        }
    }
}

struct ThermostatModeView_Previews: PreviewProvider {
    static var previews: some View {
        ThermostatModeView(
            temperature: 22,
            mode: .constant(.cool)
        )
        .background(Color("Inner Dial 2"))
    }
}
