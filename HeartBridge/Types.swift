//
//  Types.swift
//  HeartBridge
//
//  Created by Phoebe Tang on 1/21/26.
//

import Foundation

enum AppTab: String, CaseIterable {
    case predictive = "PREDICTIVE"
    case video = "VIDEO"
    case community = "COMMUNITY"
    case resources = "RESOURCES"
    case sessions = "SESSIONS"
}

enum UserRole: String, Codable {
    case parent = "parent"
    case expert = "expert"
}

enum SubscriptionTier: String, Codable {
    case free = "free"
    case core = "core"
    case premium = "premium"
    case plus = "plus"
    case individual = "individual"
    case bundle = "bundle"
}

struct ChildProfile: Codable, Identifiable {
    let id: UUID
    var name: String
    var parentName: String
    var role: UserRole
    var points: Int
    var subscriptionTier: SubscriptionTier
    var email: String?
    var diagnosis: [String]?
    var severity: String?
    var currentTherapies: [String]?
    var goals: [String]?
    var gender: String?
    var age: String?
    
    init(
        id: UUID = UUID(),
        name: String,
        parentName: String,
        role: UserRole,
        points: Int = 0,
        subscriptionTier: SubscriptionTier = .free,
        email: String? = nil,
        diagnosis: [String]? = nil,
        severity: String? = nil,
        currentTherapies: [String]? = nil,
        goals: [String]? = nil,
        gender: String? = nil,
        age: String? = nil
    ) {
        self.id = id
        self.name = name
        self.parentName = parentName
        self.role = role
        self.points = points
        self.subscriptionTier = subscriptionTier
        self.email = email
        self.diagnosis = diagnosis
        self.severity = severity
        self.currentTherapies = currentTherapies
        self.goals = goals
        self.gender = gender
        self.age = age
    }
}

struct Appointment: Codable, Identifiable {
    let id: String
    var expertId: String?
    var expertName: String?
    var expertRole: String?
    var expertImg: String?
    var date: String
    var time: String
    var clientName: String?
    var title: String?
    var appointmentDate: Date?
    var description: String?
    
    init(
        id: String = UUID().uuidString,
        expertId: String? = nil,
        expertName: String? = nil,
        expertRole: String? = nil,
        expertImg: String? = nil,
        date: String,
        time: String,
        clientName: String? = nil,
        title: String? = nil,
        appointmentDate: Date? = nil,
        description: String? = nil
    ) {
        self.id = id
        self.expertId = expertId
        self.expertName = expertName
        self.expertRole = expertRole
        self.expertImg = expertImg
        self.date = date
        self.time = time
        self.clientName = clientName
        self.title = title
        self.appointmentDate = appointmentDate
        self.description = description
    }
}

struct Message: Identifiable, Codable {
    let id: String
    let text: String
    let sender: String // "user" or "nomi"
    let timestamp: Date
    
    init(id: String = UUID().uuidString, text: String, sender: String, timestamp: Date = Date()) {
        self.id = id
        self.text = text
        self.sender = sender
        self.timestamp = timestamp
    }
}

struct Post: Identifiable, Codable {
    let id: String
    let authorId: String
    var authorName: String
    var authorAvatar: String
    var authorRole: String // "parent" or "specialist"
    var title: String
    var content: String
    var mediaUrl: String?
    var mediaType: String? // "image" or "video"
    var timestamp: String
    var likes: Int
    var comments: Int
    var tags: [String]
    
    init(
        id: String = UUID().uuidString,
        authorId: String,
        authorName: String,
        authorAvatar: String,
        authorRole: String,
        title: String,
        content: String,
        mediaUrl: String? = nil,
        mediaType: String? = nil,
        timestamp: String,
        likes: Int = 0,
        comments: Int = 0,
        tags: [String] = []
    ) {
        self.id = id
        self.authorId = authorId
        self.authorName = authorName
        self.authorAvatar = authorAvatar
        self.authorRole = authorRole
        self.title = title
        self.content = content
        self.mediaUrl = mediaUrl
        self.mediaType = mediaType
        self.timestamp = timestamp
        self.likes = likes
        self.comments = comments
        self.tags = tags
    }
}

