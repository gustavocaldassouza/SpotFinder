//
//  MapScreen.swift
//  SpotFinder
//
//  Created by Gustavo Caldas de Souza on 2025-11-17.
//

import SwiftUI
import MapKit

struct MapScreen: View {
    @State private var viewModel = ParkingReportViewModel()
    @State private var locationManager = LocationManager()
    @State private var showingReportSheet = false
    @State private var showingSettings = false
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var selectedReport: ParkingReport?
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                mapView
                
                VStack(spacing: 16) {
                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    }
                    
                    if let error = viewModel.error {
                        ErrorBanner(error: error) {
                            viewModel.clearError()
                        }
                    }
                    
                    reportsList
                    
                    actionButtons
                }
                .padding()
            }
            .navigationTitle("SpotFinder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await refreshLocation()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .sheet(isPresented: $showingReportSheet) {
                ReportSheet(
                    locationManager: locationManager,
                    viewModel: viewModel
                )
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(locationManager: locationManager)
            }
            .task {
                await initializeApp()
            }
            .onChange(of: locationManager.currentLocation) { _, newLocation in
                if let location = newLocation {
                    updateMapCamera(for: location)
                    Task {
                        await viewModel.fetchNearbyReports(
                            latitude: location.coordinate.latitude,
                            longitude: location.coordinate.longitude
                        )
                    }
                }
            }
        }
    }
    
    private var mapView: some View {
        Map(position: $cameraPosition) {
            UserAnnotation()
            
            ForEach(viewModel.reports) { report in
                Annotation(annotationTitle(for: report), coordinate: report.coordinate) {
                    ParkingPinView(report: report)
                        .onTapGesture {
                            selectedReport = report
                        }
                }
            }
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
    }
    
    private var reportsList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.reports.prefix(10)) { report in
                    ReportCard(report: report) {
                        cameraPosition = .camera(MapCamera(
                            centerCoordinate: report.coordinate,
                            distance: 500
                        ))
                        selectedReport = report
                    } onRate: { isUpvote in
                        Task {
                            await viewModel.rateReport(report.id, isUpvote: isUpvote)
                        }
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .frame(height: 160)
    }
    
    private var actionButtons: some View {
        HStack(spacing: 16) {
            Button {
                showingReportSheet = true
            } label: {
                Label("Report Spot", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!locationManager.isAuthorized)
        }
    }
    
    private func initializeApp() async {
        locationManager.requestPermission()
        
        // Wait a bit for permission
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        if locationManager.isAuthorized {
            locationManager.startUpdatingLocation()
        }
    }
    
    private func updateMapCamera(for location: CLLocation) {
        cameraPosition = .camera(MapCamera(
            centerCoordinate: location.coordinate,
            distance: 1000
        ))
        viewModel.updateCurrentLocation(location)
    }
    
    private func refreshLocation() async {
        guard let location = locationManager.currentLocation else { return }
        await viewModel.refreshReports(at: location)
    }
    
    private func annotationTitle(for report: ParkingReport) -> String {
        if let description = report.description, !description.isEmpty {
            return description
        }
        return report.status == .available ? "Spot Available" : "Spot Taken"
    }
}

#Preview {
    MapScreen()
}
