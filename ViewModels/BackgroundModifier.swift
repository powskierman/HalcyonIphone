//
//  BackgroundModifier.swift
//  HalcyonIphone
//
//  Created by Michel Lapointe on 2024-03-17.
//

import SwiftUI

// Define a custom view modifier for the background
struct BackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color("Background").ignoresSafeArea())
    }
}

// Extend View to include a convenience method to apply the background
extension View {
    func applyBackground() -> some View {
        self.modifier(BackgroundModifier())
    }
}
