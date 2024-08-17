//
//  ContentView.swift
//  FujitsuIphone
//
//  Created by Michel Lapointe on 2024-03-02.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = HalcyonViewModel.shared
    @State private var selectedRoom: Room = .chambre
    @State private var showingSettings = false
    
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.preferredFont(forTextStyle: .title1)]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        NavigationView {
            if viewModel.isFetchingInitialStates {
                Text("Fetching room states...")
            } else {
                GeometryReader { geometry in
                    VStack(spacing: 0) {
                        TabView(selection: $selectedRoom) {
                            ForEach(Room.allCases, id: \.self) { room in
                                VStack {
                                    let _ = print("room: \(room) roomStates: \(String(describing: viewModel.roomStates[room]))")
                                    if viewModel.roomStates[room] != nil {
                                        ThermostatView(
                                            temperature: tempBindingFor(room: room),
                                            mode: hvacModeBindingFor(room: room),
                                            room: room
                                        )
                                        .foregroundColor(.white)
                                        Spacer()
                                        
                                        HStack {
                                            Spacer()
                                            
                                            VStack {
                                                Text("Outdoor")
                                                    .foregroundColor(.white) // Adjust color as needed
                                                Button(action: {
                                                    print("Temp button tapped")
                                                }) {
                                                    HalcyonButtonView(text: viewModel.outdoorTemperature, outerButtonSize: 100)
                                                }
                                            }
                                            
                                            Spacer()
                                            
                                            VStack {
                                                Text("Indoor")
                                                    .foregroundColor(.white) // Adjust color as needed
                                                Button(action: {
                                          //          viewModel.fetchSensorStates()
                                                }) {
                                                    HalcyonButtonView(text: viewModel.indoorTemperature, outerButtonSize: 100)
                                                }
                                            }
                                            
                                            Spacer()
                                        }
                                        .padding(.bottom, 70)
                                    }
                                }
                                .tag(room)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle())
                        .frame(width: geometry.size.width)
                    }
                }
                
                .navigationTitle(selectedRoom.rawValue)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: Button(action: {
                    showingSettings = true
                }) {
                    Image(systemName: "gear")
                        .foregroundColor(.white)
                        .font(.title)
                })
                .sheet(isPresented: $showingSettings) {
                    OtherView(selectedRoom: $selectedRoom)
                        .presentationDetents([.fraction(0.6)])
                }
                .applyBackground()
                
                .onAppear {
                    if !viewModel.hasFetchedInitialStates {
                        viewModel.fetchAndSetInitialStates()
                    }
                    viewModel.fetchSensorStates()
                }
            }
        }
    }
    
    private func tempBindingFor(room: Room) -> Binding<Double> {
        Binding(
            get: {
                viewModel.roomStates[room]?.temperature ?? 30
            },
            set: {
                viewModel.roomStates[room]?.temperature = $0
                viewModel.refreshUIAfterStateUpdate()
            }
        )
    }
    
    private func hvacModeBindingFor(room: Room) -> Binding<HvacModes> {
        Binding(
            get: {
                viewModel.roomStates[room]?.mode ?? .off
            },
            set: {
                viewModel.roomStates[room]?.mode = $0
                viewModel.refreshUIAfterStateUpdate()
            }
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(HalcyonViewModel())
    }
}
