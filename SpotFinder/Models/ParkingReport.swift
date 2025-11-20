//
//  ParkingReport.swift
//  SpotFinder
//
//  Created by Gustavo Caldas de Souza on 2025-11-17.
//

import Foundation
import CoreLocation

enum ReportStatus: String, Codable, Sendable {
    case available
    case taken
}

struct ParkingReport: Codable, Identifiable, Sendable, Hashable {
    let id: String
    let latitude: Double
    let longitude: Double
    let description: String?
    let status: ReportStatus
    let createdAt: Date
    let expiresAt: Date
    let accuracyRating: Double
    let totalRatings: Int
    let isActive: Bool
    let createdAgo: String?
    let distance: Double?
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var timeAgoString: String {
        if let createdAgo = createdAgo {
            return createdAgo
        }
        
        let now = Date()
        let interval = now.timeIntervalSince(createdAt)
        
        let minutes = Int(interval / 60)
        let hours = Int(interval / 3600)
        let days = Int(interval / 86400)
        
        if minutes < 1 {
            return "Just now"
        } else if minutes < 60 {
            return "\(minutes) min ago"
        } else if hours < 24 {
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        } else {
            return "\(days) day\(days == 1 ? "" : "s") ago"
        }
    }
    
    var isExpired: Bool {
        return !isActive || Date() > expiresAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id, latitude, longitude, description, status, createdAt, expiresAt
        case accuracyRating, totalRatings, isActive, createdAgo, distance
    }
    
    init(id: String, latitude: Double, longitude: Double, description: String?, status: ReportStatus, 
         createdAt: Date, expiresAt: Date, accuracyRating: Double, totalRatings: Int, 
         isActive: Bool, createdAgo: String? = nil, distance: Double? = nil) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.description = description
        self.status = status
        self.createdAt = createdAt
        self.expiresAt = expiresAt
        self.accuracyRating = accuracyRating
        self.totalRatings = totalRatings
        self.isActive = isActive
        self.createdAgo = createdAgo
        self.distance = distance
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ParkingReport, rhs: ParkingReport) -> Bool {
        lhs.id == rhs.id
    }
}

struct CreateParkingReportRequest: Codable, Sendable {
    let latitude: Double
    let longitude: Double
    let description: String?
    let status: ReportStatus
}

struct RateReportRequest: Codable, Sendable {
    let isUpvote: Bool
}
