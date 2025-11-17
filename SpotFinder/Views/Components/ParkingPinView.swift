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
            streetName: "Market St",
            crossStreets: "5th St",
            status: .available,
            createdAt: Date(),
            upvotes: 5,
            downvotes: 1
        ))
        
        ParkingPinView(report: ParkingReport(
            id: "2",
            latitude: 37.7749,
            longitude: -122.4194,
            streetName: "Mission St",
            crossStreets: "6th St",
            status: .taken,
            createdAt: Date(),
            upvotes: 2,
            downvotes: 3
        ))
        
        ParkingPinView(report: ParkingReport(
            id: "3",
            latitude: 37.7749,
            longitude: -122.4194,
            streetName: "Valencia St",
            crossStreets: "16th St",
            status: .available,
            createdAt: Date().addingTimeInterval(-7200),
            upvotes: 0,
            downvotes: 0
        ))
    }
    .padding()
}
