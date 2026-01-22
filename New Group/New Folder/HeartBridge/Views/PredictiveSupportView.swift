//
//  PredictiveSupportView.swift
//  HeartBridge
//
//  Created by Phoebe Tang on 1/21/26.
//

import SwiftUI
import PhotosUI

struct PredictiveSupportView: View {
    let childName: String?
    let tier: SubscriptionTier
    let onUpgrade: (() -> Void)?
    
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    
    init(childName: String?, tier: SubscriptionTier, onUpgrade: (() -> Void)? = nil) {
        self.childName = childName
        self.tier = tier
        self.onUpgrade = onUpgrade
    }
    
    private var isFree: Bool {
        tier == .free
    }
    
    private var currentMetrics: (sleep: Int, meltdown: Int, selfInjury: Int) {
        if isFree {
            return (0, 0, 0)
        }
        return (88, 12, 5)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header spacing
                Color.clear
                    .frame(height: 112)
                
                // Predictive Health Score
                metricsSection
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                
                // Upgrade card (Free tier only)
                if isFree {
                    upgradeCard
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                }
                
                // Manual Analysis (Free tier only)
                if isFree {
                    manualAnalysisSection
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)
                }
                
                // Success/Active View (Subscribed)
                if !isFree {
                    successCard
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)
                }
                
                // Daily Clinical Tips
                dailyTipsSection
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                
                // Weekly Stability Trends
                weeklyTrendsSection
                    .padding(.horizontal, 24)
                    .padding(.bottom, 100)
            }
        }
        .background(Color.gray.opacity(0.05))
        .photosPicker(
            isPresented: .constant(false),
            selection: $selectedPhotoItem,
            matching: .videos
        )
    }
    
    // MARK: - Metrics Section
    
    private var metricsSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Text("Predictive Health Score")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundColor(.gray)
                    .textCase(.uppercase)
                    .tracking(2)
                
                Spacer()
                
                if isFree {
                    HStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Wearable Required")
                            .font(.system(size: 9, weight: .black, design: .rounded))
                            .foregroundColor(.primary)
                            .textCase(.uppercase)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(Color.primary.opacity(0.1))
                    )
                }
            }
            
            HStack(spacing: 12) {
                StatusCircle(
                    label: "Sleep",
                    value: currentMetrics.sleep,
                    color: .blue,
                    bgColor: .blue.opacity(0.1),
                    isLocked: isFree
                )
                
                StatusCircle(
                    label: "Meltdown Opp.",
                    value: currentMetrics.meltdown,
                    color: .orange,
                    bgColor: .orange.opacity(0.1),
                    inverse: true,
                    isLocked: isFree
                )
                
                StatusCircle(
                    label: "Self-Injury Opp.",
                    value: currentMetrics.selfInjury,
                    color: .red,
                    bgColor: .red.opacity(0.1),
                    inverse: true,
                    isLocked: isFree
                )
            }
        }
    }
    
    // MARK: - Upgrade Card
    
    private var upgradeCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Text("90% Prediction Accuracy")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .textCase(.uppercase)
                    .tracking(2)
            }
            
            Text("Get Accurate Predictions with a Free Wearable ⌚️")
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .tracking(-1)
                .lineSpacing(4)
            
            Text("Subscribe to Core for $29/mo. We'll send you our clinical-grade wearable for free to track \(childName ?? "your child")'s data automatically.")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(4)
            
            Button(action: {
                onUpgrade?()
            }) {
                Text("Subscribe to Core · $29/mo")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundColor(.primary)
                    .textCase(.uppercase)
                    .tracking(2)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    )
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(32)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 44)
                    .fill(Color.primary)
                    .shadow(color: .primary.opacity(0.3), radius: 20, x: 0, y: 10)
                
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 128, height: 128)
                    .blur(radius: 40)
                    .offset(x: 100, y: -100)
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 44)
                .stroke(Color.white, lineWidth: 4)
        )
    }
    
    // MARK: - Manual Analysis Section
    
    private var manualAnalysisSection: some View {
        VStack(spacing: 24) {
            VStack(spacing: 4) {
                Text("Not ready to pay?")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundColor(.primary.opacity(0.9))
                
                Text("You can still analyze behavior by manually uploading a video.")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.gray)
                    .textCase(.uppercase)
                    .tracking(2)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
            
            HStack(spacing: 12) {
                Button(action: {
                    // TODO: Implement video recording
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "video.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.gray)
                        
                        Text("Record Manually")
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .foregroundColor(.gray)
                            .textCase(.uppercase)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(ScaleButtonStyle())
                
                PhotosPicker(selection: $selectedPhotoItem, matching: .videos) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.gray)
                        
                        Text("Upload Video")
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .foregroundColor(.gray)
                            .textCase(.uppercase)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 44)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 44)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Success Card
    
    private var successCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
                
                Text("Wearable: Connected")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundColor(.gray)
                    .textCase(.uppercase)
                    .tracking(2)
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("Regulation Score:")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(.primary.opacity(0.9))
                
                Text("HIGH")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(.green)
                
                Text("✨")
                    .font(.system(size: 20))
            }
            
            Text("\(childName ?? "Child") is displaying stable signals today.")
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundColor(.primary.opacity(0.9))
                .lineSpacing(4)
        }
        .padding(32)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 44)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                
                HeartBridgeLogo(size: 160, animated: false)
                    .opacity(0.1)
                    .offset(x: 100, y: -100)
                    .rotationEffect(.degrees(12))
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 44)
                .stroke(Color.white, lineWidth: 1)
        )
    }
    
    // MARK: - Daily Tips Section
    
    private var dailyTipsSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(spacing: 8) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(isFree ? .gray : .white)
                
                Text("Daily Clinical Tips")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundColor(isFree ? .gray : .white.opacity(0.7))
                    .textCase(.uppercase)
                    .tracking(2)
            }
            
            HStack(alignment: .top, spacing: 16) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isFree ? Color.gray.opacity(0.2) : Color.white.opacity(0.2))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(isFree ? .gray : .white)
                    )
                
                Text(isFree ? "Personalized intervention tips are locked." : "Consistent routines between 4-6 PM will help stabilize the evening transition.")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(isFree ? .gray.opacity(0.7) : .white)
                    .lineSpacing(4)
            }
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 44)
                .fill(isFree ? Color.gray.opacity(0.1) : Color.primary)
                .shadow(color: isFree ? Color.clear : Color.primary.opacity(0.3), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 44)
                .stroke(isFree ? Color.gray.opacity(0.2) : Color.clear, lineWidth: 1)
        )
        .opacity(isFree ? 0.6 : 1.0)
    }
    
    // MARK: - Weekly Trends Section
    
    private var weeklyTrendsSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Weekly Stability Trends")
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundColor(.gray)
                .textCase(.uppercase)
                .tracking(2)
            
            HStack(spacing: 8) {
                ForEach(Array(["M", "T", "W", "T", "F", "S", "S"].enumerated()), id: \.offset) { index, day in
                    VStack(spacing: 8) {
                        GeometryReader { geometry in
                            ZStack(alignment: .bottom) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gray.opacity(0.1))
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.primary)
                                    .frame(height: geometry.size.height * (isFree ? 0.1 : CGFloat([30, 60, 40, 80, 50, 20, 70][index]) / 100))
                                    .animation(.easeOut(duration: 1.0), value: isFree)
                            }
                        }
                        .frame(height: 96)
                        
                        Text(day)
                            .font(.system(size: 9, weight: .black, design: .rounded))
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 44)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 44)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
        .opacity(isFree ? 0.3 : 1.0)
    }
}

#Preview {
    VStack {
        PredictiveSupportView(childName: "Andy", tier: .free, onUpgrade: {})
        
        Divider()
        
        PredictiveSupportView(childName: "Andy", tier: .core, onUpgrade: {})
    }
}
