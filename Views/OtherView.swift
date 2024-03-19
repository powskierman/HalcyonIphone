//
//  OtherView.swift
//  HalcyonIphone
//
//  Created by Michel Lapointe on 2024-03-16.
//

import SwiftUI


struct OtherView: View {
    @State private var selectedValue: Double = 20
    @State private var minValueSelected: CGFloat = 10
    @State private var maxValueSelected: CGFloat = 40
    @State private var showingFanPicker = false
    @State private var selectedFanMode: FanMode = .off
    @Binding var selectedRoom: Room // Assume Room is a defined enum
    @Environment(\.presentationMode) var presentationMode

    let heatPumpRangeSlider = HeatPumpRangeSlider()
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        GeometryReader { geometry in
            VStack {
 //               Spacer().frame(height: 20)
                heatPumpRangeSlider
                     .frame(height: geometry.size.height / 5) // Adjust the height proportion as needed

                buttonsGridView
                
   //             Spacer(minLength: 100) // Pushes everything to the top
            }
            .sheet(isPresented: $showingFanPicker) {
                self.fanPickerSheet
            }
            .applyBackground() // Assuming this is a custom view modifier
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(selectedRoom.rawValue)
            .toolbar { toolbarContent }
        }
    }
    // Extract the RangeSlider configuration into a computed property
 

    // Extract the buttons grid view
    private var buttonsGridView: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            
            ForEach(Setting.allCases, id: \.self) { setting in
                Button(action: { self.buttonAction(for: setting) }) {
                    HalcyonButtonView(text: setting.rawValue,
                                      
                                      outerButtonSize: 100)
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

    // Extract the picker sheet view
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
            .navigationTitle("Select Fan Mode")
            .navigationBarItems(trailing: Button("Done") { showingFanPicker = false })
        }
    }

    // Extract toolbar content
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

extension View {
    // Custom modifier to configure the RangeSlider style
    func configuredSliderStyle() -> some View {
        self
 //           .scaleMinValue(10)
 //           .scaleMaxValue(30)
            // Add all your other modifiers here
    }
}


struct OtherView_Previews: PreviewProvider {
    static var previews: some View {
        OtherView(selectedRoom: .constant(.chambre))
    }
}
