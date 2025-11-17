//
//  SettingsView.swift
//  SpotFinder
//
//  Created by Gustavo Caldas de Souza on 2025-11-17.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    let locationManager: LocationManager
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Label("Location Access", systemImage: "location.fill")
                        Spacer()
                        Text(permissionStatusText)
                            .foregroundStyle(permissionStatusColor)
                    }
                    
                    if !locationManager.isAuthorized {
                        Button {
                            openSettings()
                        } label: {
                            Label("Open Settings", systemImage: "gear")
                        }
                    }
                } header: {
                    Text("Permissions")
                } footer: {
                    Text("Location access is required to find nearby parking spots and report new ones")
                }
                
                Section {
                    LabeledContent("Version", value: "1.0.0")
                    LabeledContent("Build", value: "1")
                } header: {
                    Text("About")
                }
                
                Section {
                    Link(destination: URL(string: "https://github.com")!) {
                        Label("GitHub Repository", systemImage: "link")
                    }
                    
                    Link(destination: URL(string: "https://support.apple.com")!) {
                        Label("Support", systemImage: "questionmark.circle")
                    }
                } header: {
                    Text("Resources")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var permissionStatusText: String {
        switch locationManager.permissionStatus {
        case .notDetermined:
            return "Not Determined"
        case .restricted:
            return "Restricted"
        case .denied:
            return "Denied"
        case .authorizedAlways:
            return "Always"
        case .authorizedWhenInUse:
            return "While Using"
        }
    }
    
    private var permissionStatusColor: Color {
        switch locationManager.permissionStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            return .green
        case .denied, .restricted:
            return .red
        case .notDetermined:
            return .orange
        }
    }
    
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    SettingsView(locationManager: LocationManager())
}
