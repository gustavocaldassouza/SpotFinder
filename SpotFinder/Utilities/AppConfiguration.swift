//
//  AppConfiguration.swift
//  SpotFinder
//
//  Created by Gustavo Caldas de Souza on 2025-11-17.
//

import Foundation

enum AppConfiguration {
    // Set to true to use local development server, false for production
    private static let useLocalServer = false
    
    static var apiBaseURL: String {
        if useLocalServer {
            return "http://localhost:3000"
        } else {
            return AppEnvironment.apiBaseURL
        }
    }
    
    static var wsBaseURL: String {
        if useLocalServer {
            return "ws://localhost:3000"
        } else {
            return AppEnvironment.wsBaseURL
        }
    }
    
    static let nearbyRadius: Double = 500
    static let reportExpirationTime: TimeInterval = 3600
}
