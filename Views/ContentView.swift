//
//  ContentView.swift
//  FujitsuIphone
//
//  Created by Michel Lapointe on 2024-03-02.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = HalcyonViewModel.shared
    
//    @State private var selectedTemperature: Double = 22
    @State private var selectedRoom: Room = .chambre
    @State private var temperaturesForRooms: [Room: Double] = Room.allCases.reduce(into: [:]) { $0[$1] = 22 }
    @State private var hvacModesForRooms: [Room: HvacModes] = Room.allCases.reduce(into: [:]) { $0[$1] = .off }
    @State private var showingSettings = false // For presenting the settings view
    
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .clear // Set the background color to clear for a transparent navigation bar
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.preferredFont(forTextStyle: .title1)] // Set title color to white and font to title size
        
        // Apply the appearance to all navigation bar appearances
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    VStack(spacing: 0) {
                        // Use TabView with a selection binding to the selectedRoom
                        TabView(selection: $selectedRoom) {
                            ForEach(Room.allCases, id: \.self) { room in
                                VStack {
                                    ThermostatView(
                                        temperature: self.bindingFor(room: room),
                                        mode: self.hvacModeBindingFor(room: room),
                                        room: room
                                    )
                                    .foregroundColor(.white)
                                    
                                    Spacer() // Push everything up
                                    
                                    // HStack for buttons with Spacers to evenly distribute them
                                    HStack {
                                        Spacer() // Pushes the buttons to the center
                                        
                                        Button(action: {
                                            // Action for the Temp button
                                            print("Temp button tapped")
                                        }) {
                                            HalcyonButtonView(text: viewModel.temperature, outerButtonSize: 100)
                                        }
                                        
                                        Spacer() // Provides spacing between buttons
                                        
                                        Button(action: {
                                            // Action for the Humidity button
                                            viewModel.fetchSensorStates()
                                        }) {
                                            HalcyonButtonView(text: viewModel.humidity, outerButtonSize: 100)
                                        }
                                        
                                        Spacer() // Pushes everything to the center
                                    }
                                    .onAppear {
                                        viewModel.fetchSensorStates()
                                        //                                   viewModel.fetchAndSetInitialState(entityId: "climate.halcyon_chambre")
                                        viewModel.fetchAndSetInitialStates()
                                    }
                                    .padding(.bottom, 70) // Distance from the bottom
                                }
                                .tag(room)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle())
                        .frame(width: geometry.size.width)
                    }
                }
            }
            .navigationTitle(selectedRoom.rawValue) // Use the rawValue for the navigation title
            .navigationBarTitleDisplayMode(.inline)
            // Add a gear icon as a navigation bar item
            .navigationBarItems(trailing: Button(action: {
                showingSettings = true // Trigger the sheet to show the SettingsView
            }) {
                Image(systemName: "gear")
                    .foregroundColor(.white)
                    .font(.title) // Adjust the size of the gear icon if needed
            })
            .sheet(isPresented: $showingSettings) {
                OtherView(selectedRoom: $selectedRoom) // Present the settings view as a sheet
                    .presentationDetents([.fraction(0.6)])
            }
            .applyBackground()
        }
    }
    
    @ViewBuilder
    private func roomView(for room: Room) -> some View {
        if let roomState = viewModel.roomStates[room] {
            ThermostatView(
                temperature: .constant(roomState.temperature),
                mode: .constant(roomState.mode),
                room: room
            )
            .foregroundColor(.white)
            .onAppear {
                viewModel.fetchSensorStates()
            }
        } else {
            Text("Loading...")
        }
    }

    
    private func bindingFor(room: Room) -> Binding<Double> {
        Binding(
            get: { self.temperaturesForRooms[room, default: 22] },
            set: { self.temperaturesForRooms[room] = $0 }
        )
    }
    
    private func hvacModeBindingFor(room: Room) -> Binding<HvacModes> {
        Binding(
            get: { self.hvacModesForRooms[room, default: .off] },
            set: { self.hvacModesForRooms[room] = $0 }
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(HalcyonViewModel())
    }
}
