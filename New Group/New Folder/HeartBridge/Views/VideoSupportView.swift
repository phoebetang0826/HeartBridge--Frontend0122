//
//  VideoSupportView.swift
//  HeartBridge
//
//  Created by Phoebe Tang on 1/21/26.
//

import SwiftUI
import PhotosUI
import AVFoundation

enum VideoSupportViewState {
    case main
    case processing
    case report
}

struct VideoSupportView: View {
    let childName: String?
    let onUpdatePoints: ((Int) -> Void)?
    let onConsult: () -> Void
    
    @State private var viewState: VideoSupportViewState = .main
    @State private var analysisReport: BehaviorReport? = nil
    @State private var selectedVideoItem: PhotosPickerItem? = nil
    @State private var isRecording = false
    
    var body: some View {
        Group {
            switch viewState {
            case .processing:
                processingView
            case .report:
                if let report = analysisReport {
                    reportView(report)
                } else {
                    mainView
                }
            default:
                mainView
            }
        }
        .onChange(of: selectedVideoItem) { oldValue, newValue in
            if let newValue = newValue {
                handleFileUpload(item: newValue)
            }
        }
    }
    
    // MARK: - Main View
    
    private var mainView: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header spacing
                Color.clear
                    .frame(height: 112)
                
                // Title section
                titleSection
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                
                // Action buttons
                actionButtonsSection
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                
                // Real-time help card
                realTimeHelpCard
                    .padding(.horizontal, 24)
                    .padding(.bottom, 100)
            }
        }
        .background(Color.gray.opacity(0.05))
    }
    
    private var titleSection: some View {
        VStack(spacing: 8) {
            Text("Video Support")
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundColor(.primary.opacity(0.4))
                .textCase(.uppercase)
                .tracking(2)
            
            Text("Capture behaviors. Get clinical clarity.")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.gray)
        }
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 16) {
            // Record button
            recordButton
            
            // Upload button
            uploadButton
        }
    }
    
    private var recordButton: some View {
        Button(action: {
            // TODO: Implement video recording
            // For now, trigger file picker
            selectedVideoItem = nil
        }) {
            VStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.primary.opacity(0.1))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "video.fill")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.primary)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                Text("Record Interaction")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundColor(.primary.opacity(0.9))
                
                Text("Record live video for analysis")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.gray)
                    .textCase(.uppercase)
                    .tracking(2)
                    .opacity(0.6)
            }
            .frame(maxWidth: .infinity)
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 40)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 40)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private var uploadButton: some View {
        PhotosPicker(selection: $selectedVideoItem, matching: .videos) {
            VStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.primary.opacity(0.1))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.primary)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                Text("Upload Video")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundColor(.primary.opacity(0.9))
                
                Text("Choose a file from your device")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.gray)
                    .textCase(.uppercase)
                    .tracking(2)
                    .opacity(0.6)
            }
            .frame(maxWidth: .infinity)
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 40)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 40)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private var realTimeHelpCard: some View {
        VStack(spacing: 24) {
            Text("Need real-time help?")
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundColor(.white)
            
            Text("We connect you with a real therapist for instant clinical guidance and support.")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            
            Button(action: onConsult) {
                Text("Contact Therapist")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundColor(.primary)
                    .textCase(.uppercase)
                    .tracking(2)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                    )
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 44)
                .fill(Color.primary)
                .shadow(color: .primary.opacity(0.3), radius: 20, x: 0, y: 10)
        )
    }
    
    // MARK: - Processing View
    
    private var processingView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.primary.opacity(0.1))
                    .frame(width: 96, height: 96)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color.primary, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .rotationEffect(.degrees(360))
                    .animation(
                        Animation.linear(duration: 1.5).repeatForever(autoreverses: false),
                        value: UUID()
                    )
                
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            VStack(spacing: 8) {
                Text("AI Analysis in Progress...")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(.primary.opacity(0.9))
                    .tracking(-0.5)
                
                Text("Our behavioral model is decoding \(childName ?? "your child")'s signals.")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.gray)
                    .opacity(0.8)
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.primary)
                        .frame(width: geometry.size.width * 0.4, height: 6)
                        .animation(
                            Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                            value: UUID()
                        )
                }
            }
            .frame(width: 200, height: 6)
            
            Spacer()
        }
        .padding(32)
        .background(Color.white)
    }
    
    // MARK: - Report View
    
    private func reportView(_ report: BehaviorReport) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                reportHeader
                    .padding(.horizontal, 24)
                    .padding(.top, 112)
                    .padding(.bottom, 32)
                
                // Content
                VStack(spacing: 24) {
                    // Summary card
                    summaryCard(report)
                    
                    // Support steps
                    supportStepsCard(report)
                    
                    // Expert consultation
                    expertConsultationCard
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 100)
            }
        }
        .background(Color.white)
    }
    
    private var reportHeader: some View {
        HStack {
            Button(action: { viewState = .main }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.gray)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.1))
                    )
            }
            .buttonStyle(ScaleButtonStyle())
            
            Spacer()
            
            Text("AI Behavioral Insight")
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundColor(.primary.opacity(0.9))
                .tracking(-0.5)
            
            Spacer()
            
            Color.clear
                .frame(width: 44, height: 44)
        }
    }
    
    private func summaryCard(_ report: BehaviorReport) -> some View {
        VStack(spacing: 32) {
            Text(report.summaryTitle)
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundColor(.primary.opacity(0.9))
                .multilineTextAlignment(.center)
            
            // Emotion bars
            HStack(spacing: 8) {
                emotionBar(label: "happy", value: report.emotions.happy, color: .green)
                emotionBar(label: "neutral", value: report.emotions.neutral, color: .blue)
                emotionBar(label: "angry", value: report.emotions.angry, color: .red)
                emotionBar(label: "sad", value: report.emotions.sad, color: .purple)
                emotionBar(label: "nervous", value: report.emotions.nervous, color: .orange)
            }
            
            Text(report.correlation)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 44)
                .fill(Color.gray.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 44)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private func emotionBar(label: String, value: Int, color: Color) -> some View {
        VStack(spacing: 8) {
            GeometryReader { geometry in
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(height: geometry.size.height * CGFloat(value) / 100)
                        .animation(.easeOut(duration: 1.0), value: value)
                }
            }
            .frame(width: 16, height: 96)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.white, lineWidth: 4)
            )
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            Text(label)
                .font(.system(size: 8, weight: .black, design: .rounded))
                .foregroundColor(.gray)
                .textCase(.uppercase)
                .tracking(-0.5)
            
            Text("\(value)%")
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundColor(.gray)
        }
    }
    
    private func supportStepsCard(_ report: BehaviorReport) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Immediate Support Steps")
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundColor(.gray)
                .textCase(.uppercase)
                .tracking(2)
            
            VStack(spacing: 16) {
                ForEach(Array(report.whatToDo.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 16) {
                        Text("\(index + 1)")
                            .font(.system(size: 11, weight: .black, design: .rounded))
                            .foregroundColor(.primary)
                            .frame(width: 28, height: 28)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.primary.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                                    )
                            )
                        
                        Text(step)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.gray)
                            .lineSpacing(4)
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
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var expertConsultationCard: some View {
        VStack(spacing: 24) {
            HStack(spacing: 16) {
                AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=200&h=200&auto=format&fit=crop")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white, lineWidth: 4)
                )
                .overlay(alignment: .topTrailing) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.green)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white)
                        )
                        .offset(x: 4, y: -4)
                }
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Instant Consultation")
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundColor(.primary.opacity(0.9))
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                            .opacity(0.8)
                        
                        Text("Specialist is online")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Button(action: onConsult) {
                HStack(spacing: 12) {
                    Image(systemName: "message.fill")
                        .font(.system(size: 16, weight: .bold))
                    
                    Text("Discuss this Report")
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .textCase(.uppercase)
                        .tracking(2)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.primary)
                        .shadow(color: .primary.opacity(0.5), radius: 20, x: 0, y: 10)
                )
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 44)
                .fill(Color.primary.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 44)
                        .stroke(Color.primary.opacity(0.2), lineWidth: 2)
                )
                .shadow(color: .primary.opacity(0.1), radius: 20, x: 0, y: 10)
        )
    }
    
    // MARK: - Actions
    
    private func handleFileUpload(item: PhotosPickerItem) {
        viewState = .processing
        
        Task {
            do {
                guard let data = try await item.loadTransferable(type: Data.self) else {
                    await MainActor.run {
                        viewState = .main
                    }
                    return
                }
                
                let base64 = data.base64EncodedString()
                let mimeType = "video/mp4" // Default, could be determined from item
                
                let report = try await analyzeMedia(base64, mimeType)
                
                await MainActor.run {
                    analysisReport = report
                    onUpdatePoints?(50)
                    viewState = .report
                }
            } catch {
                await MainActor.run {
                    viewState = .main
                    // TODO: Show error alert
                }
            }
        }
    }
}

#Preview {
    VideoSupportView(
        childName: "Andy",
        onUpdatePoints: nil,
        onConsult: {}
    )
}
