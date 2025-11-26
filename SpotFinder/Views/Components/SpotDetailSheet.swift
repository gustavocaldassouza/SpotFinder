//
//  SpotDetailSheet.swift
//  SpotFinder
//
//  Created by Gustavo Caldas de Souza on 2025-11-20.
//

import SwiftUI
import MapKit

struct SpotDetailSheet: View {
    let report: ParkingReport
    let viewModel: ParkingReportViewModel
    @Environment(\.dismiss) var dismiss
    @State private var isUpdating = false
    @State private var isRating = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Status Badge
                    HStack {
                        Image(systemName: report.status == .available ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(report.status == .available ? .green : .red)
                        Text(report.status == .available ? "Available" : "Taken")
                            .font(.headline)
                            .foregroundColor(report.status == .available ? .green : .red)
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Time Information
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Reported", systemImage: "clock")
                            .font(.headline)
                        Text(formatDate(report.createdAt))
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Divider()
                        Label("Expires", systemImage: "hourglass")
                            .font(.headline)
                        Text(formatDate(report.expiresAt))
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Description
                    if let description = report.description, !description.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Description", systemImage: "text.alignleft")
                                .font(.headline)
                            Text(description)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    // Accuracy Rating
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Accuracy", systemImage: "star.fill")
                            .font(.headline)
                        HStack {
                            Text("\(Int(report.accuracyRating * 100))%")
                                .font(.title2)
                                .bold()
                            Text("based on \(report.totalRatings) rating\(report.totalRatings == 1 ? "" : "s")")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Location
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Location", systemImage: "mappin.circle")
                            .font(.headline)
                        Text("Lat: \(report.latitude, specifier: "%.4f")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("Lon: \(report.longitude, specifier: "%.4f")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Actions
                    VStack(spacing: 12) {
                        if report.status == .available {
                            Button {
                                Task {
                                    await markAsNotAvailable()
                                }
                            } label: {
                                if isUpdating {
                                    ProgressView()
                                        .frame(maxWidth: .infinity)
                                } else {
                                    Label("Mark as Not Available", systemImage: "xmark.circle")
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.red)
                            .disabled(isUpdating)
                        }
                        
                        // Rating buttons
                        HStack(spacing: 16) {
                            Button {
                                Task {
                                    await rateReport(isUpvote: true)
                                }
                            } label: {
                                if isRating {
                                    ProgressView()
                                        .frame(maxWidth: .infinity)
                                } else {
                                    Label("Accurate", systemImage: "hand.thumbsup")
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .buttonStyle(.bordered)
                            .tint(.green)
                            .disabled(isRating || isUpdating)
                            
                            Button {
                                Task {
                                    await rateReport(isUpvote: false)
                                }
                            } label: {
                                if isRating {
                                    ProgressView()
                                        .frame(maxWidth: .infinity)
                                } else {
                                    Label("Inaccurate", systemImage: "hand.thumbsdown")
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .buttonStyle(.bordered)
                            .tint(.orange)
                            .disabled(isRating || isUpdating)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Spot Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func markAsNotAvailable() async {
        isUpdating = true
        defer { isUpdating = false }
        
        // Create a report at the same location marking it as taken
        let success = await viewModel.createReport(
            latitude: report.latitude,
            longitude: report.longitude,
            description: "Updated: Spot no longer available",
            status: .taken
        )
        
        if success {
            dismiss()
        }
    }
    
    private func rateReport(isUpvote: Bool) async {
        isRating = true
        defer { isRating = false }
        
        await viewModel.rateReport(report.id, isUpvote: isUpvote)
        
        // Delay slightly to let the user see the update
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        dismiss()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    SpotDetailSheet(
        report: ParkingReport(
            id: "1",
            latitude: 45.5017,
            longitude: -73.5673,
            description: "Near the library",
            status: .available,
            createdAt: Date().addingTimeInterval(-3600),
            expiresAt: Date().addingTimeInterval(7200),
            accuracyRating: 0.85,
            totalRatings: 12,
            isActive: true
        ),
        viewModel: ParkingReportViewModel()
    )
}
