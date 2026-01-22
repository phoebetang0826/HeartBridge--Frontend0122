//
//  ChatView.swift
//  HeartBridge
//
//  Created by Phoebe Tang on 1/21/26.
//

import SwiftUI

struct ChatView: View {
    let childName: String
    let context: String?
    
    @Environment(\.dismiss) private var dismiss
    @State private var messages: [Message] = []
    @State private var inputValue: String = ""
    @State private var isTyping: Bool = false
    
    init(childName: String = "Andy", context: String? = nil) {
        self.childName = childName
        self.context = context
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            Divider()
            
            // Messages
            messagesView
            
            Divider()
            
            // Input area
            inputArea
        }
        .background(Color.white)
        .onAppear {
            initializeMessages()
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 4) {
            Text("AI Clinical Assistant")
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundColor(.primary.opacity(0.9))
                .tracking(-0.5)
            
            Text("Personalized for \(childName)")
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundColor(.primary)
                .textCase(.uppercase)
                .tracking(4)
                .opacity(0.6)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.top, 48)
        .background(Color.white)
    }
    
    private var messagesView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 24) {
                    ForEach(messages) { message in
                        messageBubble(message)
                            .id(message.id)
                    }
                    
                    if isTyping {
                        typingIndicator
                    }
                }
                .padding(24)
            }
            .onChange(of: messages.count) { oldValue, newValue in
                withAnimation {
                    if let lastMessage = messages.last {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
            .onChange(of: isTyping) { oldValue, newValue in
                if newValue {
                    withAnimation {
                        proxy.scrollTo("typing", anchor: .bottom)
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
            
            VStack(alignment: message.sender == "user" ? .trailing : .leading, spacing: 8) {
                Text(message.text)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(message.sender == "user" ? .white : .gray)
                    .lineSpacing(4)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(message.sender == "user" ? Color.primary : Color.gray.opacity(0.1))
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
                
                Text(formatTime(message.timestamp))
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .foregroundColor(.gray)
                    .textCase(.uppercase)
                    .tracking(2)
                    .padding(.horizontal, 8)
            }
            .frame(maxWidth: 300, alignment: message.sender == "user" ? .trailing : .leading)
            
            if message.sender != "user" {
                Spacer()
            }
        }
    }
    
    private var typingIndicator: some View {
        HStack {
            HStack(spacing: 4) {
                Text("Assistant is thinking...")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundColor(.primary.opacity(0.4))
                    .textCase(.uppercase)
                    .tracking(2)
                    .padding(.leading, 8)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.gray.opacity(0.1))
            )
            
            Spacer()
        }
        .id("typing")
    }
    
    private var inputArea: some View {
        VStack(spacing: 16) {
            // Prompt chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(["Sensory advice", "Behavior analysis", "Find a specialist"], id: \.self) { chip in
                        Button(action: { inputValue = chip }) {
                            Text(chip)
                                .font(.system(size: 10, weight: .black, design: .rounded))
                                .foregroundColor(.gray)
                                .textCase(.uppercase)
                                .tracking(2)
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
                .padding(.horizontal, 24)
            }
            
            // Input field and send button
            HStack(spacing: 12) {
                TextField("Ask anything...", text: $inputValue)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.1))
                    )
                    .onSubmit {
                        handleSend()
                    }
                
                Button(action: handleSend) {
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
                .disabled(inputValue.trimmingCharacters(in: .whitespaces).isEmpty || isTyping)
                .opacity(inputValue.trimmingCharacters(in: .whitespaces).isEmpty || isTyping ? 0.5 : 1.0)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
        .padding(.top, 16)
        .background(Color.white)
    }
    
    // MARK: - Actions
    
    private func initializeMessages() {
        let welcomeMessage = Message(
            id: "1",
            text: "Hi there! I'm your HeartBridge Assistant. I'm here to help you support \(childName). Ask me anything about behavioral insights, resources, or community threads.",
            sender: "nomi",
            timestamp: Date()
        )
        messages = [welcomeMessage]
    }
    
    private func handleSend() {
        guard !inputValue.trimmingCharacters(in: .whitespaces).isEmpty && !isTyping else { return }
        
        let userMessage = Message(
            id: UUID().uuidString,
            text: inputValue,
            sender: "user",
            timestamp: Date()
        )
        
        messages.append(userMessage)
        let currentInput = inputValue
        inputValue = ""
        isTyping = true
        
        Task {
            do {
                let response = try await getNomiResponse(currentInput, childName)
                
                await MainActor.run {
                    let nomiMessage = Message(
                        id: UUID().uuidString,
                        text: response,
                        sender: "nomi",
                        timestamp: Date()
                    )
                    messages.append(nomiMessage)
                    isTyping = false
                }
            } catch {
                await MainActor.run {
                    let errorMessage = Message(
                        id: UUID().uuidString,
                        text: "I'm here to support you and \(childName).",
                        sender: "nomi",
                        timestamp: Date()
                    )
                    messages.append(errorMessage)
                    isTyping = false
                }
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    ChatView(childName: "Andy")
}
