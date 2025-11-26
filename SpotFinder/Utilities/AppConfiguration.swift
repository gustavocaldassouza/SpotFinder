//
//  AppConfiguration.swift
//  SpotFinder
//
//  Created by Gustavo Caldas de Souza on 2025-11-17.
//

import Foundation

enum AppConfiguration {
    static var apiBaseURL: String {
        #if DEBUG
        return "http://localhost:3000"
        #else
        return AppEnvironment.apiBaseURL
        #endif
    }
    
    static var wsBaseURL: String {
        #if DEBUG
        return "ws://localhost:3000"
        #else
        return AppEnvironment.wsBaseURL
        #endif
    }
    
    static let nearbyRadius: Double = 500
    static let reportExpirationTime: TimeInterval = 3600
}
