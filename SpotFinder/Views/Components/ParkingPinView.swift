//
//  ParkingPinView.swift
//  SpotFinder
//
//  Created by Gustavo Caldas de Souza on 2025-11-17.
//

import SwiftUI

struct ParkingPinView: View {
    let report: ParkingReport
    
    var body: some View {
        ZStack {
            Circle()
                .fill(pinColor)
                .frame(width: 40, height: 40)
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
            
            Image(systemName: iconName)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)
        }
        .opacity(report.isExpired ? 0.5 : 1.0)
    }
    
    private var pinColor: Color {
        if report.isExpired {
            return .gray
        }
        
        switch report.status {
        case .available:
            return .blue
        case .taken:
            return .red
        }
    }
    
    private var iconName: String {
        switch report.status {
        case .available:
            return "p.circle.fill"
        case .taken:
            return "xmark.circle.fill"
        }
    }
}

#Preview {
    HStack(spacing: 20) {
        ParkingPinView(report: ParkingReport(
            id: "1",
            latitude: 37.7749,
            longitude: -122.4194,
            description: "Near coffee shop",
            status: .available,
            createdAt: Date(),
            expiresAt: Date().addingTimeInterval(3600),
            accuracyRating: 0.8,
            totalRatings: 5,
            isActive: true
        ))
        
        ParkingPinView(report: ParkingReport(
            id: "2",
            latitude: 37.7749,
            longitude: -122.4194,
            description: nil,
            status: .taken,
            createdAt: Date(),
            expiresAt: Date().addingTimeInterval(3600),
            accuracyRating: -0.3,
            totalRatings: 2,
            isActive: true
        ))
        
        ParkingPinView(report: ParkingReport(
            id: "3",
            latitude: 37.7749,
            longitude: -122.4194,
            description: "Expired spot",
            status: .available,
            createdAt: Date().addingTimeInterval(-7200),
            expiresAt: Date().addingTimeInterval(-1),
            accuracyRating: 0,
            totalRatings: 0,
            isActive: false
        ))
    }
    .padding()
}
