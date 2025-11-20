//
//  AppConfiguration.swift
//  SpotFinder
//
//  Created by Gustavo Caldas de Souza on 2025-11-17.
//

import Foundation

enum AppConfiguration {
    static var apiBaseURL: String {
        return "https://spotfinder-backend-6ad1bac86b75.herokuapp.com"
    }
    
    static var wsBaseURL: String {
        return "wss://spotfinder-backend-6ad1bac86b75.herokuapp.com"
    }
    
    static let nearbyRadius: Double = 500 // meters
    static let reportExpirationTime: TimeInterval = 3600 // 1 hour
}
