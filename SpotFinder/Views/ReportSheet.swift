//
//  ReportSheet.swift
//  SpotFinder
//
//  Created by Gustavo Caldas de Souza on 2025-11-17.
//

import SwiftUI
import CoreLocation

struct ReportSheet: View {
    @Environment(\.dismiss) private var dismiss
    let locationManager: LocationManager
    let viewModel: ParkingReportViewModel
    
    @State private var description = ""
    @State private var reportStatus: ReportStatus = .available
    @State private var isSubmitting = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Status", selection: $reportStatus) {
                        Label("Spot Available", systemImage: "checkmark.circle.fill")
                            .tag(ReportStatus.available)
                        Label("Spot Taken", systemImage: "xmark.circle.fill")
                            .tag(ReportStatus.taken)
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Report Type")
                }
                
                Section {
                    if let location = locationManager.currentLocation {
                        LabeledContent("Latitude", value: String(format: "%.6f", location.coordinate.latitude))
                        LabeledContent("Longitude", value: String(format: "%.6f", location.coordinate.longitude))
                    } else {
                        Label("Getting location...", systemImage: "location.fill")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Location")
                } footer: {
                    Text("Using your current GPS location")
                }
                
                Section {
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .textInputAutocapitalization(.sentences)
                        .lineLimit(3...6)
                } header: {
                    Text("Details")
                } footer: {
                    Text("Add any helpful details about the parking spot")
                }
            }
            .navigationTitle("Report Parking Spot")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") {
                        Task {
                            await submitReport()
                        }
                    }
                    .disabled(!isFormValid || isSubmitting)
                }
            }
            .overlay {
                if isSubmitting {
                    ProgressView()
                        .controlSize(.large)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.ultraThinMaterial)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .sensoryFeedback(.success, trigger: isSubmitting)
        }
    }
    
    private var isFormValid: Bool {
        locationManager.currentLocation != nil
    }
    
    private func submitReport() async {
        guard let location = locationManager.currentLocation else {
            errorMessage = "Unable to get current location"
            showError = true
            return
        }
        
        isSubmitting = true
        
        let success = await viewModel.createReport(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            description: description.isEmpty ? nil : description.trimmingCharacters(in: .whitespacesAndNewlines),
            status: reportStatus
        )
        
        isSubmitting = false
        
        if success {
            dismiss()
        } else {
            errorMessage = viewModel.error?.errorDescription ?? "Failed to submit report"
            showError = true
        }
    }
}

#Preview {
    ReportSheet(
        locationManager: LocationManager(),
        viewModel: ParkingReportViewModel()
    )
}
