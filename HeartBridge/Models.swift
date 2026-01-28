//
//  Models.swift
//  HeartBridge
//
//  Created by Phoebe Tang on 1/21/26.
//

import Foundation

// MARK: - Auth Requests

struct StartLoginRequest: Codable {
    let userType: String
    let name: String
    let childName: String?
    let phone: String

    enum CodingKeys: String, CodingKey {
        case userType = "user_type"
        case name
        case childName = "child_name"
        case phone
    }
}

struct VerifyCodeRequest: Codable {
    let phone: String
    let code: String
}

struct LoginRequest: Codable {
    let phone: String
}

// MARK: - Auth Responses

struct StartLoginResponse: Codable {
    let message: String
    let code: String?
}

struct VerifyCodeResponse: Codable {
    let message: String
    let token: String
    let user: APIUser
}

struct LoginResponse: Codable {
    let message: String
    let token: String
    let user: APIUser
}

// MARK: - API Models

struct APIUser: Codable {
    let id: Int?
    let name: String?
    let userType: String?
    let role: String?
    let childName: String?
    let phone: String?
    let subscriptionTier: String?
    let points: Int?
    let email: String?
    let diagnosis: [String]?
    let severity: String?
    let currentTherapies: [String]?
    let goals: [String]?
    let gender: String?
    let age: String?
    let createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case phone
        case userType = "user_type"
        case role
        case childName = "child_name"
        case subscriptionTier = "subscription_tier"
        case points
        case email
        case diagnosis
        case severity
        case currentTherapies = "current_therapies"
        case goals
        case gender
        case age
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct ProfileResponse: Codable {
    let user: APIUser?
}

struct VideosResponse: Codable {
    let videos: [VideoItem]
}

struct VideoItem: Codable {
    let id: Int?
    let title: String?
    let url: String?
    let thumbnailUrl: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case url
        case thumbnailUrl = "thumbnail_url"
        case createdAt = "created_at"
    }
}

// MARK: - Error Response

struct ErrorResponse: Codable {
    let error: String
}

