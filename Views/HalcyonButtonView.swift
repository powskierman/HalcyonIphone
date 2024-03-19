//
//  HalcyonButtonView.swift
//  HalcyonIphone
//
//  Created by Michel Lapointe on 2024-03-17.
//

import SwiftUI

struct HalcyonButtonView: View {
    var text: String
    var outerButtonSize: CGFloat
    
    private var innerButtonSize: CGFloat {
        outerButtonSize * 0.80 // Adjust as needed
    }

    var body: some View {
        ZStack {
            // Outer Button
            Circle()
                .fill(
                    LinearGradient(colors: [Color("Outer Dial 1"), Color("Outer Dial 2")],
                                   startPoint: .leading,
                                   endPoint: .trailing))
                .frame(width: outerButtonSize, height: outerButtonSize)
                .shadow(color: .black.opacity(0.2), radius: 60, x: 0, y: 30)
                .shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: 8)
                .overlay {
                    Circle()
                        .stroke(LinearGradient(colors: [.white.opacity(0.2), .black.opacity(0.19)],
                                               startPoint: .leading,
                                               endPoint: .trailing), lineWidth: 1)
                }
                .overlay {
                    Circle()
                        .stroke(.white.opacity(0.1), lineWidth: 4)
                        .blur(radius: 8)
                        .offset(x: 3, y: 3)
                        .mask {
                            Circle()
                                .fill(LinearGradient(colors: [.black, .clear],
                                                     startPoint: .leading,
                                                     endPoint: .trailing))
                        }
                }

            // Inner Button
            Circle()
                .fill(LinearGradient(colors: [Color("Inner Dial 1"), Color("Inner Dial 2")],
                                     startPoint: .leading,
                                     endPoint: .trailing))
                .frame(width: innerButtonSize, height: innerButtonSize)
            
            // Button Text
            Text(text)
                .foregroundColor(.white)
                .bold()
        }
    }
}

struct CustomButtonView_Previews: PreviewProvider {
    static var previews: some View {
        HalcyonButtonView(text: "Temp", outerButtonSize: 100)
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color("Background"))
    }
}

