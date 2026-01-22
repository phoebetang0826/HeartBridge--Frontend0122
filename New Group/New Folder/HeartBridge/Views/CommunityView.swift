//
//  CommunityView.swift
//  HeartBridge
//
//  Created by Phoebe Tang on 1/21/26.
//

import SwiftUI
import PhotosUI

enum CommunitySubView {
    case feed
    case create
    case postDetail
}

struct CommunityView: View {
    let isExpert: Bool
    
    @State private var view: CommunitySubView = .feed
    @State private var posts: [Post] = []
    @State private var isGenerating: Bool = false
    @State private var generationMsg: String = ""
    @State private var newPost: PartialPost = PartialPost()
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    
    var body: some View {
        ZStack {
            if view == .feed {
                feedView
            } else {
                createView
            }
            
            // Floating create button
            if view == .feed {
                floatingCreateButton
            }
            
            // AI Generation overlay
            if isGenerating {
                generationOverlay
            }
        }
        .onAppear {
            initializePosts()
        }
        .photosPicker(
            isPresented: .constant(false),
            selection: $selectedPhotoItem,
            matching: .any(of: [.images, .videos])
        )
        .onChange(of: selectedPhotoItem) { oldValue, newValue in
            if let newValue = newValue {
                handleFileChange(item: newValue)
            }
        }
    }
    
    // MARK: - Feed View
    
    private var feedView: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            Divider()
            
