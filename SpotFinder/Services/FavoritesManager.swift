//
//  FavoritesManager.swift
//  SpotFinder
//
//  Created by Gustavo Caldas de Souza on 2025-12-01.
//

import Foundation

@MainActor
@Observable
final class FavoritesManager {
    static let shared = FavoritesManager()
    
    private(set) var favoriteIds: Set<String> = []
    private(set) var favorites: [ParkingReport] = []
    private(set) var isLoading = false
    private(set) var error: APIError?
    
    private let apiClient: APIClient
    private let userDefaultsKey = "SpotFinder.FavoriteIds"
    
    private init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
        loadLocalFavorites()
    }
    
    // MARK: - Public Methods
    
    func isFavorite(_ reportId: String) -> Bool {
        favoriteIds.contains(reportId)
    }
    
    func toggleFavorite(_ report: ParkingReport) async {
        if isFavorite(report.id) {
            await removeFavorite(report.id)
        } else {
            await addFavorite(report)
        }
    }
    
    func addFavorite(_ report: ParkingReport) async {
        // Optimistically update local state
        favoriteIds.insert(report.id)
        if !favorites.contains(where: { $0.id == report.id }) {
            favorites.insert(report, at: 0)
        }
        saveLocalFavorites()
        
        // Sync with server
        do {
            try await apiClient.addFavorite(reportId: report.id)
        } catch {
            // Revert on failure
            favoriteIds.remove(report.id)
            favorites.removeAll { $0.id == report.id }
            saveLocalFavorites()
            self.error = error as? APIError ?? .unknown
        }
    }
    
    func removeFavorite(_ reportId: String) async {
        // Store for potential rollback
        let wasInFavorites = favoriteIds.contains(reportId)
        let removedReport = favorites.first { $0.id == reportId }
        
        // Optimistically update local state
        favoriteIds.remove(reportId)
        favorites.removeAll { $0.id == reportId }
        saveLocalFavorites()
        
        // Sync with server
        do {
            try await apiClient.removeFavorite(reportId: reportId)
        } catch {
            // Revert on failure
            if wasInFavorites {
                favoriteIds.insert(reportId)
            }
            if let report = removedReport {
                favorites.insert(report, at: 0)
            }
            saveLocalFavorites()
            self.error = error as? APIError ?? .unknown
        }
    }
    
    func fetchFavorites() async {
        isLoading = true
        error = nil
        
        do {
            let fetchedFavorites = try await apiClient.getFavorites()
            favorites = fetchedFavorites.sorted { $0.createdAt > $1.createdAt }
            favoriteIds = Set(fetchedFavorites.map { $0.id })
            saveLocalFavorites()
        } catch {
            self.error = error as? APIError ?? .unknown
        }
        
        isLoading = false
    }
    
    func syncFavoriteIds() async {
        do {
            let ids = try await apiClient.getFavoriteIds()
            favoriteIds = Set(ids)
            saveLocalFavorites()
        } catch {
            // Silently fail - use local cache
        }
    }
    
    func clearError() {
        error = nil
    }
    
    // MARK: - Local Storage
    
    private func loadLocalFavorites() {
        if let savedIds = UserDefaults.standard.array(forKey: userDefaultsKey) as? [String] {
            favoriteIds = Set(savedIds)
        }
    }
    
    private func saveLocalFavorites() {
        UserDefaults.standard.set(Array(favoriteIds), forKey: userDefaultsKey)
    }
    
    func clearLocalData() {
        favoriteIds.removeAll()
        favorites.removeAll()
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
}
