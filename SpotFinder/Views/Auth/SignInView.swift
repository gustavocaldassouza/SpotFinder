//
//  SignInView.swift
//  SpotFinder
//
//  Sign in screen
//

import SwiftUI

struct SignInView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Logo/Header
                VStack(spacing: 8) {
                    Image(systemName: "car.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("SpotFinder")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Find parking spots near you")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                .padding(.bottom, 40)
                
                // Sign In Form
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.password)
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button {
                        Task {
                            await viewModel.signIn(email: email, password: password)
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.white)
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Sign In")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.isLoading || email.isEmpty || password.isEmpty)
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Sign Up Link
                Button {
                    showSignUp = true
                } label: {
                    HStack(spacing: 4) {
                        Text("Don't have an account?")
                            .foregroundColor(.secondary)
                        Text("Sign Up")
                            .fontWeight(.semibold)
                    }
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $showSignUp) {
                SignUpView(viewModel: viewModel)
            }
        }
    }
}
