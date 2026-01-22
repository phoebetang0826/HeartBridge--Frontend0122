//
//  ExpertSessionsView.swift
//  HeartBridge
//
//  Created by Phoebe Tang on 1/21/26.
//

import SwiftUI

struct ExpertSessionsView: View {
    let expertName: String?
    
    @State private var activeChat: String? = nil
    @State private var chatInput: String = ""
    @State private var appointments: [Appointment] = []
    @State private var activeChats: [ActiveChat] = []
    @State private var chatHistory: [Message] = []
    
    var body: some View {
        Group {
            if let activeChatId = activeChat {
                chatView(chatId: activeChatId)
            } else {
                mainView
            }
        }
        .onAppear {
            initializeData()
        }
    }
    
    // MARK: - Main View
    
    private var mainView: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                headerSection
                    .padding(.horizontal, 24)
                    .padding(.top, 112)
                    .padding(.bottom, 40)
                
                // Upcoming Appointments
                appointmentsSection
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                
                // Parent Conversations
                conversationsSection
                    .padding(.horizontal, 24)
                    .padding(.bottom, 100)
            }
        }
        .background(Color.gray.opacity(0.05))
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Expert Console")
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundColor(.primary.opacity(0.9))
                .tracking(-1)
            
            Text("Managing clinical sessions for today.")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.gray)
        }
    }
    
    private var appointmentsSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Text("Upcoming Appointments")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundColor(.gray)
                    .textCase(.uppercase)
                    .tracking(2)
                
                Spacer()
                
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Text("Sync Calendar")
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .foregroundColor(.primary)
                            .textCase(.uppercase)
                            .tracking(2)
                        
                        Image(systemName: "calendar")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.primary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            VStack(spacing: 16) {
                ForEach(appointments) { appointment in
                    appointmentCard(appointment)
                }
            }
        }
    }
    
    private func appointmentCard(_ appointment: Appointment) -> some View {
        HStack(spacing: 16) {
            // Avatar
            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color.primary.opacity(0.1))
                    .frame(width: 56, height: 56)
                
                Text(appointment.clientName?.prefix(1).uppercased() ?? "?")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(.primary)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(appointment.clientName ?? "Unknown Client")
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundColor(.primary.opacity(0.9))
                    .lineLimit(1)
                
                Text("\(appointment.date) · \(appointment.time)")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.gray)
                    .textCase(.uppercase)
            }
            
            Spacer()
            
            // Edit button
            Button(action: {}) {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.gray)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.1))
                    )
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var conversationsSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Parent Conversations")
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundColor(.gray)
                .textCase(.uppercase)
                .tracking(2)
            
            VStack(spacing: 16) {
                ForEach(activeChats) { chat in
                    conversationCard(chat)
                }
            }
        }
    }
    
    private func conversationCard(_ chat: ActiveChat) -> some View {
        Button(action: {
            activeChat = chat.id
            loadChatHistory(for: chat.id)
        }) {
            HStack(spacing: 16) {
                // Avatar with unread badge
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 56, height: 56)
                    
                    Text(chat.name.prefix(1).uppercased())
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(.gray)
                    
                    if chat.unread > 0 {
                        Text("\(chat.unread)")
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .frame(minWidth: 20, minHeight: 20)
                            .background(
                                Circle()
                                    .fill(Color.red)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 2)
                                    )
                            )
                            .offset(x: 4, y: -4)
                    }
                }
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(chat.name)
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundColor(.primary.opacity(0.9))
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text(chat.time)
                            .font(.system(size: 9, weight: .black, design: .rounded))
                            .foregroundColor(.gray)
                            .textCase(.uppercase)
                    }
                    
                    Text(chat.lastMsg)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                        .opacity(0.7)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 32)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    // MARK: - Chat View
    
    private func chatView(chatId: String) -> some View {
        let chat = activeChats.first { $0.id == chatId }
        
        return VStack(spacing: 0) {
            // Header
            chatHeaderView(chat: chat)
            
            Divider()
            
            // Messages
            messagesView
            
            Divider()
            
            // Input area
            chatInputArea
        }
        .background(Color.gray.opacity(0.05))
    }
    
    private func chatHeaderView(chat: ActiveChat?) -> some View {
        HStack(spacing: 16) {
            Button(action: {
                activeChat = nil
                chatHistory = []
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
            
            // Avatar
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.primary.opacity(0.1))
                .frame(width: 44, height: 44)
                .overlay(
                    Text(chat?.name.prefix(1).uppercased() ?? "?")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundColor(.primary)
                )
            
            // Info
            VStack(alignment: .leading, spacing: 2) {
                Text(chat?.name ?? "Unknown")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundColor(.primary.opacity(0.9))
                
                Text("Parent · Active Consultation")
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .foregroundColor(.primary)
                    .textCase(.uppercase)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .padding(.top, 48)
        .background(Color.white)
    }
    
    private var messagesView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(Array(chatHistory.enumerated()), id: \.element.id) { index, message in
                        messageBubble(message)
                            .id(index)
                    }
                }
                .padding(24)
            }
            .onChange(of: chatHistory.count) { oldValue, newValue in
                withAnimation {
                    if newValue > 0 {
                        proxy.scrollTo(newValue - 1, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    private func messageBubble(_ message: Message) -> some View {
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
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(message.sender == "user" ? Color.clear : Color.gray.opacity(0.2), lineWidth: 1)
                        )
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
    
    private var chatInputArea: some View {
        HStack(spacing: 12) {
            TextField("Message parent...", text: $chatInput)
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
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.primary)
                            .shadow(color: .primary.opacity(0.3), radius: 10, x: 0, y: 5)
                    )
            }
            .buttonStyle(ScaleButtonStyle())
            .disabled(chatInput.trimmingCharacters(in: .whitespaces).isEmpty)
            .opacity(chatInput.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1.0)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
        .padding(.bottom, 48)
        .background(Color.white)
    }
    
    // MARK: - Data Models
    
    private struct ActiveChat: Identifiable {
        let id: String
        let name: String
        let lastMsg: String
        let time: String
        let unread: Int
    }
    
    // MARK: - Actions
    
    private func initializeData() {
        appointments = [
            Appointment(
                id: "app1",
                expertId: "me",
                expertName: "Me",
                expertRole: "Expert",
                expertImg: "",
                date: "Oct 28",
                time: "10:00 AM",
                clientName: "Emily Rivera"
            ),
            Appointment(
                id: "app2",
                expertId: "me",
                expertName: "Me",
                expertRole: "Expert",
                expertImg: "",
                date: "Oct 28",
                time: "02:30 PM",
                clientName: "Michael Chen"
            ),
            Appointment(
                id: "app3",
                expertId: "me",
                expertName: "Me",
                expertRole: "Expert",
                expertImg: "",
                date: "Oct 29",
                time: "11:15 AM",
                clientName: "Sarah Jenkins"
            )
        ]
        
        activeChats = [
            ActiveChat(
                id: "c1",
                name: "Emily Rivera",
                lastMsg: "Andy had a great night, thank you!",
                time: "10m ago",
                unread: 2
            ),
            ActiveChat(
                id: "c2",
                name: "Michael Chen",
                lastMsg: "Should we skip the sensory board?",
                time: "1h ago",
                unread: 0
            )
        ]
    }
    
    private func loadChatHistory(for chatId: String) {
        // Load chat history for the selected chat
        if chatId == "c1" {
            chatHistory = [
                Message(
                    id: "m1",
                    text: "Hello Emily, I was reviewing Andy's latest sensory report.",
                    sender: "user",
                    timestamp: Date().addingTimeInterval(-3600)
                ),
                Message(
                    id: "m2",
                    text: "Andy had a great night, thank you! The new routine is helping.",
                    sender: "parent",
                    timestamp: Date().addingTimeInterval(-600)
                )
            ]
        } else {
            chatHistory = []
        }
    }
    
    private func handleSendMessage() {
        guard !chatInput.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let newMessage = Message(
            id: UUID().uuidString,
            text: chatInput,
            sender: "user",
            timestamp: Date()
        )
        
        chatHistory.append(newMessage)
        chatInput = ""
        
        // Simulate parent response after a delay
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
            
            await MainActor.run {
                let response = Message(
                    id: UUID().uuidString,
                    text: "Thank you for the update! That's great to hear.",
                    sender: "parent",
                    timestamp: Date()
                )
                chatHistory.append(response)
            }
        }
    }
}

#Preview {
    ExpertSessionsView(expertName: "Dr. Sarah")
}
