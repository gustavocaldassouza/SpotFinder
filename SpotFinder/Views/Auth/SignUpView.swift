//
//  SignUpView.swift
//  SpotFinder
//
//  Sign up screen
//

import SwiftUI

struct SignUpView: View {
    @ObservedObject var viewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var passwordMismatch = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text(L10n.SignUp.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                Text(L10n.SignUp.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20)
                
                // Sign Up Form
                VStack(spacing: 16) {
                    TextField(L10n.SignUp.firstName, text: $firstName)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.givenName)
                    
                    TextField(L10n.SignUp.lastName, text: $lastName)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.familyName)
                    
                    TextField(L10n.SignUp.email, text: $email)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    SecureField(L10n.SignUp.password, text: $password)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.newPassword)
                        .onChange(of: password) { _ in
                            passwordMismatch = false
                        }
                    
                    SecureField(L10n.SignUp.confirmPassword, text: $confirmPassword)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.newPassword)
                        .onChange(of: confirmPassword) { _ in
                            passwordMismatch = false
                        }
                    
                    if passwordMismatch {
                        Text(L10n.SignUp.passwordMismatch)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button {
                        if password != confirmPassword {
                            passwordMismatch = true
                            return
                        }
                        
                        Task {
                            await viewModel.signUp(
                                email: email,
                                password: password,
                                firstName: firstName.isEmpty ? nil : firstName,
                                lastName: lastName.isEmpty ? nil : lastName
                            )
                            
                            if viewModel.isAuthenticated {
                                dismiss()
                            }
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.white)
                                .frame(maxWidth: .infinity)
                        } else {
                            Text(L10n.SignUp.button)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.isLoading || email.isEmpty || password.isEmpty || confirmPassword.isEmpty)
                }
                .padding(.horizontal, 32)
                
                Spacer()
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(L10n.Common.cancel) {
                        dismiss()
                    }
                }
            }
        }
    }
}
