//
//  ContentView.swift
//  FujitsuIphone
//
//  Created by Michel Lapointe on 2024-03-02.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTemperature: Double = 22
    @State private var selectedRoom: Room = .chambre
    @State private var temperaturesForRooms: [Room: Double] = Room.allCases.reduce(into: [:]) { $0[$1] = 22 }
    @State private var hvacModesForRooms: [Room: HvacModes] = Room.allCases.reduce(into: [:]) { $0[$1] = .off }
    
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
                     Color("Background").ignoresSafeArea()
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
                                 }
                                 .tag(room) // Use the enum case itself as a tag, which is Hashable
                             }
                         }
                         .tabViewStyle(PageTabViewStyle())
                         .frame(width: geometry.size.width)
                     }
                 }
             }
             .navigationTitle(selectedRoom.rawValue) // Use the rawValue for the navigation title
             .navigationBarTitleDisplayMode(.inline)
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
        ContentView().environmentObject(ClimateViewModel()) // This is where you add the environment object
    }
}
