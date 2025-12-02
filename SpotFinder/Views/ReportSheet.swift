//
//  ReportSheet.swift
//  SpotFinder
//
//  Created by Gustavo Caldas de Souza on 2025-11-17.
//

import SwiftUI
import CoreLocation
import MapKit

extension Binding where Value == Bool {
    var not: Binding<Bool> {
        Binding<Bool>(
            get: { !self.wrappedValue },
            set: { self.wrappedValue = !$0 }
        )
    }
}

enum LocationSource: CaseIterable {
    case currentLocation
    case mapLocation
    case searchAddress
    
    var localizedName: String {
        switch self {
        case .currentLocation: return L10n.Report.currentLocation
        case .mapLocation: return L10n.Report.mapLocation
        case .searchAddress: return L10n.Report.searchAddress
        }
    }
}

struct ReportSheet: View {
    @Environment(\.dismiss) var dismiss
    let locationManager: LocationManager
    let viewModel: ParkingReportViewModel
    let customLocation: CLLocationCoordinate2D?
    
    @State private var description = ""
    @State private var reportStatus: ReportStatus = .available
    @State private var isSubmitting = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var locationSource: LocationSource = .currentLocation
    
    // Address search states
    @State private var addressSearchText = ""
    @State private var addressSuggestions: [MKLocalSearchCompletion] = []
    @State private var searchedLocation: CLLocationCoordinate2D?
    @State private var searchedAddress: String?
    @State private var isSearching = false
    @State private var searchCompleter = MKLocalSearchCompleter()
    @FocusState private var isAddressFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker(L10n.Report.status, selection: $reportStatus) {
                        Label(L10n.Report.spotAvailable, systemImage: "checkmark.circle.fill")
                            .tag(ReportStatus.available)
                        Label(L10n.Report.spotTaken, systemImage: "xmark.circle.fill")
                            .tag(ReportStatus.taken)
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text(L10n.Report.statusHeader)
                }
                
