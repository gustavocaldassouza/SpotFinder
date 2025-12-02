//
//  MapScreen.swift
//  SpotFinder
//
//  Created by Gustavo Caldas de Souza on 2025-11-17.
//

import SwiftUI
import MapKit

struct MapScreen: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    private func formatAddress(for mapItem: MKMapItem) -> String? {
            let placemark = mapItem.placemark
            let parts: [String?] = [
                placemark.thoroughfare,
                placemark.locality,
                placemark.administrativeArea
            ]
            let address = parts.compactMap { $0 }.joined(separator: ", ")
            return address.isEmpty ? nil : address
        }
        
        private func fullAddressString(for placemark: CLPlacemark) -> String {
            let parts: [String?] = [
                placemark.name,
                placemark.thoroughfare,
                placemark.subThoroughfare,
                placemark.locality,
                placemark.administrativeArea
            ]
            return parts.compactMap { $0 }.joined(separator: ", ")
        }
    @State private var viewModel = ParkingReportViewModel()
    @State private var locationManager = LocationManager()
    @State private var showingReportSheet = false
    @State private var customReportLocation: CLLocationCoordinate2D?
    @State private var showingSettings = false
    @State private var showingSpotDetail = false
    @State private var showingFavorites = false
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var selectedReport: ParkingReport?
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var addressSuggestions: [MKLocalSearchCompletion] = []
    @FocusState private var searchFieldIsFocused: Bool
    @State private var searchCompleter = MKLocalSearchCompleter()
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search address...", text: $searchText)
                            .autocapitalization(.words)
                            .disableAutocorrection(true)
                            .focused($searchFieldIsFocused)
                            .onChange(of: searchText) { _, newValue in
                                Task { await fetchAddressSuggestions(for: newValue) }
                            }
                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                                addressSuggestions = []
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                    .padding(.top, 12)
                    .padding(.horizontal)

                    if searchFieldIsFocused && !addressSuggestions.isEmpty {
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(addressSuggestions.prefix(8), id: \.self) { completion in
                                    Button {
                                        searchText = completion.title
                                        searchFieldIsFocused = false // Dismiss keyboard
                                        Task { await searchFromCompletion(completion) }
                                    } label: {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(completion.title)
                                                .font(.body)
                                                .foregroundColor(.primary)
                                                .lineLimit(1)
                                            Text(completion.subtitle)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .lineLimit(1)
                                        }
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 12)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color(.systemBackground))
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    if completion != addressSuggestions.last {
                                        Divider()
                                    }
                                }
                            }
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        }
                        .padding(.horizontal)
                        .frame(maxHeight: 280)
                    }
                    mapView
                }
                VStack(spacing: 16) {
                    if viewModel.isLoading || isSearching {
                        ProgressView()
                            .padding()
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    }
                    if let error = viewModel.error {
                        ErrorBanner(error: error) {
                            viewModel.clearError()
                        }
                    }
                    actionButtons
                }
                .padding()
            }
            .navigationTitle("SpotFinder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingFavorites = true
                    } label: {
                        Image(systemName: "bookmark.fill")
                    }
                }
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
                    viewModel: viewModel,
                    customLocation: customReportLocation
                )
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(locationManager: locationManager)
            }
            .sheet(isPresented: $showingFavorites) {
                FavoritesView { report in
                    // Navigate to the selected spot on the map
                    cameraPosition = .camera(MapCamera(
                        centerCoordinate: report.coordinate,
                        distance: 500
                    ))
                    selectedReport = report
                    showingSpotDetail = true
                }
            }
            .sheet(isPresented: $showingSpotDetail) {
                if let report = selectedReport {
                    SpotDetailSheet(report: report, viewModel: viewModel)
                }
            }
            .task {
                await initializeApp()
                setupSearchCompleter()
                // Sync favorite IDs when app starts
                await FavoritesManager.shared.syncFavoriteIds()
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
    private func searchAddress() async {
        let address = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !address.isEmpty else { return }
        isSearching = true
        defer { isSearching = false }
        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.geocodeAddressString(address)
            if let placemark = placemarks.first, let location = placemark.location {
                updateMapCamera(for: location)
                await viewModel.fetchNearbyReports(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
                addressSuggestions = []
            } else {
                setCustomError("Address not found")
            }
        } catch {
            setCustomError("Failed to search address")
        }
    }

    private func setupSearchCompleter() {
        searchCompleter.resultTypes = [.address, .pointOfInterest, .query]
        
        if let location = locationManager.currentLocation {
            searchCompleter.region = MKCoordinateRegion(
                center: location.coordinate,
                latitudinalMeters: 100000, // 100km radius
                longitudinalMeters: 100000
            )
        } else {
            searchCompleter.region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 45.5017, longitude: -73.5673),
                latitudinalMeters: 100000,
                longitudinalMeters: 100000
            )
        }
    }
    
    private func fetchAddressSuggestions(for query: String) async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else {
            addressSuggestions = []
            return
        }
        
        searchCompleter.queryFragment = trimmed
        
        try? await Task.sleep(nanoseconds: 300_000_000)
        addressSuggestions = searchCompleter.results
    }
    
    private func searchFromCompletion(_ completion: MKLocalSearchCompletion) async {
        isSearching = true
        defer { isSearching = false }
        
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)
        
        do {
            let response = try await search.start()
            if let mapItem = response.mapItems.first,
               let location = mapItem.placemark.location {
                updateMapCamera(for: location)
                
                await viewModel.fetchNearbyReports(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
                
                addressSuggestions = []
            }
        } catch {
            setCustomError("Failed to find location")
        }
    }
        

        private func setCustomError(_ message: String) {
            Task { @MainActor in
                await MainActor.run {
                    viewModel.clearError()
                    let _ = viewModel
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
                            showingSpotDetail = true
                        }
                }
            }
        }
        .onLongPressGesture(minimumDuration: 0.5) {
            // This will be handled by the MapReader if needed
        }
        .onTapGesture { location in
            // Future: Could convert tap location to coordinates for selection
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
                customReportLocation = nil
                showingReportSheet = true
            } label: {
                Label("Report Spot", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
            }
            .buttonStyle(.borderedProminent)
            
            Button {
                if let currentLocation = locationManager.currentLocation {
                    customReportLocation = currentLocation.coordinate
                } else if let camera = cameraPosition.camera {
                    customReportLocation = camera.centerCoordinate
                }
                showingReportSheet = true
            } label: {
                Image(systemName: "mappin.and.ellipse")
                    .font(.headline)
                    .frame(height: 50)
                    .frame(width: 50)
            }
            .buttonStyle(.bordered)
        }
    }
    
    private func initializeApp() async {
        locationManager.requestPermission()
        
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
