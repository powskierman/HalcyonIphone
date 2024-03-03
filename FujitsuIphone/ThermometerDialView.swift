import SwiftUI

struct ThermometerDialView: View {
    var outerDialSize: CGFloat
    var degrees: CGFloat

    // Calculating innerDialSize and setpointSize based on outerDialSize to maintain proportions
    private var innerDialSize: CGFloat {
        outerDialSize * 0.80 // Adjust the multiplier based on your design preference
    }
    private var setpointSize: CGFloat {
        outerDialSize * 0.2 // Adjust the multiplier based on your design preference
    }

    var body: some View {
        ZStack {
            // Outer Dial
            Circle()
                .fill(
                    LinearGradient(colors: [Color("Outer Dial 1"), Color("Outer Dial 2")],
                                   startPoint: .leading,
                                   endPoint: .trailing))
                .frame(width: outerDialSize, height: outerDialSize)
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
            
            // Inner Dial
            Circle()
                .fill(LinearGradient(colors: [Color("Inner Dial 1"), Color("Inner Dial 2")],
                                     startPoint: .leading,
                                     endPoint: .trailing))
                .frame(width: innerDialSize, height: innerDialSize)
        }
    }
}

struct ThermometerDialView_Previews: PreviewProvider {
    static var previews: some View {
        // Example usage with a dynamic outerDialSize and degrees
        ThermometerDialView(outerDialSize: 180, degrees: 0)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("Background"))
    }
}
