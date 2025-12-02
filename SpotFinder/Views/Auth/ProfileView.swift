//
//  ProfileView.swift
//  SpotFinder
//
//  User profile view
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            List {
                if let user = viewModel.currentUser {
                    Section(L10n.Profile.title) {
                        HStack {
                            Text(L10n.Profile.name)
                            Spacer()
                            Text(user.displayName)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text(L10n.Profile.email)
                            Spacer()
                            Text(user.email)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text(L10n.Profile.memberSince)
                            Spacer()
                            Text(user.createdAt, style: .date)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        Task {
                            await viewModel.signOut()
                        }
                    } label: {
                        HStack {
                            Spacer()
                            if viewModel.isLoading {
                                ProgressView()
                            } else {
                                Text(L10n.Profile.signOut)
                            }
                            Spacer()
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .navigationTitle(L10n.Profile.title)
        }
    }
}
