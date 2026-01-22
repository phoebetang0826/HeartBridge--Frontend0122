//
//  ServicesView.swift
//  HeartBridge
//
//  Created by Phoebe Tang on 1/21/26.
//

import SwiftUI

enum ServicesSubView {
    case main
    case expertProfile
    case expertChat
}

struct ServicesView: View {
    let initialExpertId: String?
    let onClearInitialExpert: (() -> Void)?
    let onBook: ((Appointment) -> Void)?
    
    @State private var view: ServicesSubView = .main
    @State private var selectedExpert: Expert? = nil
    @State private var mainScrollOffset: CGFloat = 0
    @State private var profileScrollOffset: CGFloat = 0
    @State private var isBookingModalOpen: Bool = false
    @State private var selectedDate: String = "Oct 28"
    @State private var selectedTime: String = "10:00 AM"
    @State private var chatInput: String = ""
    
    private let experts: [Expert] = [
        Expert(
            id: "1",
            name: "Alberto S.",
            role: "BCBA Therapist",
            headline: "Behavioral Intervention Specialist | Sensory-Friendly ABA",
            price: "$85/hr",
            img: "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=800&h=1200&auto=format&fit=crop",
            rating: "5.0",
            reviews: "124",
            minutesCoached: "12,500",
            followers: "2.1k",
            experience: "10 Years",
            education: "M.A. in Behavioral Science",
            philosophy: "Evidence-based intervention in natural environments.",
            bio: "Expert help on behavioral management and functional assessments. Specializing in sensory processing and emotional regulation for children ages 3-12.",
            specialties: ["Early Intervention", "Parent Training", "Social Skills"],
            isCustomerFavorite: true
        ),
        Expert(
            id: "2",
            name: "Jeremy S.",
            role: "ABA Specialist",
            headline: "Early Language Development | Positive Reinforcement Expert",
            price: "$65/hr",
            img: "https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?q=80&w=800&h=1200&auto=format&fit=crop",
            rating: "5.0",
            reviews: "89",
            minutesCoached: "8,420",
            followers: "1.2k",
            experience: "6 Years",
            education: "B.S. Psychology, Certified RBT",
            philosophy: "Connection through positive reinforcement.",
            bio: "Helping children find their voice through natural interaction. Passionate about using technology and play to bridge communication gaps.",
            specialties: ["NET", "AAC Support"],
            isCustomerFavorite: false
        )
    ]
    
    private let recentChats: [RecentChat] = [
        RecentChat(
            id: "1",
            name: "Dr. Sarah",
            avatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=Sarah",
            lastMsg: "How was Andy today?",
            time: "2m ago"
        ),
        RecentChat(
            id: "2",
            name: "Jeremy S.",
            avatar: "https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?q=80&w=800&h=1200&auto=format&fit=crop",
            lastMsg: "The schedule is sent.",
            time: "1h ago"
        )
    ]
    
    private let expertChatHistory: [ChatMessage] = [
        ChatMessage(sender: "expert", text: "Hello! I was reviewing Andy's latest sensory report. The progress in the playground is remarkable."),
        ChatMessage(sender: "user", text: "Thank you! We've been practicing the deep breathing techniques you suggested."),
        ChatMessage(sender: "expert", text: "That's excellent. Consistency is key. Should we focus on transition strategies for our next session?"),
        ChatMessage(sender: "user", text: "Yes, the morning routine is still a bit of a challenge.")
    ]
    
    var body: some View {
        ZStack {
            if view == .main {
                mainView
            } else if view == .expertProfile, let expert = selectedExpert {
                expertProfileView(expert)
            } else if view == .expertChat, let expert = selectedExpert {
                expertChatView(expert)
            }
            
            // Booking Modal
            if isBookingModalOpen, let expert = selectedExpert {
                bookingModal(expert)
            }
        }
        .onAppear {
            if let expertId = initialExpertId {
                if let expert = experts.first(where: { $0.id == expertId }) {
                    selectedExpert = expert
                    view = .expertProfile
                }
            }
        }
    }
    
    // MARK: - Main View
    
    private var mainView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    // Disappearing Header
                    disappearingHeader
                        .padding(.horizontal, 24)
                        .padding(.top, 64)
                        .padding(.bottom, 24)
                    
