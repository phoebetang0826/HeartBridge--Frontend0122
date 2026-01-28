//
//  GeminiService.swift
//  HeartBridge
//
//  Created by Phoebe Tang on 1/21/26.
//

import Foundation

struct BehaviorReport: Codable {
    let summaryTitle: String
    let emotions: Emotions
    let behaviorPattern: String
    let correlation: String
    let whatToDo: [String]
    let expertRecommendation: String
}

struct Emotions: Codable {
    let happy: Int
    let neutral: Int
    let angry: Int
    let sad: Int
    let nervous: Int
}

struct ChatPart: Codable {
    var text: String?
    var inlineData: InlineData?
}

struct InlineData: Codable {
    let mimeType: String
    let data: String
}

struct ChatMessage: Codable {
    let role: String // "user" or "model"
    let parts: [ChatPart]
}

class GeminiService {
    static let shared = GeminiService()
    
    private init() {}
    
    func analyzeMedia(_ base64Data: String, mimeType: String) async throws -> BehaviorReport {
        // Simulate API call - replace with actual Gemini API implementation
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // Return mock data for now
        return BehaviorReport(
            summaryTitle: "Sensory Overload Response",
            emotions: Emotions(
                happy: 15,
                neutral: 25,
                angry: 40,
                sad: 10,
                nervous: 10
            ),
            behaviorPattern: "Child shows signs of sensory overload with increased agitation",
            correlation: "The behavior correlates with environmental noise levels and transition periods",
            whatToDo: [
                "Move to a quiet, dimly lit space immediately",
                "Offer deep pressure input (weighted blanket or firm hug)",
                "Use visual schedule to prepare for next transition",
                "Provide noise-canceling headphones if available"
            ],
            expertRecommendation: "Consider scheduling a sensory assessment to identify specific triggers and develop a personalized sensory diet."
        )
    }
    
    func getExpertConsultationResponse(
        _ messages: [ChatMessage],
        expertName: String,
        expertRole: String
    ) async throws -> String {
        // Simulate API call
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        
        // Return mock response
        return "I'm reviewing the video now. It seems like a sensory-related response. Let's discuss a plan to help manage these situations better."
    }
    
    func getNomiResponse(_ input: String, _ childName: String) async throws -> String {
        // Simulate API call
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Return contextual response based on input
        let lowerInput = input.lowercased()
        
        if lowerInput.contains("sensory") {
            return "For sensory-related concerns with \(childName), I recommend creating a sensory-friendly environment. Consider using weighted blankets, noise-canceling headphones, or a quiet corner space. Would you like specific strategies for managing sensory overload?"
        } else if lowerInput.contains("behavior") || lowerInput.contains("meltdown") {
            return "Behavioral challenges can be complex. For \(childName), tracking patterns and triggers is key. I suggest maintaining a behavior log to identify what happens before, during, and after incidents. This data helps create effective intervention strategies."
        } else if lowerInput.contains("specialist") || lowerInput.contains("therapist") {
            return "Finding the right specialist for \(childName) is important. I can help you connect with BCBA therapists, speech pathologists, or occupational therapists in your area. Would you like me to search for specialists near you?"
        } else {
            return "I'm here to support you and \(childName). I can help with behavioral insights, sensory strategies, finding resources, or connecting with specialists. What would you like to know more about?"
        }
    }
    
    func generateCommunityImage(_ prompt: String) async throws -> String {
        // Simulate API call
        try await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
        
        // Return mock image URL
        return "https://images.unsplash.com/photo-1588075592446-265fd1e6e76f?q=80&w=800&h=800&auto=format&fit=crop"
    }
    
    func generateCommunityVideo(_ prompt: String, progressCallback: ((String) -> Void)? = nil) async throws -> String {
        // Simulate API call with progress updates
        progressCallback?("Creating video frames...")
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        progressCallback?("Rendering animation...")
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        progressCallback?("Finalizing video...")
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Return mock video URL
        return "https://www.w3schools.com/html/mov_bbb.mp4"
    }
}

// Convenience functions matching React API
func analyzeMedia(_ base64Data: String, _ mimeType: String) async throws -> BehaviorReport {
    return try await GeminiService.shared.analyzeMedia(base64Data, mimeType: mimeType)
}

func getExpertConsultationResponse(
    _ messages: [ChatMessage],
    _ expertName: String,
    _ expertRole: String
) async throws -> String {
    return try await GeminiService.shared.getExpertConsultationResponse(
        messages,
        expertName: expertName,
        expertRole: expertRole
    )
}

func getNomiResponse(_ input: String, _ childName: String) async throws -> String {
    return try await GeminiService.shared.getNomiResponse(input, childName)
}

func generateCommunityImage(_ prompt: String) async throws -> String {
    return try await GeminiService.shared.generateCommunityImage(prompt)
}

func generateCommunityVideo(_ prompt: String, progressCallback: ((String) -> Void)? = nil) async throws -> String {
    return try await GeminiService.shared.generateCommunityVideo(prompt, progressCallback: progressCallback)
}

