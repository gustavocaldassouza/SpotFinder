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
                        Text(report.streetName)
                            .font(.headline)
                            .lineLimit(1)
                        
                        if let crossStreets = report.crossStreets {
                            Text(crossStreets)
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
                    Text("\(report.upvotes)")
                }
                .font(.caption)
                .foregroundStyle(.green)
            }
            .buttonStyle(.plain)
            
            Button {
                onRate(false)
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "hand.thumbsdown.fill")
                    Text("\(report.downvotes)")
                }
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
                    streetName: "Market Street",
                    crossStreets: "5th & 6th St",
                    status: .available,
                    createdAt: Date().addingTimeInterval(-120),
                    upvotes: 5,
                    downvotes: 1
                ),
                onTap: {},
                onRate: { _ in }
            )
            
            ReportCard(
                report: ParkingReport(
                    id: "2",
                    latitude: 37.7749,
                    longitude: -122.4194,
                    streetName: "Mission Street",
                    crossStreets: nil,
                    status: .taken,
                    createdAt: Date().addingTimeInterval(-3600),
                    upvotes: 2,
                    downvotes: 3
                ),
                onTap: {},
                onRate: { _ in }
            )
        }
    }
}
