//
//  AuthService.swift
//  SpotFinder
//
//  Authentication service for user management
//

import Foundation

actor AuthService {
    static let shared = AuthService()
    
    private let baseURL: String
    private let session: URLSession
    private let keychainManager = KeychainManager.shared
    
    private(set) var currentUser: User?
    private(set) var isAuthenticated = false
    
    private init() {
        self.baseURL = AppConfiguration.apiBaseURL
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: configuration)
        
        // Try to restore session on init
        Task {
            await restoreSession()
        }
    }
    
    // MARK: - Authentication
    
    func signUp(email: String, password: String, firstName: String?, lastName: String?) async throws -> User {
        let request = SignUpRequest(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName
        )
        
        let authResponse = try await performAuthRequest(endpoint: "/auth/signup", body: request)
        try await saveTokens(authResponse)
        
        self.currentUser = authResponse.user
        self.isAuthenticated = true
        
        return authResponse.user
    }
    
    func signIn(email: String, password: String) async throws -> User {
        let request = SignInRequest(email: email, password: password)
        let authResponse = try await performAuthRequest(endpoint: "/auth/signin", body: request)
        try await saveTokens(authResponse)
        
        self.currentUser = authResponse.user
        self.isAuthenticated = true
        
        return authResponse.user
    }
    
    func signOut() async throws {
        // Call backend to invalidate refresh token
        do {
            try await performAuthenticatedRequest(endpoint: "/auth/signout", method: "POST", body: Empty())
        } catch {
            // Continue with local signout even if backend call fails
            print("Backend signout failed, continuing with local signout: \(error)")
        }
        
        // Clear local session
        try await keychainManager.clearAll()
        self.currentUser = nil
        self.isAuthenticated = false
    }
    
    func refreshAccessToken() async throws -> String {
        guard let refreshToken = await keychainManager.getRefreshToken() else {
            throw AuthError.notAuthenticated
        }
        
        let request = RefreshTokenRequest(refreshToken: refreshToken)
        let authResponse = try await performAuthRequest(endpoint: "/auth/refresh", body: request)
        try await saveTokens(authResponse)
        
        self.currentUser = authResponse.user
        self.isAuthenticated = true
        
        return authResponse.accessToken
    }
    
    func getProfile() async throws -> User {
        let user: User = try await performAuthenticatedRequest(endpoint: "/auth/profile", method: "GET")
        self.currentUser = user
        return user
    }
    
    func getAccessToken() async -> String? {
        return await keychainManager.getAccessToken()
    }
    
    // MARK: - Private Methods
    
    private func restoreSession() async {
        guard let accessToken = await keychainManager.getAccessToken(),
              !accessToken.isEmpty else {
            return
        }
        
        do {
            let user = try await getProfile()
            self.currentUser = user
            self.isAuthenticated = true
        } catch {
            // Token might be expired, try to refresh
            do {
                _ = try await refreshAccessToken()
            } catch {
                // Failed to restore session
                try? await keychainManager.clearAll()
            }
        }
    }
    
    private func saveTokens(_ authResponse: AuthResponse) async throws {
        try await keychainManager.saveAccessToken(authResponse.accessToken)
        try await keychainManager.saveRefreshToken(authResponse.refreshToken)
    }
    
    private func performAuthRequest<T: Encodable, R: Decodable>(
        endpoint: String,
        body: T
    ) async throws -> R {
        let urlString = "\(baseURL)\(endpoint)"
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(body)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMessage = String(data: data, encoding: .utf8)
            throw APIError.serverError(httpResponse.statusCode, errorMessage)
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode(R.self, from: data)
    }
    
    private func performAuthenticatedRequest<T: Encodable, R: Decodable>(
        endpoint: String,
        method: String,
        body: T? = nil
    ) async throws -> R {
        guard let accessToken = await keychainManager.getAccessToken() else {
            throw AuthError.notAuthenticated
        }
        
        let urlString = "\(baseURL)\(endpoint)"
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        if let body = body {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            request.httpBody = try encoder.encode(body)
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        // If unauthorized, try to refresh token
        if httpResponse.statusCode == 401 {
            _ = try await refreshAccessToken()
            return try await performAuthenticatedRequest(endpoint: endpoint, method: method, body: body)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMessage = String(data: data, encoding: .utf8)
            throw APIError.serverError(httpResponse.statusCode, errorMessage)
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode(R.self, from: data)
    }
    
    private func performAuthenticatedRequest(
        endpoint: String,
        method: String
    ) async throws -> Void {
        let _: Empty = try await performAuthenticatedRequest(endpoint: endpoint, method: method, body: nil as Empty?)
    }
}

// MARK: - Helper Types

private struct Empty: Codable {}

enum AuthError: Error {
    case notAuthenticated
    case invalidCredentials
    case emailAlreadyExists
    case weakPassword
    
    var localizedDescription: String {
        switch self {
        case .notAuthenticated:
            return "Not authenticated"
        case .invalidCredentials:
            return "Invalid email or password"
        case .emailAlreadyExists:
            return "An account with this email already exists"
        case .weakPassword:
            return "Password must be at least 8 characters"
        }
    }
}
