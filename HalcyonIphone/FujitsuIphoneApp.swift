//
//  FujitsuIphoneApp.swift
//  FujitsuIphone
//
//  Created by Michel Lapointe on 2024-03-02.
//

import SwiftUI

@main
struct FujitsuIphoneApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(ClimateViewModel())
        }
    }
}
