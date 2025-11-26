//
//  AuthViewModel.swift
//  SpotFinder
//
//  View model for authentication flows
//

import Foundation
import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let authService = AuthService.shared
    
    init() {
        Task {
            await checkAuthenticationStatus()
        }
    }
    
    func checkAuthenticationStatus() async {
        let authenticated = await authService.isAuthenticated
        let user = await authService.currentUser
        
        isAuthenticated = authenticated
        currentUser = user
    }
    
    func signUp(email: String, password: String, firstName: String?, lastName: String?) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let user = try await authService.signUp(
                email: email,
                password: password,
                firstName: firstName,
                lastName: lastName
            )
            
            currentUser = user
            isAuthenticated = true
        } catch let error as APIError {
            errorMessage = handleAPIError(error)
        } catch {
            errorMessage = "An unexpected error occurred. Please try again."
        }
        
        isLoading = false
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let user = try await authService.signIn(email: email, password: password)
            currentUser = user
            isAuthenticated = true
        } catch let error as APIError {
            errorMessage = handleAPIError(error)
        } catch {
            errorMessage = "An unexpected error occurred. Please try again."
        }
        
        isLoading = false
    }
    
    func signOut() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await authService.signOut()
            currentUser = nil
            isAuthenticated = false
        } catch {
            errorMessage = "Failed to sign out. Please try again."
        }
        
        isLoading = false
    }
    
    private func handleAPIError(_ error: APIError) -> String {
        switch error {
        case .serverError(let code, _):
            if code == 401 {
                return "Invalid email or password"
            } else if code == 409 {
                return "An account with this email already exists"
            } else {
                return "Server error. Please try again later."
            }
        case .networkError:
            return "Network error. Please check your connection."
        case .decodingError:
            return "Failed to process response. Please try again."
        case .invalidURL, .invalidResponse:
            return "An unexpected error occurred. Please try again."
        }
    }
}
