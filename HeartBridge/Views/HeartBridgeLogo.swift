//
//  HeartBridgeLogo.swift
//  HeartBridge
//
//  Created by Phoebe Tang on 1/21/26.
//

import SwiftUI

enum LogoVariant {
    case bubble
    case icon
}

struct HeartBridgeLogo: View {
    var size: CGFloat = 32
    var animated: Bool = false
    var variant: LogoVariant = .bubble
    
    var body: some View {
        ZStack {
            if animated {
                Circle()
                    .fill(Color.primary.opacity(0.2))
                    .frame(width: size, height: size)
                    .opacity(0.1)
                    .scaleEffect(1.2)
                    .animation(
                        Animation.easeInOut(duration: 2.0)
                            .repeatForever(autoreverses: true),
                        value: UUID()
                    )
            }
            
            // SVG-like heart shape
            GeometryReader { geometry in
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    let centerX = width / 2
                    
                    if variant == .bubble {
                        // Bubble variant path
                        path.move(to: CGPoint(x: centerX, y: height * 0.96))
                        path.addCurve(
                            to: CGPoint(x: width * 0.9, y: height * 0.75),
                            control1: CGPoint(x: width * 0.9, y: height * 0.85),
                            control2: CGPoint(x: width * 0.95, y: height * 0.8)
                        )
                        path.addCurve(
                            to: CGPoint(x: width, y: height * 0.38),
                            control1: CGPoint(x: width, y: height * 0.58),
                            control2: CGPoint(x: width, y: height * 0.48)
                        )
                        path.addCurve(
                            to: CGPoint(x: width * 0.65, y: height * 0.2),
                            control1: CGPoint(x: width, y: height * 0.15),
                            control2: CGPoint(x: width * 0.8, y: height * 0.1)
                        )
                        path.addQuadCurve(
                            to: CGPoint(x: centerX, y: height * 0.32),
                            control: CGPoint(x: width * 0.5, y: height * 0.25)
                        )
                        path.addQuadCurve(
                            to: CGPoint(x: width * 0.35, y: height * 0.2),
                            control: CGPoint(x: centerX, y: height * 0.25)
                        )
                        path.addCurve(
                            to: CGPoint(x: 0, y: height * 0.38),
                            control1: CGPoint(x: width * 0.2, y: height * 0.1),
                            control2: CGPoint(x: 0, y: height * 0.15)
                        )
                        path.addCurve(
                            to: CGPoint(x: width * 0.1, y: height * 0.75),
                            control1: CGPoint(x: 0, y: height * 0.58),
                            control2: CGPoint(x: 0, y: height * 0.65)
                        )
                        path.addCurve(
                            to: CGPoint(x: width * 0.2, y: height * 0.85),
                            control1: CGPoint(x: width * 0.05, y: height * 0.8),
                            control2: CGPoint(x: width * 0.1, y: height * 0.82)
                        )
                        path.addLine(to: CGPoint(x: width * 0.08, y: height))
                        path.addLine(to: CGPoint(x: width * 0.4, y: height * 0.92))
                        path.addQuadCurve(
                            to: CGPoint(x: centerX, y: height * 0.96),
                            control: CGPoint(x: width * 0.45, y: height * 0.96)
                        )
                    } else {
                        // Icon variant (simpler heart)
                        path.move(to: CGPoint(x: centerX, y: height * 0.96))
                        path.addCurve(
                            to: CGPoint(x: width * 0.9, y: height * 0.75),
                            control1: CGPoint(x: width * 0.9, y: height * 0.85),
                            control2: CGPoint(x: width * 0.95, y: height * 0.8)
                        )
                        path.addCurve(
                            to: CGPoint(x: width, y: height * 0.38),
                            control1: CGPoint(x: width, y: height * 0.58),
                            control2: CGPoint(x: width, y: height * 0.48)
                        )
                        path.addCurve(
                            to: CGPoint(x: width * 0.65, y: height * 0.2),
                            control1: CGPoint(x: width, y: height * 0.15),
                            control2: CGPoint(x: width * 0.8, y: height * 0.1)
                        )
                        path.addQuadCurve(
                            to: CGPoint(x: centerX, y: height * 0.32),
                            control: CGPoint(x: width * 0.5, y: height * 0.25)
                        )
                        path.addQuadCurve(
                            to: CGPoint(x: width * 0.35, y: height * 0.2),
                            control: CGPoint(x: centerX, y: height * 0.25)
                        )
                        path.addCurve(
                            to: CGPoint(x: 0, y: height * 0.38),
                            control1: CGPoint(x: width * 0.2, y: height * 0.1),
                            control2: CGPoint(x: 0, y: height * 0.15)
                        )
                        path.addCurve(
                            to: CGPoint(x: width * 0.1, y: height * 0.75),
                            control1: CGPoint(x: 0, y: height * 0.58),
                            control2: CGPoint(x: 0, y: height * 0.65)
                        )
                        path.addCurve(
                            to: CGPoint(x: centerX, y: height * 0.96),
                            control1: CGPoint(x: width * 0.2, y: height * 0.85),
                            control2: CGPoint(x: width * 0.4, y: height * 0.9)
                        )
                    }
                }
                .fill(Color(red: 0.45, green: 0.65, blue: 0.88)) // #74A7E0
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                // Face elements
                Group {
                    // Smile (yellow arc)
                    Path { path in
                        let centerX = geometry.size.width / 2
                        let y = geometry.size.height * 0.38
                        path.move(to: CGPoint(x: geometry.size.width * 0.36, y: y))
                        path.addQuadCurve(
                            to: CGPoint(x: geometry.size.width * 0.64, y: y),
                            control: CGPoint(x: centerX, y: geometry.size.height * 0.28)
                        )
                    }
                    .stroke(Color(red: 0.91, green: 0.77, blue: 0.42), lineWidth: 3) // #E9C46A
                    
                    // Smile (white arc)
                    Path { path in
                        let centerX = geometry.size.width / 2
                        let y = geometry.size.height * 0.46
                        path.move(to: CGPoint(x: geometry.size.width * 0.32, y: y))
                        path.addQuadCurve(
                            to: CGPoint(x: geometry.size.width * 0.68, y: y),
                            control: CGPoint(x: centerX, y: geometry.size.height * 0.32)
                        )
                    }
                    .stroke(Color.white, lineWidth: 3.2)
                    
                    // Teeth
                    ForEach([0.41, 0.47, 0.53, 0.59], id: \.self) { xRatio in
                        Path { path in
                            let x = geometry.size.width * xRatio
                            let y1 = geometry.size.height * 0.36
                            let y2 = geometry.size.height * 0.40
                            path.move(to: CGPoint(x: x, y: y1))
                            path.addLine(to: CGPoint(x: x, y: y2))
                        }
                        .stroke(Color.white, lineWidth: 2)
                    }
                    
                    // Eyes
                    Circle()
                        .fill(Color.white)
                        .frame(width: geometry.size.width * 0.06, height: geometry.size.width * 0.06)
                        .offset(x: geometry.size.width * -0.07, y: geometry.size.height * 0.08)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: geometry.size.width * 0.06, height: geometry.size.width * 0.06)
                        .offset(x: geometry.size.width * 0.07, y: geometry.size.height * 0.08)
                    
                    // Bottom smile
                    Path { path in
                        let centerX = geometry.size.width / 2
                        let y = geometry.size.height * 0.67
                        path.move(to: CGPoint(x: geometry.size.width * 0.36, y: y))
                        path.addQuadCurve(
                            to: CGPoint(x: geometry.size.width * 0.64, y: y),
                            control: CGPoint(x: centerX, y: geometry.size.height * 0.84)
                        )
                    }
                    .stroke(Color.white, lineWidth: 4.5)
                }
            }
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    VStack(spacing: 20) {
        HeartBridgeLogo(size: 48, animated: false, variant: .bubble)
        HeartBridgeLogo(size: 64, animated: true, variant: .bubble)
        HeartBridgeLogo(size: 32, animated: false, variant: .icon)
    }
    .padding()
}
