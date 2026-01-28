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
    let id: String?
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
}

struct ProfileResponse: Codable {
    let user: APIUser
}

struct VideosResponse: Codable {
    let videos: [VideoItem]
}

struct VideoItem: Codable {
    let id: String?
    let title: String?
    let url: String?
    let thumbnailUrl: String?
    let createdAt: String?
}

// MARK: - Error Response

struct ErrorResponse: Codable {
    let error: String
}

