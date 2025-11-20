//
//  AppConfiguration.swift
//  SpotFinder
//
//  Created by Gustavo Caldas de Souza on 2025-11-17.
//

import Foundation

enum AppConfiguration {
    static var apiBaseURL: String {
        // In production, you can read this from Info.plist or environment variables
        #if DEBUG
        return "http://100.85.203.36:3000"
        #else
        return "https://your-production-api.com"
        #endif
    }
    
    static var wsBaseURL: String {
        #if DEBUG
        return "ws://100.85.203.36:3000"
        #else
        return "wss://your-production-api.com"
        #endif
    }
    
    static let nearbyRadius: Double = 500 // meters
    static let reportExpirationTime: TimeInterval = 3600 // 1 hour
}
