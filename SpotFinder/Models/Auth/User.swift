//
//  User.swift
//  SpotFinder
//
//  Created for authentication feature
//

import Foundation

struct User: Codable, Sendable {
    let id: String
    let email: String
    let firstName: String?
    let lastName: String?
    let avatarUrl: String?
    let createdAt: Date
    
    var displayName: String {
        if let firstName = firstName, let lastName = lastName {
            return "\(firstName) \(lastName)"
        } else if let firstName = firstName {
            return firstName
        } else {
            return email
        }
    }
}

struct AuthResponse: Codable, Sendable {
    let accessToken: String
    let refreshToken: String
    let user: User
}

struct SignUpRequest: Codable, Sendable {
    let email: String
    let password: String
    let firstName: String?
    let lastName: String?
}

struct SignInRequest: Codable, Sendable {
    let email: String
    let password: String
}

struct RefreshTokenRequest: Codable, Sendable {
    let refreshToken: String
}
