//
//  StatusCircle.swift
//  HeartBridge
//
//  Created by Phoebe Tang on 1/21/26.
//

import SwiftUI

struct StatusCircle: View {
    let label: String
    let value: Int
    let color: Color
    let bgColor: Color
    var inverse: Bool = false
    var isLocked: Bool = false
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 32)
                    .fill(bgColor)
                    .frame(width: 96, height: 96)
                    .overlay(
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(Color.white, lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                
                // Progress ring
                Circle()
                    .trim(from: 0, to: isLocked ? 0.05 : CGFloat(value) / 100)
                    .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .opacity(0.3)
                    .frame(width: 88, height: 88)
                
                Circle()
                    .trim(from: 0, to: isLocked ? 0.05 : CGFloat(value) / 100)
                    .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 88, height: 88)
                    .animation(.easeOut(duration: 1.0), value: value)
                
                // Value text
                if isLocked {
                    Text("--")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundColor(.gray)
                        .opacity(0.6)
                        .tracking(-1)
                } else {
                    Text("\(value)%")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(color)
                        .tracking(-1)
                }
            }
            
            VStack(spacing: 4) {
                Text(label)
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .foregroundColor(.primary.opacity(0.9))
                    .textCase(.uppercase)
                    .tracking(2)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(height: 24)
                
                Text(isLocked ? "Locked" : "Active")
                    .font(.system(size: 8, weight: .black, design: .rounded))
                    .foregroundColor(isLocked ? .gray : .green)
                    .textCase(.uppercase)
                    .tracking(2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(isLocked ? Color.gray.opacity(0.1) : Color.green.opacity(0.1))
                    )
            }
        }
    }
}

#Preview {
    HStack {
        StatusCircle(
            label: "Sleep",
            value: 88,
            color: .blue,
            bgColor: .blue.opacity(0.1),
            isLocked: false
        )
        
        StatusCircle(
            label: "Meltdown Opp.",
            value: 12,
            color: .orange,
            bgColor: .orange.opacity(0.1),
            inverse: true,
            isLocked: true
        )
    }
    .padding()
}

