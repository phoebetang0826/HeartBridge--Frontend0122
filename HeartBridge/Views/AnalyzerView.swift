//
//  AnalyzerView.swift
//  HeartBridge
//
//  Created by Phoebe Tang on 1/21/26.
//

import SwiftUI
import PhotosUI

enum AnalyzerViewState {
    case dashboard
    case record
    case report
    case processing
    case calendar
    case expertChat
    case metricDetail
}

enum MetricType: String {
    case sleep = "sleep"
    case meltdown = "meltdown"
    case aggression = "aggression"
}

struct AnalyzerView: View {
    let onNavigate: ((AppTab, String?) -> Void)?
    let childName: String
    let onUpdatePoints: ((Int) -> Void)?
    
    @State private var viewState: AnalyzerViewState = .dashboard
    @State private var activeMetric: MetricType? = nil
    @State private var selectedDay: String = "Today"
    @State private var analysisReport: BehaviorReport? = nil
    @State private var chatMessages: [ChatMessage] = []
    @State private var isTyping: Bool = false
    @State private var chatInput: String = ""
    @State private var lastUploadedMedia: (data: String, mimeType: String)? = nil
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    
    private var currentMetrics: Metrics {
        getMetricsForDay(selectedDay)
    }
    
    var body: some View {
        Group {
            switch viewState {
            case .processing:
                processingView
            case .expertChat:
                expertChatView
            case .report:
                if let report = analysisReport {
                    reportView(report)
                } else {
                    dashboardView
                }
            case .calendar:
                calendarView
            case .metricDetail:
                if let metric = activeMetric {
                    metricDetailView(metric)
                } else {
                    dashboardView
                }
            default:
                dashboardView
            }
        }
        .photosPicker(
            isPresented: .constant(false),
            selection: $selectedPhotoItem,
            matching: .videos
        )
        .onChange(of: selectedPhotoItem) { oldValue, newValue in
            if let newValue = newValue {
                handleFileUpload(item: newValue)
            }
        }
    }
    
    // MARK: - Dashboard View
    
