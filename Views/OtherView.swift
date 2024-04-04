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
    @State private var selectedFanMode: FanModes = .off
    @State private var showingSwingPicker = false
    @State private var selectedSwingMode: SwingModes = .off
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
            .sheet(isPresented: $showingSwingPicker) {
                swingPickerSheet
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
        switch setting {
        case .fan:
            showingFanPicker.toggle()
        case .swing:
            showingSwingPicker.toggle()
        default:
            print("\(setting.rawValue) button tapped")
        }
    }

    private var fanPickerSheet: some View {
        NavigationView {
            Form {
                Picker("Fan Mode", selection: $selectedFanMode) {
                    ForEach(FanModes.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(WheelPickerStyle())
            }
            .navigationBarItems(trailing: Button("Done") {
                showingFanPicker = false
                let entityId = "climate.halcyon_\(selectedRoom.rawValue.lowercased())" // Corrected use of entityId
                print("Selected room: \(entityId)")
                print("Selected fan mode: \(selectedFanMode.rawValue)")
                // Call update fan mode logic here
                HassAPIService.shared.updateFanModeForRoom(entityId: entityId, fanMode: selectedFanMode) { result in
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

    private var swingPickerSheet: some View {
        NavigationView {
            Form {
                Picker("Swing Mode", selection: $selectedSwingMode) {
                    ForEach(SwingModes.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(WheelPickerStyle())
            }
            .navigationBarItems(trailing: Button("Done") {
                showingSwingPicker = false
                let entityId = "climate.\(selectedRoom.rawValue.lowercased())"
                print("Selected swing mode: \(selectedSwingMode.rawValue)")
                // Call update swing mode logic here similar to fan mode update logic
            })
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Swing Mode").font(.headline)
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
