//
//  WhoopCircle.swift
//  HeartBridge
//
//  Created by Phoebe Tang on 1/21/26.
//

import SwiftUI

struct WhoopCircle: View {
    let label: String?
    let value: Int
    let color: Color
    let bgColor: Color
    let comparison: Comparison?
    
    struct Comparison {
        let delta: Int
        let improved: Bool
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                // Background circle
                Circle()
                    .fill(bgColor)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                
                // Progress ring
                Circle()
                    .trim(from: 0, to: CGFloat(value) / 100)
                    .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .opacity(0.3)
                
                Circle()
                    .trim(from: 0, to: CGFloat(value) / 100)
                    .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
                // Value text
                Text("\(value)%")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(color)
            }
            .frame(width: 96, height: 96)
            
            VStack(spacing: 4) {
                if let label = label {
                    Text(label)
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundColor(.primary.opacity(0.8))
                        .textCase(.uppercase)
                        .tracking(2)
                }
                
                if let comparison = comparison {
                    HStack(spacing: 2) {
                        Image(systemName: comparison.improved ? "arrow.up" : "arrow.down")
                            .font(.system(size: 12, weight: .black))
                            .foregroundColor(comparison.improved ? .green : .red)
                        
                        Text("\(abs(comparison.delta))%")
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .foregroundColor(comparison.improved ? .green : .red)
                            .textCase(.uppercase)
                    }
                }
            }
            .frame(minHeight: 40)
        }
    }
}

#Preview {
    HStack {
        WhoopCircle(
            label: "Sleep",
            value: 88,
            color: .blue,
            bgColor: .blue.opacity(0.1),
            comparison: WhoopCircle.Comparison(delta: 12, improved: true)
        )
        
        WhoopCircle(
            label: "Meltdown",
            value: 12,
            color: .orange,
            bgColor: .orange.opacity(0.1),
            comparison: WhoopCircle.Comparison(delta: 5, improved: true)
        )
    }
    .padding()
}



