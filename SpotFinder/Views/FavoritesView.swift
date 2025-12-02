//
//  FavoritesView.swift
//  SpotFinder
//
//  Created by Gustavo Caldas de Souza on 2025-12-01.
//

import SwiftUI
import MapKit

struct FavoritesView: View {
    @Environment(\.dismiss) var dismiss
    @State private var favoritesManager = FavoritesManager.shared
    @State private var selectedReport: ParkingReport?
    @State private var showingSpotDetail = false
    
    var onSelectSpot: ((ParkingReport) -> Void)?
    
    var body: some View {
        NavigationStack {
            Group {
                if favoritesManager.isLoading {
                    ProgressView("Loading favorites...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if favoritesManager.favorites.isEmpty {
                    emptyState
                } else {
                    favoritesList
                }
            }
            .navigationTitle("Saved Spots")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .task {
                await favoritesManager.fetchFavorites()
            }
            .sheet(isPresented: $showingSpotDetail) {
                if let report = selectedReport {
                    SpotDetailSheet(
                        report: report,
                        viewModel: ParkingReportViewModel()
                    )
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "bookmark.slash")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Saved Spots")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Bookmark parking spots to quickly access them later.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var favoritesList: some View {
        List {
            ForEach(favoritesManager.favorites) { report in
                FavoriteRow(report: report) {
                    // Navigate to spot on map
                    onSelectSpot?(report)
                    dismiss()
                } onShowDetail: {
                    selectedReport = report
                    showingSpotDetail = true
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        Task {
                            await favoritesManager.removeFavorite(report.id)
                        }
                    } label: {
                        Label("Remove", systemImage: "bookmark.slash")
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .refreshable {
            await favoritesManager.fetchFavorites()
        }
    }
}

struct FavoriteRow: View {
    let report: ParkingReport
    let onNavigate: () -> Void
    let onShowDetail: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Status indicator
            Circle()
                .fill(report.status == .available ? Color.green : Color.red)
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 4) {
                if let description = report.description, !description.isEmpty {
                    Text(description)
                        .font(.headline)
                        .lineLimit(1)
                } else {
                    Text(report.status == .available ? "Available Spot" : "Taken Spot")
                        .font(.headline)
                }
                
                HStack(spacing: 8) {
                    Label(report.timeAgoString, systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if report.totalRatings > 0 {
                        Label("\(report.totalRatings)", systemImage: "hand.thumbsup")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Text("Lat: \(report.latitude, specifier: "%.4f"), Lon: \(report.longitude, specifier: "%.4f")")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(spacing: 8) {
                Button {
                    onNavigate()
                } label: {
                    Image(systemName: "location.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
                
                Button {
                    onShowDetail()
                } label: {
                    Image(systemName: "info.circle")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
        .opacity(report.isExpired ? 0.6 : 1.0)
        .overlay {
            if report.isExpired {
                HStack {
                    Spacer()
                    Text("Expired")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange)
                        .cornerRadius(4)
                }
            }
        }
    }
}

#Preview {
    FavoritesView()
}
