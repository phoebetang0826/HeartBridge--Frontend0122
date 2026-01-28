//
//  AppView.swift
//  HeartBridge
//
//  Created by Phoebe Tang on 1/21/26.
//

import SwiftUI

struct AppView: View {
    @State private var isOnboarded = false
    @State private var childProfile: ChildProfile?
    @State private var activeTab: AppTab = .predictive
    @State private var appointments: [Appointment] = []
    @State private var isProfileOpen = false
    @State private var isChatOpen = false
    @State private var isPricingOpen = false
    
    private let profileKey = "heartbridge_user_profile"
    
    var body: some View {
        Group {
            if !isOnboarded {
                OnboardingView(onComplete: handleOnboardingComplete)
            } else {
                mainContentView
            }
        }
        .onAppear {
            loadSavedProfile()
        }
    }
    
    private var mainContentView: some View {
        ZStack {
            // Main content
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Content area
                contentView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Tab bar
                tabBarView
            }
            
            // Floating chat button (only for parents, when chat is not open)
            if !isExpert && !isChatOpen {
                floatingChatButton
            }
        }
        .sheet(isPresented: $isChatOpen) {
            ChatView(childName: childProfile?.name ?? "")
        }
        .sheet(isPresented: $isPricingOpen) {
            PricingView(
                role: childProfile?.role ?? .parent,
                onSelect: handleUpdateSubscription
            )
        }
        .fullScreenCover(isPresented: $isProfileOpen) {
            ProfileView(
                childProfile: childProfile,
                appointments: appointments,
                onLogout: handleLogout
            )
        }
    }
    
    private var headerView: some View {
        HStack {
            // HeartBridge logo
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.primary)
                    .frame(width: 8, height: 8)
                    .opacity(0.8)
                
                Text("HeartBridge")
                    .font(.system(size: 13, weight: .black, design: .default))
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
            
            Spacer()
            
            // Profile button
            Button(action: { isProfileOpen = true }) {
                AsyncImage(url: profileImageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(.gray)
                }
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(.horizontal, 24)
        .padding(.top, 48)
        .padding(.bottom, 16)
    }
    
    private var contentView: some View {
        Group {
            if isExpert {
                expertContentView
            } else {
                parentContentView
            }
        }
    }
    
    private var expertContentView: some View {
        Group {
            switch activeTab {
            case .sessions:
                ExpertSessionsView(expertName: childProfile?.parentName ?? "")
            case .community:
                CommunityView(isExpert: true)
            default:
                ExpertSessionsView(expertName: childProfile?.parentName ?? "")
            }
        }
    }
    
    private var parentContentView: some View {
        Group {
            switch activeTab {
            case .predictive:
                PredictiveSupportView(
                    childName: childProfile?.name,
                    tier: childProfile?.subscriptionTier ?? .free,
                    onUpgrade: { isPricingOpen = true }
                )
            case .video:
                VideoSupportView(
                    childName: childProfile?.name,
                    onUpdatePoints: handleUpdatePoints,
                    onConsult: { isChatOpen = true }
                )
            case .community:
                CommunityView(isExpert: false)
            case .resources:
                ServicesView(
                    initialExpertId: nil,
                    onClearInitialExpert: nil,
                    onBook: { appointment in
                        appointments.insert(appointment, at: 0)
                    }
                )
            default:
                PredictiveSupportView(
                    childName: childProfile?.name,
                    tier: childProfile?.subscriptionTier ?? .free
                )
            }
        }
    }
    
    private var tabBarView: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.gray.opacity(0.2))
            
            HStack(spacing: 0) {
                ForEach(navItems, id: \.id) { item in
                    Button(action: { activeTab = item.id }) {
                        VStack(spacing: 4) {
                            Image(systemName: item.icon)
                                .font(.system(size: 28))
                                .symbolVariant(activeTab == item.id ? .fill : .none)
                                .foregroundColor(activeTab == item.id ? .primary : .gray)
                                .frame(width: 44, height: 44)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(activeTab == item.id ? Color.primary.opacity(0.1) : Color.clear)
                                )
                            
                            Text(item.label)
                                .font(.system(size: 9, weight: .black))
                                .textCase(.uppercase)
                                .tracking(2)
                                .foregroundColor(activeTab == item.id ? .primary : .gray.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .background(
                Color.white.opacity(0.95)
                    .background(.ultraThinMaterial)
            )
        }
    }
    
    private var floatingChatButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: { isChatOpen = true }) {
                    Image(systemName: "message.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .frame(width: 64, height: 64)
                        .background(
                            Circle()
                                .fill(Color.primary)
                                .shadow(color: .primary.opacity(0.5), radius: 20, x: 0, y: 10)
                        )
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.trailing, 24)
                .padding(.bottom, 128)
            }
        }
    }
    
    private var navItems: [NavItem] {
        if isExpert {
            return [
                NavItem(id: .sessions, label: "Sessions", icon: "calendar"),
                NavItem(id: .community, label: "Community", icon: "person.3.fill")
            ]
        } else {
            return [
                NavItem(id: .predictive, label: "Predictive", icon: "chart.line.uptrend.xyaxis"),
                NavItem(id: .video, label: "Video", icon: "video.fill"),
                NavItem(id: .resources, label: "Resources", icon: "book.fill"),
                NavItem(id: .community, label: "Community", icon: "person.3.fill")
            ]
        }
    }
    
    private var isExpert: Bool {
        childProfile?.role == .expert
    }
    
    private var profileImageURL: URL? {
        let name = childProfile?.parentName ?? "User"
        return URL(string: "https://api.dicebear.com/7.x/avataaars/svg?seed=\(name)")
    }
    
    // MARK: - Actions
    
    private func loadSavedProfile() {
        if let data = UserDefaults.standard.data(forKey: profileKey),
           let profile = try? JSONDecoder().decode(ChildProfile.self, from: data) {
            childProfile = profile
            isOnboarded = true
            activeTab = profile.role == .expert ? .sessions : .predictive
        }
    }
    
    private func handleOnboardingComplete(_ profile: ChildProfile) {
        let enriched = ChildProfile(
            name: profile.name,
            parentName: profile.parentName,
            role: profile.role,
            points: profile.role == .parent ? 100 : 0,
            subscriptionTier: .free
        )
        childProfile = enriched
        isOnboarded = true
        saveProfile(enriched)
        activeTab = profile.role == .expert ? .sessions : .predictive
    }
    
    private func handleUpdateSubscription(_ tier: SubscriptionTier) {
        guard var profile = childProfile else { return }
        profile.subscriptionTier = tier
        childProfile = profile
        saveProfile(profile)
        isPricingOpen = false
    }
    
    private func handleUpdatePoints(_ points: Int) {
        guard var profile = childProfile else { return }
        profile.points += points
        childProfile = profile
        saveProfile(profile)
    }
    
    private func handleLogout() {
        UserDefaults.standard.removeObject(forKey: profileKey)
        childProfile = nil
        isOnboarded = false
        isProfileOpen = false
        activeTab = .predictive
    }
    
    private func saveProfile(_ profile: ChildProfile) {
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: profileKey)
        }
    }
}

// MARK: - Supporting Types

struct NavItem {
    let id: AppTab
    let label: String
    let icon: String
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

