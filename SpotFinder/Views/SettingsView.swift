//
//  SettingsView.swift
//  SpotFinder
//
//  Created by Gustavo Caldas de Souza on 2025-11-17.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    let locationManager: LocationManager
    @State private var showProfile = false
    @State private var languageManager = LanguageManager.shared
    @State private var showRestartAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        showProfile = true
                    } label: {
                        HStack {
                            Label(L10n.Settings.profile, systemImage: "person.circle.fill")
                            Spacer()
                            if let user = authViewModel.currentUser {
                                Text(user.displayName)
                                    .foregroundColor(.secondary)
                            }
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .foregroundColor(.primary)
                } header: {
                    Text(L10n.Settings.accountHeader)
                }
                
                Section {
                    Picker(selection: Binding(
                        get: { languageManager.currentLanguage },
                        set: { newLanguage in
                            languageManager.currentLanguage = newLanguage
                            showRestartAlert = true
                        }
                    )) {
                        ForEach(AppLanguage.allCases) { language in
                            HStack {
                                Text(language.flag)
                                Text(language.displayName)
                            }
                            .tag(language)
                        }
                    } label: {
                        Label(L10n.Settings.language, systemImage: "globe")
                    }
                } header: {
                    Text(L10n.Settings.languageHeader)
                } footer: {
                    Text(L10n.Settings.languageFooter)
                }
                
                Section {
                    HStack {
                        Label(L10n.Settings.locationAccess, systemImage: "location.fill")
                        Spacer()
                        Text(permissionStatusText)
                            .foregroundStyle(permissionStatusColor)
                    }
                    
                    if !locationManager.isAuthorized {
                        Button {
                            openSettings()
                        } label: {
                            Label(L10n.Settings.openSettings, systemImage: "gear")
                        }
                    }
                } header: {
                    Text(L10n.Settings.permissionsHeader)
                } footer: {
                    Text(L10n.Settings.locationFooter)
                }
                
                Section {
                    LabeledContent(L10n.Settings.version, value: "1.0.0")
                    LabeledContent(L10n.Settings.build, value: "1")
                } header: {
                    Text(L10n.Settings.aboutHeader)
                }
                
                Section {
                    Link(destination: URL(string: "https://github.com")!) {
                        Label(L10n.Settings.github, systemImage: "link")
                    }
                    
                    Link(destination: URL(string: "https://support.apple.com")!) {
                        Label(L10n.Settings.support, systemImage: "questionmark.circle")
                    }
                } header: {
                    Text(L10n.Settings.resourcesHeader)
                }
            }
            .navigationTitle(L10n.Settings.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.Common.done) {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showProfile) {
                ProfileView(viewModel: authViewModel)
            }
            .alert(L10n.Settings.restartRequired, isPresented: $showRestartAlert) {
                Button(L10n.Common.ok) { }
            } message: {
                Text(L10n.Settings.restartMessage)
            }
        }
    }
    
    private var permissionStatusText: String {
        switch locationManager.permissionStatus {
        case .notDetermined:
            return L10n.Permission.notDetermined
        case .restricted:
            return L10n.Permission.restricted
        case .denied:
            return L10n.Permission.denied
        case .authorizedAlways:
            return L10n.Permission.always
        case .authorizedWhenInUse:
            return L10n.Permission.whileUsing
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