    private var dashboardView: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 24) {
                    Text("HeartBridge")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(.primary)
                        .tracking(-1)
                        .padding(.top, 48)
                    
                    // Date selector
                    dateSelectorView
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                
                // Metrics circles
                metricsCirclesView
                    .padding(.bottom, 40)
                
                // Status message
                statusMessageView
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                
                // Support steps
                supportStepsView
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                
                // Record/Upload section
                recordUploadSection
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                
                // Recommendation banner
                recommendationBanner
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                
                // Expert care section
                expertCareSection
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                
                // Parenting library
                parentingLibrarySection
                    .padding(.horizontal, 24)
                    .padding(.bottom, 100)
            }
        }
        .background(Color.gray.opacity(0.05))
    }
    
    private var dateSelectorView: some View {
        HStack(spacing: 16) {
            Button(action: {
                if selectedDay == "Today" {
                    selectedDay = "Yesterday"
                } else if selectedDay == "Tomorrow" {
                    selectedDay = "Today"
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    )
            }
            .buttonStyle(ScaleButtonStyle())
            
            Button(action: { viewState = .calendar }) {
                Text(selectedDay)
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundColor(.primary.opacity(0.9))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                            .overlay(
                                Capsule()
                                    .stroke(Color.primary.opacity(0.1), lineWidth: 2)
                            )
                    )
            }
            .buttonStyle(ScaleButtonStyle())
            
            Button(action: {
                if selectedDay == "Yesterday" {
                    selectedDay = "Today"
                } else if selectedDay == "Today" {
                    selectedDay = "Tomorrow"
                }
            }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    )
            }
            .buttonStyle(ScaleButtonStyle())
            
            Button(action: { viewState = .calendar }) {
                Image(systemName: "calendar")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    )
            }
            .buttonStyle(ScaleButtonStyle())
        }
    }
    
    private var metricsCirclesView: some View {
        HStack(spacing: 12) {
            Button(action: {
                activeMetric = .sleep
                viewState = .metricDetail
            }) {
                WhoopCircle(
                    label: "Sleep",
                    value: currentMetrics.sleep,
                    color: .blue,
                    bgColor: .blue.opacity(0.1),
                    comparison: getComparison(.sleep)
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: {
                activeMetric = .meltdown
                viewState = .metricDetail
            }) {
                WhoopCircle(
                    label: "Meltdown",
                    value: currentMetrics.meltdown,
                    color: .orange,
                    bgColor: .orange.opacity(0.1),
                    comparison: getComparison(.meltdown)
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: {
                activeMetric = .aggression
                viewState = .metricDetail
            }) {
                WhoopCircle(
                    label: "Aggression",
                    value: currentMetrics.aggression,
                    color: .red,
                    bgColor: .red.opacity(0.1),
                    comparison: getComparison(.aggression)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 24)
    }
    
    private var statusMessageView: some View {
        VStack(spacing: 0) {
            Text("\(childName) is doing great! Based on \(selectedDay)'s data, his consistency is \(Int.random(in: 70...90))%. ✨")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.primary.opacity(0.9))
                .multilineTextAlignment(.center)
                .lineLimit(3)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    private var supportStepsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Supporting \(childName) Today")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundColor(.primary.opacity(0.9))
                    .textCase(.uppercase)
                    .tracking(2)
            }
            
            VStack(spacing: 16) {
                supportStepItem(
                    number: 1,
                    text: currentMetrics.sleep < 60
                        ? "\(childName) might be tired. Stick to familiar, calming routines."
                        : "Good energy levels! Perfect day for a short community outing."
                )
                
                supportStepItem(
                    number: 2,
                    text: currentMetrics.meltdown > 40
                        ? "Prepare a visual schedule to reduce anxiety during transitions."
                        : "Reinforce positive social interaction with his favorite reward."
                )
            }
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 44)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    private func supportStepItem(number: Int, text: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Text("\(number)")
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundColor(.primary)
                .frame(width: 24, height: 24)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.primary.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                        )
                )
            
            Text(text)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.gray)
                .lineSpacing(4)
        }
    }
    
    private var recordUploadSection: some View {
        VStack(spacing: 32) {
            VStack(spacing: 12) {
                Text("Need Instant Help?")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundColor(.primary.opacity(0.9))
                
                Text("Record and we will connect you with expert for free.")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Rectangle()
                    .fill(Color.primary.opacity(0.2))
                    .frame(width: 48, height: 4)
                    .cornerRadius(2)
            }
            
            HStack(spacing: 16) {
                Button(action: {
                    // TODO: Implement video recording
                    viewState = .record
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "video.fill")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Record")
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .textCase(.uppercase)
                            .tracking(2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.primary)
                            .shadow(color: .primary.opacity(0.5), radius: 20, x: 0, y: 10)
                    )
                }
                .buttonStyle(ScaleButtonStyle())
                
                PhotosPicker(selection: $selectedPhotoItem, matching: .videos) {
                    VStack(spacing: 4) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Upload")
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .textCase(.uppercase)
                            .tracking(2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.primary)
                            .shadow(color: .primary.opacity(0.5), radius: 20, x: 0, y: 10)
                    )
                }
            }
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 44)
                .fill(Color.white)
                .shadow(color: .primary.opacity(0.1), radius: 20, x: 0, y: 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 44)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private var recommendationBanner: some View {
        HStack(spacing: 12) {
            HeartBridgeLogo(size: 40, animated: false)
                .frame(width: 44, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
            
            Text("80% users recommend these resources")
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundColor(.primary.opacity(0.8))
                .textCase(.uppercase)
                .tracking(1)
        }
        .padding(8)
    }
    
    private var expertCareSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Text("Expert Care")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundColor(.gray)
                    .textCase(.uppercase)
                    .tracking(2)
                
                Spacer()
                
                Button("View all") {
                    // TODO: Navigate to experts list
                }
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundColor(.primary)
                .textCase(.uppercase)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(recommendedExperts) { expert in
                        expertCard(expert)
                    }
                }
            }
        }
    }
    
    private func expertCard(_ expert: Expert) -> some View {
        HStack(spacing: 16) {
            AsyncImage(url: URL(string: expert.img)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: 48, height: 48)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 2)
            )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(expert.name)
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundColor(.primary.opacity(0.9))
                
                Text(expert.role)
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundColor(.primary)
                    .textCase(.uppercase)
                    .tracking(2)
            }
        }
        .padding(20)
        .frame(minWidth: 240)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    private var parentingLibrarySection: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Text("Parenting Library")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundColor(.gray)
                    .textCase(.uppercase)
                    .tracking(2)
                
                Spacer()
                
                Button("Browse") {
                    // TODO: Navigate to library
                }
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundColor(.primary)
                .textCase(.uppercase)
            }
            
            VStack(spacing: 16) {
                ForEach(recommendedVideos) { video in
                    videoCard(video)
                }
            }
        }
    }
    
    private func videoCard(_ video: Video) -> some View {
        HStack(spacing: 16) {
            AsyncImage(url: URL(string: video.img)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: 128)
            .aspectRatio(16/9, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                ZStack {
                    Color.black.opacity(0.1)
                    
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white.opacity(0.8))
                }
            )
            .overlay(alignment: .bottomTrailing) {
                Text(video.duration)
                    .font(.system(size: 8, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.6))
                    )
                    .padding(4)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(video.title)
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundColor(.primary.opacity(0.9))
                    .lineLimit(2)
                
                Text("Neuro-Training")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.gray)
                    .textCase(.uppercase)
                    .tracking(2)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
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
                
                Text("Our behavioral model is decoding \(childName)'s signals.")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.gray)
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
            VStack(spacing: 24) {
                // Header
                HStack {
                    Button(action: { viewState = .dashboard }) {
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
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 24)
                .padding(.top, 48)
                
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
                        .fill(Color.gray.opacity(0.2))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(height: geometry.size.height * CGFloat(value) / 100)
                }
            }
            .frame(width: 20, height: 96)
            
            Text(label)
                .font(.system(size: 8, weight: .black, design: .rounded))
                .foregroundColor(.gray)
                .textCase(.uppercase)
            
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
    }
    
    private var expertConsultationCard: some View {
        let expert = recommendedExperts[0]
        
        return VStack(spacing: 24) {
            HStack(spacing: 16) {
                AsyncImage(url: URL(string: expert.img)) { image in
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
                            Circle()
                                .fill(Color.white)
                        )
                        .offset(x: 4, y: -4)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Instant Consultation")
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundColor(.primary.opacity(0.9))
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                            .opacity(0.8)
                        
                        Text("\(expert.name) is online")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Button(action: startConsultation) {
                HStack(spacing: 8) {
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
    
    // MARK: - Expert Chat View
    
    private var expertChatView: some View {
        let expert = recommendedExperts[0]
        
        return VStack(spacing: 0) {
            // Header
            HStack(spacing: 12) {
                Button(action: { viewState = .report }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.gray)
                }
                .buttonStyle(ScaleButtonStyle())
                
                AsyncImage(url: URL(string: expert.img)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(
                    Circle()
                        .fill(Color.green)
                        .frame(width: 14, height: 14)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .offset(x: 16, y: 16)
                )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(expert.name)
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundColor(.primary.opacity(0.9))
                    
                    Text(expert.role)
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundColor(.primary)
                        .textCase(.uppercase)
                        .tracking(2)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .padding(.top, 48)
            .background(Color.white)
            
            Divider()
            
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(Array(chatMessages.enumerated()), id: \.offset) { index, message in
                            messageBubble(message, isUser: message.role == "user")
                                .id(index)
                        }
                        
                        if isTyping {
                            typingIndicator
                        }
                    }
                    .padding()
                }
                .onChange(of: chatMessages.count) { oldValue, newValue in
                    withAnimation {
                        proxy.scrollTo(newValue - 1, anchor: .bottom)
                    }
                }
            }
            
            Divider()
            
            // Input area
            VStack(spacing: 12) {
                // Prompt chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(["Is this behavior typical?", "How to prevent this?", "Sensory advice"], id: \.self) { chip in
                            Button(action: { chatInput = chip }) {
                                Text(chip)
                                    .font(.system(size: 10, weight: .black, design: .rounded))
                                    .foregroundColor(.gray)
                                    .textCase(.uppercase)
                                    .tracking(1)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(Color.gray.opacity(0.1))
                                            .overlay(
                                                Capsule()
                                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                            )
                                    )
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                HStack(spacing: 12) {
                    TextField("Ask a question...", text: $chatInput)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.gray.opacity(0.1))
                        )
                        .onSubmit {
                            handleSendMessage()
                        }
                    
                    Button(action: handleSendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(
                                Circle()
                                    .fill(Color.primary)
                                    .shadow(color: .primary.opacity(0.5), radius: 10, x: 0, y: 5)
                            )
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .disabled(chatInput.trimmingCharacters(in: .whitespaces).isEmpty || isTyping)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
            .background(Color.white)
        }
        .background(Color.gray.opacity(0.05))
    }
    
    private func messageBubble(_ message: ChatMessage, isUser: Bool) -> some View {
        HStack {
            if isUser {
                Spacer()
            }
            
            VStack(alignment: isUser ? .trailing : .leading, spacing: 8) {
                ForEach(Array(message.parts.enumerated()), id: \.offset) { index, part in
                    if let inlineData = part.inlineData {
                        // Video/image preview
                        AsyncImage(url: URL(string: "data:\(inlineData.mimeType);base64,\(inlineData.data)")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Color.gray.opacity(0.3)
                        }
                        .frame(width: 200, height: 112)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            ZStack {
                                Color.black.opacity(0.2)
                                
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        )
                    }
                    
                    if let text = part.text {
                        Text(text)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(isUser ? .white : .gray)
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(isUser ? Color.primary : Color.white)
                                    .shadow(color: isUser ? Color.primary.opacity(0.3) : Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                            )
                    }
                }
            }
            .frame(maxWidth: 300, alignment: isUser ? .trailing : .leading)
            
            if !isUser {
                Spacer()
            }
        }
    }
    
    private var typingIndicator: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.primary.opacity(0.4))
                        .frame(width: 6, height: 6)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                            value: UUID()
                        )
                }
                
                Text("Expert is typing")
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .foregroundColor(.gray)
                    .textCase(.uppercase)
                    .tracking(2)
                    .padding(.leading, 8)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
            )
            
            Spacer()
        }
    }
    
    // MARK: - Calendar View
    
    private var calendarView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    Button(action: { viewState = .dashboard }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                            .frame(width: 44, height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.primary.opacity(0.1))
                            )
                    }
                    .buttonStyle(ScaleButtonStyle())
                    
                    Spacer()
                    
                    Text("October 2024")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(.primary.opacity(0.9))
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 24)
                .padding(.top, 48)
                
                // Weekday headers
                HStack(spacing: 4) {
                    ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                        Text(day)
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .foregroundColor(.gray)
                            .textCase(.uppercase)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 24)
                
                // Calendar grid
                calendarGrid
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.gray.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 100)
            }
        }
        .background(Color.white)
    }
    
    // MARK: - Metric Detail View
    
    private func metricDetailView(_ metric: MetricType) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    Button(action: { viewState = .dashboard }) {
                        Image(systemName: "arrow.left")
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
                    
                    Text(metricTitle(metric))
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(.primary.opacity(0.9))
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 24)
                .padding(.top, 48)
                
                VStack(spacing: 24) {
                    if metric == .sleep {
                        sleepDetailView
                    } else {
                        behaviorDetailView(metric)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 100)
            }
        }
        .background(Color.white)
    }
    
    private var sleepDetailView: some View {
        VStack(spacing: 24) {
            // Sleep condition card
            VStack(alignment: .leading, spacing: 24) {
                Text("Sleep Condition")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
                    .textCase(.uppercase)
                    .tracking(2)
                
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("Restorative")
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("88%")
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundColor(.blue.opacity(0.8))
                }
                
                HStack(spacing: 16) {
                    metricBox(title: "HRV", value: "54", unit: "ms")
                    metricBox(title: "Avg Heart Rate", value: "62", unit: "bpm")
                }
            }
            .padding(32)
            .background(
                LinearGradient(
                    colors: [Color.blue, Color.indigo],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 44))
            .shadow(color: .blue.opacity(0.3), radius: 20, x: 0, y: 10)
            
            // Night wakings
            nightWakingsCard
            
            // Sleep complications
            sleepComplicationsCard
            
            // Sleep stages
            sleepStagesCard
            
            // Expert insight
            expertInsightCard
        }
    }
    
    private func metricBox(title: String, value: String, unit: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
                .textCase(.uppercase)
                .tracking(2)
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                
                Text(unit)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private var nightWakingsCard: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Text("Night Wakings")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundColor(.gray)
                    .textCase(.uppercase)
                    .tracking(2)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "bed.double.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.red)
                    
                    Text("2 Times")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundColor(.red)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.red.opacity(0.1))
                )
            }
            
            // Timeline visualization
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 48)
                
                HStack {
                    ForEach(0..<8) { _ in
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 1, height: 6)
                    }
                }
                
                HStack {
                    Text("10PM")
                        .font(.system(size: 8, weight: .bold, design: .rounded))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    HStack(spacing: 64) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 12, height: 12)
                            .shadow(color: .red.opacity(0.5), radius: 8, x: 0, y: 0)
                            .opacity(0.8)
                        
                        Circle()
                            .fill(Color.red)
                            .frame(width: 12, height: 12)
                            .shadow(color: .red.opacity(0.5), radius: 8, x: 0, y: 0)
                    }
                    
                    Spacer()
                    
                    Text("6AM")
                        .font(.system(size: 8, weight: .bold, design: .rounded))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 16)
            }
            
            Text("Awake for a total of 18 minutes. Primary reason: Sensory noise (Air conditioning).")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.gray)
                .lineSpacing(4)
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 44)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    private var sleepComplicationsCard: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Sleep Complications")
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundColor(.gray)
                .textCase(.uppercase)
                .tracking(2)
            
            VStack(spacing: 16) {
                complicationItem(label: "Sleep Onset Delay", value: "Minimal", color: .green, icon: "clock.fill")
                complicationItem(label: "Periodic Limb Movement", value: "None", color: .gray, icon: "figure.walk")
                complicationItem(label: "Sleep Apnea Signs", value: "Low Risk", color: .green, icon: "lungs.fill")
            }
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 44)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    private func complicationItem(label: String, value: String, color: Color, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
                .frame(width: 24)
            
            Text(label)
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundColor(.primary.opacity(0.9))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundColor(color)
                .textCase(.uppercase)
                .tracking(2)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.gray.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private var sleepStagesCard: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Sleep Stages")
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundColor(.gray)
                .textCase(.uppercase)
                .tracking(2)
            
            VStack(spacing: 16) {
                sleepStageItem(label: "Deep Sleep", value: 30, color: .blue)
                sleepStageItem(label: "REM Sleep", value: 25, color: .indigo)
                sleepStageItem(label: "Light Sleep", value: 45, color: .blue.opacity(0.6))
            }
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 44)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    private func sleepStageItem(label: String, value: Int, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundColor(.gray)
                    .textCase(.uppercase)
                    .tracking(2)
                
                Spacer()
                
                Text("\(value)%")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundColor(.primary.opacity(0.9))
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.2))
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(color)
                        .frame(width: geometry.size.width * CGFloat(value) / 100)
                }
            }
            .frame(height: 12)
        }
    }
    
    private var expertInsightCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Expert Insight")
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundColor(.indigo)
                .textCase(.uppercase)
                .tracking(2)
            
            Text("\(childName)'s sleep fragmentation is decreasing. Eliminating the white noise machine might further reduce the 2AM wake-up event.")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.indigo.opacity(0.9))
                .lineSpacing(4)
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 44)
                .fill(Color.indigo.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 44)
                        .stroke(Color.indigo.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private func behaviorDetailView(_ metric: MetricType) -> some View {
        VStack(spacing: 24) {
            // Core metrics
            VStack(alignment: .leading, spacing: 24) {
                Text("Core Behavioral Metrics")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundColor(metric == .meltdown ? .orange : .red)
                    .textCase(.uppercase)
                    .tracking(2)
                
                HStack(spacing: 16) {
                    metricValueBox(title: "Intensity", value: "7.2", unit: "/ 10", color: metric == .meltdown ? .orange : .red)
                    metricValueBox(title: "Avg Duration", value: "12", unit: "min", color: metric == .meltdown ? .orange : .red)
                }
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 44)
                    .fill(metric == .meltdown ? Color.orange.opacity(0.1) : Color.red.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 44)
                            .stroke(metric == .meltdown ? Color.orange.opacity(0.2) : Color.red.opacity(0.2), lineWidth: 2)
                    )
            )
            
            // Triggers
            triggersCard
            
            // Intervention success
            interventionCard
        }
    }
    
    private func metricValueBox(title: String, value: String, unit: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 9, weight: .black, design: .rounded))
                .foregroundColor(.gray)
                .textCase(.uppercase)
                .tracking(2)
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundColor(color)
                
                Text(unit)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
    
    private var triggersCard: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Triggers & Antecedents")
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundColor(.gray)
                .textCase(.uppercase)
                .tracking(2)
            
            VStack(spacing: 16) {
                triggerItem(label: "Transitions", value: 65, icon: "arrow.triangle.2.circlepath")
                triggerItem(label: "Sensory Overload", value: 20, icon: "speaker.wave.2.fill")
                triggerItem(label: "Task Refusal", value: 15, icon: "xmark.circle.fill")
            }
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 44)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    private func triggerItem(label: String, value: Int, icon: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(label)
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundColor(.primary.opacity(0.9))
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.gray.opacity(0.2))
                        
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.primary)
                            .frame(width: geometry.size.width * CGFloat(value) / 100)
                    }
                }
                .frame(height: 6)
            }
            
            Text("\(value)%")
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundColor(.gray)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.gray.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private var interventionCard: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Intervention Success")
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundColor(.gray)
                .textCase(.uppercase)
                .tracking(2)
            
            Text("The \"Quiet Corner\" technique has reduced recovery time by 4 minutes this week.")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.gray)
                .lineSpacing(4)
            
            // Chart
            HStack(alignment: .bottom, spacing: 8) {
                ForEach([40, 70, 45, 90, 65, 30, 80], id: \.self) { height in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(height > 60 ? Color.primary : Color.gray.opacity(0.3))
                        .frame(width: 12, height: CGFloat(height) * 1.6)
                }
            }
            .frame(height: 160)
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.gray.opacity(0.05))
            )
            
            HStack {
                Text("Mon")
                    .font(.system(size: 8, weight: .black, design: .rounded))
                    .foregroundColor(.gray)
                    .textCase(.uppercase)
                
                Spacer()
                
                Text("Sun")
                    .font(.system(size: 8, weight: .black, design: .rounded))
                    .foregroundColor(.gray)
                    .textCase(.uppercase)
            }
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 44)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    private var calendarGrid: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
        return LazyVGrid(columns: columns, spacing: 4) {
            ForEach(1...31, id: \.self) { day in
                calendarDayButton(day: day)
            }
        }
    }
    
    private func calendarDayButton(day: Int) -> some View {
        let isToday = day == 25
        return Button(action: {
            selectedDay = "Oct \(day)"
            viewState = .dashboard
        }) {
            Text("\(day)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(isToday ? .white : .gray)
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isToday ? Color.primary : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isToday ? Color.clear : Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    // MARK: - Helper Functions
    
    private func metricTitle(_ metric: MetricType) -> String {
        switch metric {
        case .sleep: return "Sleep Vitality Report"
        case .meltdown: return "Meltdown Analysis"
        case .aggression: return "Aggression Log"
        }
    }
    
    private struct Metrics {
        let sleep: Int
        let meltdown: Int
        let aggression: Int
    }
    
    private func getMetricsForDay(_ day: String) -> Metrics {
        let seed = day.reduce(0) { $0 + Int($1.asciiValue ?? 0) }
        func pseudoRandom(offset: Int) -> Int {
            let val = sin(Double(seed + offset)) * 10000
            return Int((val - floor(val)) * 100)
        }
        
        if day == "Yesterday" {
            return Metrics(sleep: 75, meltdown: 30, aggression: 25)
        } else if day == "Today" {
            return Metrics(sleep: 88, meltdown: 12, aggression: 65)
        } else if day == "Tomorrow" {
            return Metrics(sleep: 92, meltdown: 5, aggression: 10)
        }
        
        return Metrics(
            sleep: 40 + (pseudoRandom(offset: 1) % 55),
            meltdown: pseudoRandom(offset: 2) % 80,
            aggression: pseudoRandom(offset: 3) % 70
        )
    }
    
    private func getComparison(_ metric: MetricType) -> WhoopCircle.Comparison? {
        let hash = selectedDay.count + metric.rawValue.count
        let delta = (hash % 15) + 5
        let improved = hash % 2 == 0
        return WhoopCircle.Comparison(delta: delta, improved: improved)
    }
    
    private func handleFileUpload(item: PhotosPickerItem) {
        viewState = .processing
        
        Task {
            do {
                guard let data = try await item.loadTransferable(type: Data.self) else {
                    await MainActor.run {
                        viewState = .dashboard
                    }
                    return
                }
                
                let base64 = data.base64EncodedString()
                let mimeType = "video/mp4" // Default, could be determined from item
                
                let report = try await analyzeMedia(base64, mimeType)
                
                await MainActor.run {
                    analysisReport = report
                    lastUploadedMedia = (data: "data:\(mimeType);base64,\(base64)", mimeType: mimeType)
                    onUpdatePoints?(50)
                    viewState = .report
                }
            } catch {
                await MainActor.run {
                    viewState = .dashboard
                    // TODO: Show error alert
                }
            }
        }
    }
    
    private func startConsultation() {
        guard let report = analysisReport else { return }
        let expert = recommendedExperts[0]
        let initialText = "Hi \(expert.name.components(separatedBy: " ").first ?? ""), I've shared a video of \(childName) during a \"\(report.summaryTitle)\". Can you help me understand the triggers and how I can support him better?"
        
        var newMessages: [ChatMessage] = []
        
        if let media = lastUploadedMedia {
            // Remove data URL prefix if present
            let base64Data = media.data.contains(",") 
                ? String(media.data.split(separator: ",").last ?? "")
                : media.data
            
            newMessages.append(ChatMessage(
                role: "user",
                parts: [
                    ChatPart(text: "Video file: \(report.summaryTitle)", inlineData: nil),
                    ChatPart(text: nil, inlineData: InlineData(mimeType: media.mimeType, data: base64Data))
                ]
            ))
        }
        
        newMessages.append(ChatMessage(
            role: "user",
            parts: [ChatPart(text: initialText, inlineData: nil)]
        ))
        
        chatMessages = newMessages
        viewState = .expertChat
        isTyping = true
        
        Task {
            do {
                let response = try await getExpertConsultationResponse(
                    newMessages,
                    expert.name,
                    expert.role
                )
                
                await MainActor.run {
                    chatMessages.append(ChatMessage(
                        role: "model",
                        parts: [ChatPart(text: response, inlineData: nil)]
                    ))
                    isTyping = false
                }
            } catch {
                await MainActor.run {
                    chatMessages.append(ChatMessage(
                        role: "model",
                        parts: [ChatPart(text: "I'm reviewing the video now. It seems like a sensory-related response. Let's discuss a plan.", inlineData: nil)]
                    ))
                    isTyping = false
                }
            }
        }
    }
    
    private func handleSendMessage() {
        guard !chatInput.trimmingCharacters(in: .whitespaces).isEmpty && !isTyping else { return }
        
        let expert = recommendedExperts[0]
        let newMessage = ChatMessage(
            role: "user",
            parts: [ChatPart(text: chatInput, inlineData: nil)]
        )
        
        let nextHistory = chatMessages + [newMessage]
        chatMessages = nextHistory
        chatInput = ""
        isTyping = true
        
        Task {
            do {
                let response = try await getExpertConsultationResponse(
                    nextHistory,
                    expert.name,
                    expert.role
                )
                
                await MainActor.run {
                    chatMessages.append(ChatMessage(
                        role: "model",
                        parts: [ChatPart(text: response, inlineData: nil)]
                    ))
                    isTyping = false
                }
            } catch {
                await MainActor.run {
                    chatMessages.append(ChatMessage(
                        role: "model",
                        parts: [ChatPart(text: "I'm listening. Please go on.", inlineData: nil)]
                    ))
                    isTyping = false
                }
            }
        }
    }
    
    // MARK: - Data Models
    
    private struct Expert: Identifiable {
        let id: String
        let name: String
        let role: String
        let img: String
    }
    
    private struct Video: Identifiable {
        let id: String
        let title: String
        let duration: String
        let img: String
    }
    
    private let recommendedExperts: [Expert] = [
        Expert(id: "1", name: "Sarah Jones", role: "BCBA Specialist", img: "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=200&h=200&auto=format&fit=crop"),
        Expert(id: "2", name: "Dr. Mark Chen", role: "Speech Pathologist", img: "https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?q=80&w=200&h=200&auto=format&fit=crop")
    ]
    
    private let recommendedVideos: [Video] = [
        Video(id: "v1", title: "Sensory Reset Guide", duration: "5m", img: "https://images.unsplash.com/photo-1516627145497-ae6968895b74?q=80&w=400&h=225&auto=format&fit=crop"),
        Video(id: "v2", title: "Calm Transitions", duration: "12m", img: "https://images.unsplash.com/photo-1588075592446-265fd1e6e76f?q=80&w=400&h=225&auto=format&fit=crop")
    ]
}

#Preview {
    AnalyzerView(
        onNavigate: nil,
        childName: "Andy",
        onUpdatePoints: nil
    )
}

