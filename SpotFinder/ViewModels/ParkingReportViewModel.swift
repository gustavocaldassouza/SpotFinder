//
//  ParkingReportViewModel.swift
//  SpotFinder
//
//  Created by Gustavo Caldas de Souza on 2025-11-17.
//

import Foundation
import CoreLocation
import Combine

@MainActor
@Observable
final class ParkingReportViewModel {
    private(set) var reports: [ParkingReport] = []
    private(set) var isLoading = false
    private(set) var error: APIError?
    
    private let apiClient: APIClient
    private var webSocketManager: WebSocketManager?
    private var cancellables = Set<AnyCancellable>()
    private var currentLocation: CLLocation?
    
    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }
    
    private func getOrCreateWebSocketManager() -> WebSocketManager {
        if let manager = webSocketManager {
            return manager
        }
        let manager = WebSocketManager()
        webSocketManager = manager
        setupWebSocketSubscription()
        return manager
    }
    
    private func setupWebSocketSubscription() {
        guard let manager = webSocketManager else { return }
        manager.reportPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newReport in
                self?.handleNewReport(newReport)
            }
            .store(in: &cancellables)
    }
    
    private func handleNewReport(_ newReport: ParkingReport) {
        // Check if report already exists
        if let index = reports.firstIndex(where: { $0.id == newReport.id }) {
            reports[index] = newReport
        } else {
            // Add new report and keep sorted by date
            reports.append(newReport)
            reports.sort { $0.createdAt > $1.createdAt }
        }
    }
    
    func fetchNearbyReports(latitude: Double, longitude: Double, radius: Double = 500) async {
        isLoading = true
        error = nil
        
        do {
            let fetchedReports = try await apiClient.fetchNearbyReports(latitude: latitude, longitude: longitude, radius: radius)
            reports = fetchedReports.sorted { $0.createdAt > $1.createdAt }
            
            // Connect to WebSocket for real-time updates
            let manager = getOrCreateWebSocketManager()
            manager.connect(latitude: latitude, longitude: longitude)
        } catch let apiError as APIError {
            error = apiError
        } catch {
            self.error = .unknown
        }
        
        isLoading = false
    }
    
    func createReport(latitude: Double, longitude: Double, streetName: String, crossStreets: String?, status: ReportStatus) async -> Bool {
        let request = CreateParkingReportRequest(
            latitude: latitude,
            longitude: longitude,
            streetName: streetName,
            crossStreets: crossStreets,
            status: status
        )
        
        do {
            let newReport = try await apiClient.createParkingReport(request)
            handleNewReport(newReport)
            return true
        } catch let apiError as APIError {
            error = apiError
            return false
        } catch {
            self.error = .unknown
            return false
        }
    }
    
    func rateReport(_ reportId: String, isUpvote: Bool) async {
        do {
            let updatedReport = try await apiClient.rateReport(reportId: reportId, isUpvote: isUpvote)
            handleNewReport(updatedReport)
        } catch let apiError as APIError {
            error = apiError
        } catch {
            self.error = .unknown
        }
    }
    
    func refreshReports(at location: CLLocation) async {
        await fetchNearbyReports(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }
    
    func disconnectWebSocket() {
        webSocketManager?.disconnect()
    }
    
    var nearbyReports: [ParkingReport] {
        guard let location = currentLocation else { return reports }
        
        return reports.filter { report in
            let reportLocation = CLLocation(latitude: report.latitude, longitude: report.longitude)
            let distance = location.distance(from: reportLocation)
            return distance <= 500 // 500 meters
        }
    }
    
    func updateCurrentLocation(_ location: CLLocation) {
        currentLocation = location
    }
    
    func clearError() {
        error = nil
    }
}
