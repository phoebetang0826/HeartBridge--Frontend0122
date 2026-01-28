//
//  APIClient.swift
//  HeartBridge
//
//  Created by Phoebe Tang on 1/21/26.
//

import Foundation

final class APIClient {
    static let shared = APIClient()

    private let session: URLSession
    private let tokenStore: TokenStore
    private let baseURL: URL

    init(
        baseURL: URL = Config.baseURL,
        session: URLSession = .shared,
        tokenStore: TokenStore = KeychainTokenStore.shared
    ) {
        self.baseURL = baseURL
        self.session = session
        self.tokenStore = tokenStore
    }

    func get<T: Decodable>(_ path: String) async throws -> T {
        try await request(path: path, method: "GET", body: Optional<Data>.none)
    }

    func post<T: Decodable, Body: Encodable>(_ path: String, body: Body) async throws -> T {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(body)
        return try await request(path: path, method: "POST", body: data)
    }

    private func request<T: Decodable>(
        path: String,
        method: String,
        body: Data?
    ) async throws -> T {
        guard let url = URL(string: path, relativeTo: baseURL) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let body = body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        if let token = tokenStore.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorResponse = try? decoder.decode(ErrorResponse.self, from: data) {
                throw APIError.server(errorResponse.error)
            }
            throw APIError.server("Server error (\(httpResponse.statusCode))")
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decoding(error.localizedDescription)
        }
    }
}

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case decoding(String)
    case server(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .invalidResponse:
            return "Invalid server response."
        case .decoding(let message):
            return "Failed to decode response: \(message)"
        case .server(let message):
            return message
        }
    }
}