            // Content
            ScrollView {
                VStack(spacing: 0) {
                    // Create post prompt
                    createPostPrompt
                        .padding(.horizontal, 16)
                        .padding(.vertical, 24)
                    
                    // Filter chips
                    filterChips
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    
                    // Posts
                    postsList
                        .padding(.horizontal, 16)
                        .padding(.bottom, 100)
                }
            }
        }
        .background(Color.gray.opacity(0.05))
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Community")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundColor(.primary)
                    .tracking(-1)
                
                Text(isExpert ? "Clinician Network" : "Neurodiversity Hub")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundColor(.gray)
                    .textCase(.uppercase)
                    .tracking(2)
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.primary)
                            .shadow(color: .primary.opacity(0.5), radius: 10, x: 0, y: 5)
                    )
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(.horizontal, 24)
        .padding(.top, 48)
        .padding(.bottom, 24)
        .background(Color.white)
    }
    
    private var createPostPrompt: some View {
        Button(action: { view = .create }) {
            HStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.gray)
                    )
                
                Text(isExpert ? "Share clinical advice..." : "What's on your mind today?")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.gray)
                
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(["🔥 Hot", "✨ New", "🏥 Specialists", "🎞️ AI Reels"], id: \.self) { filter in
                    Button(action: {}) {
                        Text(filter)
                            .font(.system(size: 11, weight: .black, design: .rounded))
                            .foregroundColor(.gray)
                            .textCase(.uppercase)
                            .tracking(2)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(Color.white)
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                            )
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
        }
    }
    
    private var postsList: some View {
        VStack(spacing: 8) {
            ForEach(posts) { post in
                PostCard(post: post)
            }
        }
    }
    
    private var floatingCreateButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: { view = .create }) {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 64, height: 64)
                        .background(
                            Circle()
                                .fill(Color.primary)
                                .shadow(color: .primary.opacity(0.4), radius: 20, x: 0, y: 10)
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 4)
                        )
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.trailing, 24)
                .padding(.bottom, 128)
            }
        }
    }
    
    // MARK: - Create View
    
    private var createView: some View {
        VStack(spacing: 0) {
            // Header
            createHeaderView
            
            Divider()
            
            // Content
            ScrollView {
                VStack(spacing: 24) {
                    // Author info
                    authorInfoView
                        .padding(.top, 24)
                    
                    // Title input
                    titleInput
                    
                    // Content input
                    contentInput
                    
                    // Media preview
                    if let mediaUrl = newPost.mediaUrl {
                        mediaPreview(mediaUrl: mediaUrl)
                    }
                    
                    // AI tools
                    aiToolsSection
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 100)
            }
            
            Divider()
            
            // Bottom actions
            bottomActions
        }
        .background(Color.white)
    }
    
    private var createHeaderView: some View {
        HStack {
            Button(action: { view = .feed }) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.gray)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(ScaleButtonStyle())
            
            Spacer()
            
            Text("New Post")
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundColor(.primary.opacity(0.9))
            
            Spacer()
            
            Button(action: handleCreatePost) {
                Text("Post")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(canPost ? Color.primary : Color.gray.opacity(0.3))
                            .shadow(color: canPost ? Color.primary.opacity(0.3) : Color.clear, radius: 10, x: 0, y: 5)
                    )
            }
            .buttonStyle(ScaleButtonStyle())
            .disabled(!canPost)
        }
        .padding(.horizontal, 24)
        .padding(.top, 48)
        .padding(.bottom, 16)
        .background(Color.white)
    }
    
    private var authorInfoView: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.primary.opacity(0.1))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Posting as \(isExpert ? "Clinician" : "Parent")")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundColor(.primary.opacity(0.9))
                
                Text("Public Community Feed")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.gray)
                    .textCase(.uppercase)
                    .tracking(2)
            }
        }
    }
    
    private var titleInput: some View {
        TextField("Post title...", text: $newPost.title)
            .font(.system(size: 24, weight: .black, design: .rounded))
            .foregroundColor(.primary.opacity(0.9))
            .placeholder(when: newPost.title.isEmpty) {
                Text("Post title...")
                    .foregroundColor(.gray.opacity(0.3))
            }
    }
    
    private var contentInput: some View {
        TextEditor(text: $newPost.content)
            .font(.system(size: 18, weight: .medium, design: .rounded))
            .foregroundColor(.gray)
            .frame(minHeight: 150)
            .scrollContentBackground(.hidden)
            .overlay(
                Group {
                    if newPost.content.isEmpty {
                        VStack {
                            HStack {
                                Text(isExpert ? "Provide clinical insight..." : "Share your story...")
                                    .font(.system(size: 18, weight: .medium, design: .rounded))
                                    .foregroundColor(.gray.opacity(0.3))
                                    .padding(.top, 8)
                                    .padding(.leading, 4)
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                },
                alignment: .topLeading
            )
    }
    
    private func mediaPreview(mediaUrl: String) -> some View {
        ZStack(alignment: .topTrailing) {
            Group {
                if newPost.mediaType == "video" {
                    VideoPlayerView(url: mediaUrl)
                } else {
                    AsyncImage(url: URL(string: mediaUrl)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                }
            }
            .frame(height: 300)
            .clipShape(RoundedRectangle(cornerRadius: 32))
            .overlay(
                RoundedRectangle(cornerRadius: 32)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 4)
            )
            
            Button(action: {
                newPost.mediaUrl = nil
                newPost.mediaType = nil
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.5))
                            .background(.ultraThinMaterial)
                    )
            }
            .buttonStyle(ScaleButtonStyle())
            .padding(16)
        }
    }
    
    private var aiToolsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("AI Visualization Tools")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundColor(.gray)
                    .textCase(.uppercase)
                    .tracking(2)
            }
            
            HStack(spacing: 12) {
                Button(action: handleAIMagicImage) {
                    VStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.primary.opacity(0.1))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.primary)
                            )
                        
                        Text("Gen Image")
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .foregroundColor(.primary.opacity(0.9))
                            .textCase(.uppercase)
                            .tracking(1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    )
                }
                .buttonStyle(ScaleButtonStyle())
                
                Button(action: handleAIMagicVideo) {
                    VStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.red.opacity(0.1))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "video.fill")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.red)
                            )
                        
                        Text("Gen Video")
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .foregroundColor(.red.opacity(0.9))
                            .textCase(.uppercase)
                            .tracking(1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color.red.opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    )
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 40)
                .fill(Color.gray.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private var bottomActions: some View {
        HStack {
            PhotosPicker(selection: $selectedPhotoItem, matching: .any(of: [.images, .videos])) {
                HStack(spacing: 8) {
                    Image(systemName: "paperclip")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Attach Media")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundColor(.primary)
                        .textCase(.uppercase)
                        .tracking(2)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.primary.opacity(0.1))
                )
            }
            .buttonStyle(ScaleButtonStyle())
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(Color.white)
    }
    
    // MARK: - Generation Overlay
    
    private var generationOverlay: some View {
        ZStack {
            Color.white.opacity(0.95)
                .background(.ultraThinMaterial)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
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
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.primary)
                }
                
                VStack(spacing: 8) {
                    Text("AI Magic in progress...")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(.primary.opacity(0.9))
                    
                    Text(generationMsg)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .opacity(0.8)
                }
            }
            .padding(32)
        }
    }
    
    // MARK: - Post Card Component
    
    private struct PostCard: View {
        let post: Post
        
        var body: some View {
            VStack(spacing: 0) {
                // Author header
                HStack {
                    HStack(spacing: 12) {
                        ZStack(alignment: .topLeading) {
                            AsyncImage(url: URL(string: post.authorAvatar)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Color.gray.opacity(0.3)
                            }
                            .frame(width: 44, height: 44)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            
                            if post.authorRole == "specialist" {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 20, height: 20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.primary)
                                            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.white, lineWidth: 2)
                                    )
                                    .offset(x: -4, y: -4)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 8) {
                                Text(post.authorName)
                                    .font(.system(size: 14, weight: .black, design: .rounded))
                                    .foregroundColor(.primary.opacity(0.9))
                                
                                if post.authorRole == "specialist" {
                                    Text("Specialist")
                                        .font(.system(size: 9, weight: .black, design: .rounded))
                                        .foregroundColor(.primary)
                                        .textCase(.uppercase)
                                        .tracking(2)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(
                                            Capsule()
                                                .fill(Color.primary.opacity(0.1))
                                        )
                                }
                            }
                            
                            Text(post.timestamp)
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundColor(.gray)
                                .textCase(.uppercase)
                                .tracking(2)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.gray)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(20)
                
                // Content
                VStack(alignment: .leading, spacing: 8) {
                    Text(post.title)
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundColor(.primary.opacity(0.9))
                        .tracking(-0.5)
                        .lineLimit(2)
                    
                    Text(post.content)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                        .lineSpacing(4)
                        .lineLimit(3)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                
                // Media
                if let mediaUrl = post.mediaUrl {
                    Group {
                        if post.mediaType == "video" {
                            VideoPlayerView(url: mediaUrl)
                        } else {
                            AsyncImage(url: URL(string: mediaUrl)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Color.gray.opacity(0.3)
                            }
                        }
                    }
                    .frame(maxHeight: 400)
                    .clipped()
                }
                
                Divider()
                    .padding(.horizontal, 20)
                
                // Actions
                HStack(spacing: 24) {
                    Button(action: {}) {
                        HStack(spacing: 6) {
                            Image(systemName: "heart")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.gray)
                            
                            Text("\(post.likes)")
                                .font(.system(size: 12, weight: .black, design: .rounded))
                                .foregroundColor(.gray)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {}) {
                        HStack(spacing: 6) {
                            Image(systemName: "bubble.right")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.gray)
                            
                            Text("\(post.comments)")
                                .font(.system(size: 12, weight: .black, design: .rounded))
                                .foregroundColor(.gray)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(16)
            }
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
    }
    
    // MARK: - Helper Views
    
    private struct VideoPlayerView: View {
        let url: String
        
        var body: some View {
            ZStack {
                Color.black
                
                if URL(string: url) != nil {
                    // Note: In a real app, you'd use AVPlayerViewController
                    // For now, we'll show a placeholder
                    VStack {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("Video")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            .frame(height: 300)
        }
    }
    
    // MARK: - Computed Properties
    
    private var canPost: Bool {
        !newPost.title.isEmpty && !newPost.content.isEmpty
    }
    
    // MARK: - Actions
    
    private func initializePosts() {
        posts = [
            Post(
                id: "ai-vid-1",
                authorId: "coach-maya",
                authorName: "Coach Maya",
                authorAvatar: "https://images.unsplash.com/photo-1594824476967-48c8b964273f?q=80&w=200&h=200&auto=format&fit=crop",
                authorRole: "specialist",
                title: "AI Visualization: Calming Morning Routine",
                content: "I used AI to generate this supportive visualization of a sensory-friendly morning. I hope this helps your children transition smoothly into their day!",
                mediaUrl: "https://www.w3schools.com/html/mov_bbb.mp4",
                mediaType: "video",
                timestamp: "Just now",
                likes: 142,
                comments: 24,
                tags: ["AI Generated", "Visual Support"]
            ),
            Post(
                id: "ai-img-1",
                authorId: "alex-p",
                authorName: "Alex Rivera",
                authorAvatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=Alex",
                authorRole: "parent",
                title: "Neuro-Affirming Space Design",
                content: "Sharing an AI-generated layout for a sensory-friendly bedroom. Trying to find the best way to reduce overload for Andy!",
                mediaUrl: "https://images.unsplash.com/photo-1588075592446-265fd1e6e76f?q=80&w=800&h=800&auto=format&fit=crop",
                mediaType: "image",
                timestamp: "1h ago",
                likes: 98,
                comments: 12,
                tags: ["Design", "Sensory"]
            )
        ]
    }
    
    private func handleCreatePost() {
        guard canPost else { return }
        
        let post = Post(
            id: UUID().uuidString,
            authorId: "u-me",
            authorName: isExpert ? "Dr. Sarah (Expert)" : "Alex Rivera (Me)",
            authorAvatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=\(isExpert ? "Expert" : "Alex")",
            authorRole: isExpert ? "specialist" : "parent",
            title: newPost.title,
            content: newPost.content,
            mediaUrl: newPost.mediaUrl,
            mediaType: newPost.mediaType,
            timestamp: "Just now",
            likes: 0,
            comments: 0,
            tags: isExpert ? ["ExpertInsight"] : ["Community"]
        )
        
        posts.insert(post, at: 0)
        newPost = PartialPost()
        view = .feed
    }
    
    private func handleFileChange(item: PhotosPickerItem) {
        Task {
            if (try? await item.loadTransferable(type: Data.self)) != nil {
                // In a real app, you'd save this to a temporary location
                // For now, we'll use a placeholder
                await MainActor.run {
                    newPost.mediaUrl = "https://images.unsplash.com/photo-1588075592446-265fd1e6e76f?q=80&w=800&h=800&auto=format&fit=crop"
                    newPost.mediaType = "image"
                }
            }
        }
    }
    
    private func handleAIMagicImage() {
        guard !newPost.title.isEmpty || !newPost.content.isEmpty else {
            // TODO: Show alert
            return
        }
        
        isGenerating = true
        generationMsg = "Designing a therapeutic visual for you..."
        
        Task {
            do {
                let prompt = "\(newPost.title) \(newPost.content)"
                let imgUrl = try await generateCommunityImage(prompt)
                
                await MainActor.run {
                    newPost.mediaUrl = imgUrl
                    newPost.mediaType = "image"
                    isGenerating = false
                }
            } catch {
                await MainActor.run {
                    isGenerating = false
                    // TODO: Show error alert
                }
            }
        }
    }
    
    private func handleAIMagicVideo() {
        guard !newPost.title.isEmpty || !newPost.content.isEmpty else {
            // TODO: Show alert
            return
        }
        
        isGenerating = true
        
        Task {
            do {
                let prompt = "\(newPost.title) \(newPost.content)"
                let videoUrl = try await generateCommunityVideo(prompt) { msg in
                    Task { @MainActor in
                        generationMsg = msg
                    }
                }
                
                await MainActor.run {
                    newPost.mediaUrl = videoUrl
                    newPost.mediaType = "video"
                    isGenerating = false
                }
            } catch {
                await MainActor.run {
                    isGenerating = false
                    // TODO: Show error alert
                }
            }
        }
    }
}

// MARK: - Supporting Types

struct PartialPost {
    var title: String = ""
    var content: String = ""
    var mediaUrl: String? = nil
    var mediaType: String? = nil
    var tags: [String] = []
}

// MARK: - View Extensions

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    CommunityView(isExpert: false)
}
