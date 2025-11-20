//
//  ReportCard.swift
//  SpotFinder
//
//  Created by Gustavo Caldas de Souza on 2025-11-17.
//

import SwiftUI

struct ReportCard: View {
    let report: ParkingReport
    let onTap: () -> Void
    let onRate: (Bool) -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: statusIcon)
                        .foregroundStyle(statusColor)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(statusText)
                            .font(.headline)
                            .lineLimit(1)
                        
                        if let description = report.description, !description.isEmpty {
                            Text(description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                    
                    Spacer()
                }
                
                HStack {
                    Label(report.timeAgoString, systemImage: "clock")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    ratingButtons
                }
            }
            .padding()
            .frame(width: 280)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            .overlay {
                if report.isExpired {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.gray.opacity(0.5), lineWidth: 2)
                }
            }
        }
        .buttonStyle(.plain)
    }
    
    private var statusIcon: String {
        switch report.status {
        case .available:
            return "checkmark.circle.fill"
        case .taken:
            return "xmark.circle.fill"
        }
    }
    
    private var statusText: String {
        switch report.status {
        case .available:
            return "Spot Available"
        case .taken:
            return "Spot Taken"
        }
    }
    
    private var statusColor: Color {
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
    
    private var ratingButtons: some View {
        HStack(spacing: 12) {
            Button {
                onRate(true)
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "hand.thumbsup.fill")
                    Text("\(report.totalRatings)")
                }
                .font(.caption)
                .foregroundStyle(report.accuracyRating > 0 ? .green : .gray)
            }
            .buttonStyle(.plain)
            
            if report.accuracyRating != 0 {
                Text(String(format: "%.1f", report.accuracyRating))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Button {
                onRate(false)
            } label: {
                Image(systemName: "hand.thumbsdown.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    ScrollView(.horizontal) {
        HStack {
            ReportCard(
                report: ParkingReport(
                    id: "1",
                    latitude: 37.7749,
                    longitude: -122.4194,
                    description: "Near the coffee shop",
                    status: .available,
                    createdAt: Date().addingTimeInterval(-120),
                    expiresAt: Date().addingTimeInterval(3600),
                    accuracyRating: 0.8,
                    totalRatings: 5,
                    isActive: true
                ),
                onTap: {},
                onRate: { _ in }
            )
            
            ReportCard(
                report: ParkingReport(
                    id: "2",
                    latitude: 37.7749,
                    longitude: -122.4194,
                    description: nil,
                    status: .taken,
                    createdAt: Date().addingTimeInterval(-3600),
                    expiresAt: Date().addingTimeInterval(-1),
                    accuracyRating: -0.5,
                    totalRatings: 3,
                    isActive: false
                ),
                onTap: {},
                onRate: { _ in }
            )
        }
    }
}
