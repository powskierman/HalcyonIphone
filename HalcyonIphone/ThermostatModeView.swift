//
//  ThermostatModeView.swift
//  SmartHomeThermostat
//

import SwiftUI

struct ThermostatModeView: View {
    var temperature: CGFloat
    var entityId: String // Add this to know which room/entity you're controlling
    @Binding var mode: HvacModes
    @EnvironmentObject var climateViewModel: ClimateViewModel

    var body: some View {
        VStack {
            Text("\(temperature, specifier: "%.0f")°")
                .font(.system(size: 54))
                .foregroundColor(.white)
  
            Image(systemName: mode.systemImageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .padding()
                .onTapGesture {
                    let nextMode = mode.next
                    mode = nextMode
                    climateViewModel.updateHvacMode(entityId: entityId, newMode: nextMode) // Update this call
                }
        }
    }
}

struct ThermostatModeView_Previews: PreviewProvider {
    static var previews: some View {
        ThermostatModeView(
            temperature: 22,
            entityId: "",
            mode: .constant(.cool)
        )
        .background(Color("Inner Dial 2"))
    }
}