                    // Sticky Search Bar
                    stickySearchBar
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                    
                    // Content
                    VStack(spacing: 48) {
                        // Recent Consultations
                        recentConsultationsSection
                            .padding(.horizontal, 24)
                        
                        // Parent Workshops
                        workshopsSection
                            .padding(.horizontal, 24)
                        
                        // Meet the Experts
                        expertsSection
                            .padding(.horizontal, 24)
                            .padding(.bottom, 100)
                    }
                }
            }
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).minY)
                }
            )
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                mainScrollOffset = -value
            }
        }
        .background(Color.gray.opacity(0.05))
    }
    
    private var disappearingHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("ABA & BCBA Behavioral Support")
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundColor(.primary.opacity(0.9))
                .tracking(-1)
                .lineSpacing(4)
            
            Text("Expert clinical advice for every stage of your journey.")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.gray)
                .textCase(.uppercase)
                .tracking(2)
                .lineSpacing(4)
        }
        .opacity(max(0, 1 - mainScrollOffset / 120))
        .offset(y: -mainScrollOffset * 0.4)
        .opacity(mainScrollOffset > 150 ? 0 : max(0, 1 - mainScrollOffset / 120))
    }
    
    private var stickySearchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.gray)
                .padding(.leading, 24)
            
            TextField("Search for a therapist...", text: .constant(""))
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .padding(.vertical, 20)
                .padding(.trailing, 24)
        }
        .background(
            RoundedRectangle(cornerRadius: 40)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(mainScrollOffset > 80 ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1), lineWidth: 2)
                )
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .background(
            Group {
                if mainScrollOffset > 80 {
                    Color.white.opacity(0.9).background(.ultraThinMaterial)
                } else {
                    Color.clear
                }
            }
        )
    }
    
    private var recentConsultationsSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Clinical Conversations")
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundColor(.gray)
                .textCase(.uppercase)
                .tracking(2)
                .padding(.leading, 8)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(recentChats) { chat in
                        recentChatCard(chat)
                    }
                }
                .padding(.horizontal, 24)
            }
            .padding(.horizontal, -24)
        }
    }
    
    private func recentChatCard(_ chat: RecentChat) -> some View {
        HStack(spacing: 16) {
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: chat.avatar)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 2)
                )
                
                Circle()
                    .fill(Color.green)
                    .frame(width: 14, height: 14)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .offset(x: 4, y: -4)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(chat.name)
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundColor(.primary.opacity(0.9))
                    .lineLimit(1)
                
                Text(chat.lastMsg)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.gray)
                    .opacity(0.8)
                    .lineLimit(1)
            }
        }
        .padding(20)
        .frame(minWidth: 240)
        .background(
            RoundedRectangle(cornerRadius: 40)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 40)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
    
    private var workshopsSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Text("Parent Workshops")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(.primary.opacity(0.9))
                    .tracking(-1)
                
                Spacer()
                
                Button("Browse All") {
                    // TODO: Navigate to all workshops
                }
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundColor(.primary)
                .textCase(.uppercase)
                .tracking(2)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    workshopCard
                }
                .padding(.horizontal, 24)
            }
            .padding(.horizontal, -24)
        }
    }
    
    private var workshopCard: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?q=80&w=400&h=225&auto=format&fit=crop")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(height: 200)
                .clipped()
                
                Text("Live in 2h")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundColor(.primary.opacity(0.9))
                    .textCase(.uppercase)
                    .tracking(2)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.95))
                            .background(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    )
                    .padding(20)
            }
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Meltdown Prevention: Advanced BCBA Techniques")
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundColor(.primary.opacity(0.9))
                    .lineLimit(2)
                    .frame(height: 44, alignment: .top)
                
                Button(action: {}) {
                    Text("Secure Spot")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .textCase(.uppercase)
                        .tracking(2)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.primary)
                                .shadow(color: .primary.opacity(0.3), radius: 10, x: 0, y: 5)
                        )
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(32)
        }
        .frame(width: 300)
        .background(
            RoundedRectangle(cornerRadius: 56)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 56)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var expertsSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Text("Meet the Experts")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(.primary.opacity(0.9))
                    .tracking(-1)
                
                Spacer()
                
                Button("See More") {
                    // TODO: Navigate to all experts
                }
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundColor(.primary)
                .textCase(.uppercase)
                .tracking(2)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(experts) { expert in
                        expertCard(expert)
                    }
                }
                .padding(.horizontal, 24)
            }
            .padding(.horizontal, -24)
        }
    }
    
    private func expertCard(_ expert: Expert) -> some View {
        Button(action: {
            selectedExpert = expert
            profileScrollOffset = 0
            view = .expertProfile
        }) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    AsyncImage(url: URL(string: expert.img)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 40))
                    .overlay(
                        RoundedRectangle(cornerRadius: 40)
                            .stroke(Color.gray.opacity(0.1), lineWidth: 4)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 40)
                            .stroke(Color.white, lineWidth: 4)
                    )
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(expert.price)
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundColor(.gray)
                        
                        Text("consultation")
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .foregroundColor(.gray)
                            .textCase(.uppercase)
                            .tracking(-0.5)
                    }
                }
                .padding(.bottom, 24)
                
                Text(expert.name)
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundColor(.primary.opacity(0.9))
                    .padding(.bottom, 8)
                
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.orange)
                    
                    Text("\(expert.rating) (\(expert.reviews))")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 12)
                
                Text(expert.headline)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.gray)
                    .lineLimit(2)
                    .frame(height: 40, alignment: .top)
                    .padding(.bottom, 32)
                
                Divider()
                    .padding(.bottom, 20)
                
                HStack {
                    Text(expert.role)
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundColor(.primary)
                        .textCase(.uppercase)
                        .tracking(2)
                    
                    Spacer()
                    
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "chevron.right")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.gray)
                        )
                }
            }
            .padding(24)
            .frame(width: 280)
            .background(
                RoundedRectangle(cornerRadius: 48)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 48)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    // MARK: - Expert Profile View
    
    private func expertProfileView(_ expert: Expert) -> some View {
        ZStack(alignment: .bottom) {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        // Header
                        expertProfileHeader(expert)
                            .padding(.horizontal, 24)
                            .padding(.top, 48)
                            .padding(.bottom, 32)
                        
                        // Content
                        expertProfileContent(expert)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 200)
                    }
                }
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("profileScroll")).minY)
                    }
                )
                .coordinateSpace(name: "profileScroll")
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    profileScrollOffset = -value
                }
            }
            
            // Action Bar
            actionBar(expert)
                .offset(y: profileScrollOffset > 60 ? 0 : 200)
                .opacity(profileScrollOffset > 60 ? 1 : 0)
                .animation(.spring(response: 0.7, dampingFraction: 0.8), value: profileScrollOffset)
        }
        .background(Color.white)
    }
    
    private func expertProfileHeader(_ expert: Expert) -> some View {
        HStack(spacing: 16) {
            Button(action: {
                view = .main
                onClearInitialExpert?()
            }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.gray)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.1))
                    )
            }
            .buttonStyle(ScaleButtonStyle())
            
            if profileScrollOffset > 60 {
                VStack(alignment: .leading, spacing: 2) {
                    Text(expert.name)
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundColor(.primary.opacity(0.9))
                        .lineLimit(1)
                    
                    Text(expert.role)
                        .font(.system(size: 9, weight: .black, design: .rounded))
                        .foregroundColor(.primary)
                        .textCase(.uppercase)
                        .tracking(2)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.gray)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 12)
        .background(
            Group {
                if profileScrollOffset > 60 {
                    Color.white.opacity(0.95).background(.ultraThinMaterial)
                } else {
                    Color.clear
                }
            }
        )
        .overlay(
            Rectangle()
                .fill(Color.gray.opacity(0.1))
                .frame(height: 1)
                .offset(y: profileScrollOffset > 60 ? 0 : -1)
        )
    }
    
    private func expertProfileContent(_ expert: Expert) -> some View {
        VStack(spacing: 0) {
            // Avatar and basic info
            VStack(spacing: 24) {
                ZStack(alignment: .bottomTrailing) {
                    AsyncImage(url: URL(string: expert.img)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(width: 160, height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 64))
                    .overlay(
                        RoundedRectangle(cornerRadius: 64)
                            .stroke(Color.gray.opacity(0.1), lineWidth: 8)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 64)
                            .stroke(Color.white, lineWidth: 4)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                    
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.green)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.white, lineWidth: 4)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        .offset(x: -4, y: -4)
                }
                
                Text(expert.name)
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundColor(.primary.opacity(0.9))
                    .tracking(-1)
                
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.orange)
                    
                    Text(expert.rating)
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundColor(.gray)
                    
                    Text("(\(expert.reviews) reviews)")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundColor(.gray)
                        .textCase(.uppercase)
                        .tracking(2)
                }
                
                Text(expert.headline)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
            }
            
            // Stats
            HStack(spacing: 16) {
                statBox(value: expert.minutesCoached, label: "Clinical Hours")
                statBox(value: expert.followers, label: "Families Helped")
            }
            .padding(.bottom, 48)
            
            // Approach
            VStack(alignment: .leading, spacing: 16) {
                Text("Approach")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundColor(.gray)
                    .textCase(.uppercase)
                    .tracking(2)
                    .padding(.leading, 8)
                
                Text("\"\(expert.philosophy)\"")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .italic()
                    .lineSpacing(4)
                    .padding(32)
                    .background(
                        RoundedRectangle(cornerRadius: 48)
                            .fill(Color.primary.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 48)
                                    .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                            )
                    )
            }
            .padding(.bottom, 48)
            
            // Bio
            VStack(alignment: .leading, spacing: 16) {
                Text("Professional Bio")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundColor(.gray)
                    .textCase(.uppercase)
                    .tracking(2)
                    .padding(.leading, 8)
                
                Text(expert.bio)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                    .lineSpacing(4)
            }
            .padding(.bottom, 48)
            
            // Specialties
            VStack(alignment: .leading, spacing: 16) {
                Text("Core Specialties")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundColor(.gray)
                    .textCase(.uppercase)
                    .tracking(2)
                    .padding(.leading, 8)
                
                FlowLayout(spacing: 8) {
                    ForEach(expert.specialties, id: \.self) { specialty in
                        Text(specialty)
                            .font(.system(size: 11, weight: .black, design: .rounded))
                            .foregroundColor(.gray)
                            .textCase(.uppercase)
                            .tracking(2)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 2)
                                    )
                            )
                    }
                }
            }
        }
    }
    
    private func statBox(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(value)
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundColor(.primary.opacity(0.9))
            
            Text(label)
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundColor(.gray)
                .textCase(.uppercase)
                .tracking(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 48)
                .fill(Color.gray.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 48)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private func actionBar(_ expert: Expert) -> some View {
        HStack(spacing: 12) {
            Button(action: {
                view = .expertChat
            }) {
                Image(systemName: "message.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.gray)
                    .frame(width: 64, height: 64)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.gray.opacity(0.1))
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    )
            }
            .buttonStyle(ScaleButtonStyle())
            
            Button(action: {
                isBookingModalOpen = true
            }) {
                Text("Book Session")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .textCase(.uppercase)
                    .tracking(2)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 32)
                            .fill(Color.primary)
                            .shadow(color: .primary.opacity(0.3), radius: 20, x: 0, y: 10)
                    )
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
        .padding(.bottom, 48)
        .background(
            Color.white.opacity(0.95)
                .background(.ultraThinMaterial)
                .overlay(
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 1)
                )
        )
    }
    
    // MARK: - Expert Chat View
    
    private func expertChatView(_ expert: Expert) -> some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 16) {
                Button(action: {
                    view = .expertProfile
                }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.gray)
                        .frame(width: 44, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.gray.opacity(0.1))
                        )
                }
                .buttonStyle(ScaleButtonStyle())
                
                AsyncImage(url: URL(string: expert.img)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(expert.name)
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundColor(.primary.opacity(0.9))
                    
                    Text("Specialist Online")
                        .font(.system(size: 9, weight: .black, design: .rounded))
                        .foregroundColor(.primary)
                        .textCase(.uppercase)
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .padding(.top, 48)
            .background(Color.white.opacity(0.95).background(.ultraThinMaterial))
            .overlay(
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 1)
            )
            
            // Messages
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(Array(expertChatHistory.enumerated()), id: \.offset) { index, message in
                        messageBubble(message)
                    }
                }
                .padding(24)
            }
            .background(Color.gray.opacity(0.05))
            
            // Input
            HStack(spacing: 12) {
                TextField("Type a message...", text: $chatInput)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.1))
                    )
                    .onSubmit {
                        // TODO: Send message
                    }
                
                Button(action: {
                    // TODO: Send message
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.primary)
                                .shadow(color: .primary.opacity(0.3), radius: 10, x: 0, y: 5)
                        )
                }
                .buttonStyle(ScaleButtonStyle())
                .disabled(chatInput.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(24)
            .padding(.bottom, 48)
            .background(Color.white)
            .overlay(
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 1)
                    .offset(y: -1)
            )
        }
        .background(Color.white)
    }
    
    private func messageBubble(_ message: ChatMessage) -> some View {
        HStack {
            if message.sender == "user" {
                Spacer()
            }
            
            Text(message.text)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(message.sender == "user" ? .white : .gray)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(message.sender == "user" ? Color.primary : Color.white)
                        .shadow(
                            color: message.sender == "user" ? Color.primary.opacity(0.3) : Color.black.opacity(0.05),
                            radius: 10,
                            x: 0,
                            y: 5
                        )
                )
                .frame(maxWidth: 300, alignment: message.sender == "user" ? .trailing : .leading)
            
            if message.sender != "user" {
                Spacer()
            }
        }
    }
    
    // MARK: - Booking Modal
    
    private func bookingModal(_ expert: Expert) -> some View {
        ZStack {
            Color.black.opacity(0.4)
                .background(.ultraThinMaterial)
                .ignoresSafeArea()
                .onTapGesture {
                    isBookingModalOpen = false
                }
            
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 0) {
                    // Handle
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 48, height: 6)
                        .padding(.top, 16)
                        .padding(.bottom, 32)
                    
                    Text("Schedule Session")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(.primary.opacity(0.9))
                        .padding(.bottom, 32)
                    
                    // Date selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Select Date")
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .foregroundColor(.gray)
                            .textCase(.uppercase)
                            .tracking(2)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(["Oct 28", "Oct 29", "Oct 30", "Oct 31", "Nov 01"], id: \.self) { date in
                                    Button(action: { selectedDate = date }) {
                                        Text(date)
                                            .font(.system(size: 14, weight: .black, design: .rounded))
                                            .foregroundColor(selectedDate == date ? .white : .gray)
                                            .padding(.horizontal, 24)
                                            .padding(.vertical, 20)
                                            .background(
                                                RoundedRectangle(cornerRadius: 24)
                                                    .fill(selectedDate == date ? Color.primary : Color.gray.opacity(0.1))
                                                    .shadow(
                                                        color: selectedDate == date ? Color.primary.opacity(0.5) : Color.clear,
                                                        radius: 10,
                                                        x: 0,
                                                        y: 5
                                                    )
                                            )
                                    }
                                    .buttonStyle(ScaleButtonStyle())
                                }
                            }
                        }
                    }
                    .padding(.bottom, 40)
                    
                    // Time selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Select Time")
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .foregroundColor(.gray)
                            .textCase(.uppercase)
                            .tracking(2)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                            ForEach(["09:00 AM", "10:00 AM", "01:30 PM", "04:00 PM"], id: \.self) { time in
                                Button(action: { selectedTime = time }) {
                                    Text(time)
                                        .font(.system(size: 14, weight: .black, design: .rounded))
                                        .foregroundColor(selectedTime == time ? .white : .gray)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 20)
                                        .background(
                                            RoundedRectangle(cornerRadius: 24)
                                                .fill(selectedTime == time ? Color.primary : Color.gray.opacity(0.1))
                                                .shadow(
                                                    color: selectedTime == time ? Color.primary.opacity(0.5) : Color.clear,
                                                    radius: 10,
                                                    x: 0,
                                                    y: 5
                                                )
                                        )
                                }
                                .buttonStyle(ScaleButtonStyle())
                            }
                        }
                    }
                    .padding(.bottom, 48)
                    
                    // Confirm button
                    Button(action: handleConfirmBooking) {
                        Text("Confirm Booking • \(selectedDate)")
                            .font(.system(size: 14, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .textCase(.uppercase)
                            .tracking(2)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 24)
                            .background(
                                RoundedRectangle(cornerRadius: 40)
                                    .fill(Color.primary)
                                    .shadow(color: .primary.opacity(0.3), radius: 20, x: 0, y: 10)
                            )
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .padding(.bottom, 32)
                }
                .padding(.horizontal, 40)
                .background(
                    RoundedRectangle(cornerRadius: 64)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.2), radius: 40, x: 0, y: -10)
                )
                .frame(maxHeight: 700)
            }
        }
        .zIndex(200)
    }
    
    // MARK: - Actions
    
    private func handleConfirmBooking() {
        guard let expert = selectedExpert else { return }
        
        let appointment = Appointment(
            id: UUID().uuidString,
            expertId: expert.id,
            expertName: expert.name,
            expertRole: expert.role,
            expertImg: expert.img,
            date: selectedDate,
            time: selectedTime
        )
        
        onBook?(appointment)
        isBookingModalOpen = false
        
        // TODO: Show success alert
    }
    
    // MARK: - Data Models
    
    private struct Expert: Identifiable {
        let id: String
        let name: String
        let role: String
        let headline: String
        let price: String
        let img: String
        let rating: String
        let reviews: String
        let minutesCoached: String
        let followers: String
        let experience: String
        let education: String
        let philosophy: String
        let bio: String
        let specialties: [String]
        let isCustomerFavorite: Bool
    }
    
    private struct RecentChat: Identifiable {
        let id: String
        let name: String
        let avatar: String
        let lastMsg: String
        let time: String
    }
    
    private struct ChatMessage {
        let sender: String
        let text: String
    }
}

// MARK: - Supporting Views

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX, y: bounds.minY + result.frames[index].minY), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var frames: [CGRect] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

// MARK: - Scroll Offset Preference Key

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    ServicesView(
        initialExpertId: nil,
        onClearInitialExpert: nil,
        onBook: nil
    )
}