                Section {
                    Picker(L10n.Report.locationSource, selection: $locationSource) {
                        Text(L10n.Report.currentLocation).tag(LocationSource.currentLocation)
                        if customLocation != nil {
                            Text(L10n.Report.mapLocation).tag(LocationSource.mapLocation)
                        }
                        Text(L10n.Report.searchAddress).tag(LocationSource.searchAddress)
                    }
                    .pickerStyle(.menu)
                    .onChange(of: locationSource) { _, newValue in
                        if newValue != .searchAddress {
                            addressSearchText = ""
                            addressSuggestions = []
                            searchedLocation = nil
                            searchedAddress = nil
                        }
                    }
                    
                    if locationSource == .searchAddress {
                        addressSearchSection
                    }
                    
                    if let location = selectedLocation {
                        if let address = searchedAddress, locationSource == .searchAddress {
                            LabeledContent(L10n.Report.address, value: address)
                                .lineLimit(2)
                        }
                        LabeledContent(L10n.Report.latitude, value: String(format: "%.6f", location.latitude))
                        LabeledContent(L10n.Report.longitude, value: String(format: "%.6f", location.longitude))
                    } else if locationSource != .searchAddress {
                        Label(L10n.Report.gettingLocation, systemImage: "location.fill")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text(L10n.Report.locationHeader)
                } footer: {
                    locationFooterText
                }
                
                Section {
                    TextField(L10n.Report.descriptionPlaceholder, text: $description, axis: .vertical)
                        .textInputAutocapitalization(.sentences)
                        .lineLimit(3...6)
                } header: {
                    Text(L10n.Report.detailsHeader)
                } footer: {
                    Text(L10n.Report.descriptionFooter)
                }
            }
            .navigationTitle(L10n.Report.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Common.cancel) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.Common.submit) {
                        Task {
                            await submitReport()
                        }
                    }
                    .disabled(!isFormValid || isSubmitting)
                }
            }
            .overlay {
                if isSubmitting || isSearching {
                    ProgressView()
                        .controlSize(.large)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.ultraThinMaterial)
                }
            }
            .alert(L10n.Common.error, isPresented: $showError) {
                Button(L10n.Common.ok, role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .sensoryFeedback(.success, trigger: isSubmitting)
            .onAppear {
                setupSearchCompleter()
                // Default to map location if available
                if customLocation != nil {
                    locationSource = .mapLocation
                }
            }
        }
    }
    
    @ViewBuilder
    private var addressSearchSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField(L10n.Report.addressPlaceholder, text: $addressSearchText)
                    .textInputAutocapitalization(.words)
                    .disableAutocorrection(true)
                    .focused($isAddressFieldFocused)
                    .onChange(of: addressSearchText) { _, newValue in
                        Task { await fetchAddressSuggestions(for: newValue) }
                    }
                if !addressSearchText.isEmpty {
                    Button {
                        addressSearchText = ""
                        addressSuggestions = []
                        searchedLocation = nil
                        searchedAddress = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            
            if !addressSuggestions.isEmpty && isAddressFieldFocused {
                Divider()
                ForEach(addressSuggestions.prefix(5), id: \.self) { completion in
                    Button {
                        Task { await selectAddress(completion) }
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(completion.title)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            if !completion.subtitle.isEmpty {
                                Text(completion.subtitle)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 6)
                    }
                    .buttonStyle(.plain)
                    
                    if completion != addressSuggestions.prefix(5).last {
                        Divider()
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var locationFooterText: some View {
        switch locationSource {
        case .currentLocation:
            Text(L10n.Report.usingCurrentLocation)
        case .mapLocation:
            Text(L10n.Report.usingMapLocation)
        case .searchAddress:
            if searchedLocation != nil {
                Text(L10n.Report.usingSearchedLocation)
            } else {
                Text(L10n.Report.searchForAddress)
            }
        }
    }
    
    private var selectedLocation: CLLocationCoordinate2D? {
        switch locationSource {
        case .currentLocation:
            return locationManager.currentLocation?.coordinate
        case .mapLocation:
            return customLocation ?? locationManager.currentLocation?.coordinate
        case .searchAddress:
            return searchedLocation
        }
    }
    
    private var isFormValid: Bool {
        selectedLocation != nil
    }
    
    private func setupSearchCompleter() {
        searchCompleter.resultTypes = [.address, .pointOfInterest]
        
        if let location = locationManager.currentLocation {
            searchCompleter.region = MKCoordinateRegion(
                center: location.coordinate,
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
    
    private func selectAddress(_ completion: MKLocalSearchCompletion) async {
        isAddressFieldFocused = false
        isSearching = true
        defer { isSearching = false }
        
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)
        
        do {
            let response = try await search.start()
            if let mapItem = response.mapItems.first {
                searchedLocation = mapItem.placemark.coordinate
                searchedAddress = formatAddress(for: mapItem)
                addressSearchText = completion.title
                addressSuggestions = []
            } else {
                errorMessage = L10n.Report.addressNotFound
                showError = true
            }
        } catch {
            errorMessage = L10n.Report.addressSearchFailed
            showError = true
        }
    }
    
    private func formatAddress(for mapItem: MKMapItem) -> String {
        let placemark = mapItem.placemark
        var parts: [String] = []
        
        if let name = placemark.name {
            parts.append(name)
        }
        if let thoroughfare = placemark.thoroughfare {
            if let subThoroughfare = placemark.subThoroughfare {
                parts.append("\(subThoroughfare) \(thoroughfare)")
            } else if !parts.contains(thoroughfare) {
                parts.append(thoroughfare)
            }
        }
        if let locality = placemark.locality {
            parts.append(locality)
        }
        if let administrativeArea = placemark.administrativeArea {
            parts.append(administrativeArea)
        }
        
        // Remove duplicates while preserving order
        var seen = Set<String>()
        let unique = parts.filter { seen.insert($0).inserted }
        
        return unique.joined(separator: ", ")
    }
    
    private func submitReport() async {
        guard let location = selectedLocation else {
            errorMessage = L10n.Report.unableToGetLocation
            showError = true
            return
        }
        
        isSubmitting = true
        
        let success = await viewModel.createReport(
            latitude: location.latitude,
            longitude: location.longitude,
            description: description.isEmpty ? nil : description.trimmingCharacters(in: .whitespacesAndNewlines),
            status: reportStatus
        )
        
        isSubmitting = false
        
        if success {
            dismiss()
        } else {
            errorMessage = viewModel.error?.errorDescription ?? L10n.Report.failedToSubmit
            showError = true
        }
    }
}

#Preview {
    ReportSheet(
        locationManager: LocationManager(),
        viewModel: ParkingReportViewModel(),
        customLocation: nil
    )
}
