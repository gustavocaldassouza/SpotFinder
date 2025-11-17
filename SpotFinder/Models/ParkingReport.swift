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
    let streetName: String
    let crossStreets: String?
    let status: ReportStatus
    let createdAt: Date
    let upvotes: Int
    let downvotes: Int
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var timeAgoString: String {
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
        let now = Date()
        let interval = now.timeIntervalSince(createdAt)
        return interval > 3600 // Expired after 1 hour
    }
    
    enum CodingKeys: String, CodingKey {
        case id, latitude, longitude, streetName, crossStreets, status, createdAt, upvotes, downvotes
    }
    
    init(id: String, latitude: Double, longitude: Double, streetName: String, crossStreets: String?, status: ReportStatus, createdAt: Date, upvotes: Int, downvotes: Int) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.streetName = streetName
        self.crossStreets = crossStreets
        self.status = status
        self.createdAt = createdAt
        self.upvotes = upvotes
        self.downvotes = downvotes
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ParkingReport, rhs: ParkingReport) -> Bool {
        lhs.id == rhs.id
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)
        streetName = try container.decode(String.self, forKey: .streetName)
        crossStreets = try container.decodeIfPresent(String.self, forKey: .crossStreets)
        status = try container.decode(ReportStatus.self, forKey: .status)
        upvotes = try container.decode(Int.self, forKey: .upvotes)
        downvotes = try container.decode(Int.self, forKey: .downvotes)
        
        // Handle date decoding
        if let dateString = try? container.decode(String.self, forKey: .createdAt) {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = formatter.date(from: dateString) {
                createdAt = date
            } else {
                // Fallback without fractional seconds
                formatter.formatOptions = [.withInternetDateTime]
                createdAt = formatter.date(from: dateString) ?? Date()
            }
        } else {
            createdAt = Date()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(streetName, forKey: .streetName)
        try container.encodeIfPresent(crossStreets, forKey: .crossStreets)
        try container.encode(status, forKey: .status)
        try container.encode(upvotes, forKey: .upvotes)
        try container.encode(downvotes, forKey: .downvotes)
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        try container.encode(formatter.string(from: createdAt), forKey: .createdAt)
    }
}

struct CreateParkingReportRequest: Codable, Sendable {
    let latitude: Double
    let longitude: Double
    let streetName: String
    let crossStreets: String?
    let status: ReportStatus
}

struct RateReportRequest: Codable, Sendable {
    let isUpvote: Bool
}
