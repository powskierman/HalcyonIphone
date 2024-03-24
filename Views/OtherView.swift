//
//  OtherView.swift
//  HalcyonIphone
//
//  Created by Michel Lapointe on 2024-03-16.
//

import SwiftUI

struct OtherView: View {
    @ObservedObject var viewModel = HalcyonViewModel.shared
    @State private var showingFanPicker = false
    @State private var selectedFanMode: FanMode = .off
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedRoom: Room

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        GeometryReader { geometry in
            VStack {
                HeatPumpRangeSlider(
                    lowerValue: Binding<CGFloat>(
                        get: { self.viewModel.lowerValue },
                        set: { newValue in
                            self.viewModel.lowerValue = newValue
                            let correctedLowerTemperature = Int(viewModel.minValue + newValue * (viewModel.maxValue - viewModel.minValue))
                            HassAPIService.shared.updateTemperatureThreshold(entityId: "input_number.lower_temp_threshold", temperature: CGFloat(correctedLowerTemperature)) { result in
                                switch result {
                                case .success():
                                    print("Successfully updated lower temperature threshold")
                                case .failure(let error):
                                    print("Error updating lower temperature threshold: \(error)")
                                }
                            }
                        }
                    ),
                    upperValue: Binding<CGFloat>(
                        get: { self.viewModel.upperValue },
                        set: { newValue in
                            self.viewModel.upperValue = newValue
                            let correctedUpperTemperature = Int(viewModel.minValue + newValue * (viewModel.maxValue - viewModel.minValue))
                            HassAPIService.shared.updateTemperatureThreshold(entityId: "input_number.upper_temp_threshold", temperature: CGFloat(correctedUpperTemperature)) { result in
                                switch result {
                                case .success():
                                    print("Successfully updated upper temperature threshold")
                                case .failure(let error):
                                    print("Error updating upper temperature threshold: \(error)")
                                }
                            }
                        }
                    ),
                    minValue: viewModel.minValue,
                    maxValue: viewModel.maxValue
                )
                .frame(height: geometry.size.height / 5)

                buttonsGridView
            }
            .sheet(isPresented: $showingFanPicker) {
                fanPickerSheet
            }
            .navigationTitle(selectedRoom.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
        }
    }

    private var buttonsGridView: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(Setting.allCases, id: \.self) { setting in
                Button(action: { self.buttonAction(for: setting) }) {
                    HalcyonButtonView(text: setting.rawValue, outerButtonSize: 100)
                }
                .padding(5)
            }
        }
        .padding(.horizontal)
    }

    private func buttonAction(for setting: Setting) {
        if setting == .fan {
            showingFanPicker.toggle()
        } else {
            print("\(setting.rawValue) button tapped")
        }
    }

    private var fanPickerSheet: some View {
        NavigationView {
            Form {
                Picker("Fan Mode", selection: $selectedFanMode) {
                    ForEach(FanMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(WheelPickerStyle())
            }
//            .navigationTitle("Select Fan Mode")
            .navigationBarItems(trailing: Button("Done") {
                showingFanPicker = false
                // Here, it's assumed that `selectedRoom` can directly provide an entity ID suitable for Home Assistant.
                // You may need to adjust `entityId` based on your actual entity naming convention in Home Assistant.
                _ = "climate.\(selectedRoom.rawValue.lowercased())" // Modify this line as necessary to match your entity IDs
                print("Selected fan mode: \(selectedFanMode.rawValue)")
                HassAPIService.shared.updateFanModeForRoom(entityId: "climate.halcyon_chambre", fanMode: selectedFanMode) { result in
                    switch result {
                    case .success():
                        print("Fan mode successfully updated to \(selectedFanMode.rawValue)")
                    case .failure(let error):
                        print("Failed to update fan mode: \(error)")
                    }
                
                }
            })
            .toolbar {
                ToolbarItem(placement: .principal) { // 'principal' places it in the center
                    Text("Fan Mode").font(.headline)
                }
                }
        }
    }



    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                HStack {
                    Image(systemName: "arrow.left").foregroundColor(.white)
                    Text("Back").foregroundColor(.white)
                }
            }
        }
    }
}

struct OtherView_Previews: PreviewProvider {
    static var previews: some View {
        OtherView(selectedRoom: .constant(.chambre))
    }
}
