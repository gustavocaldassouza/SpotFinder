//
//  ErrorBanner.swift
//  SpotFinder
//
//  Created by Gustavo Caldas de Souza on 2025-11-17.
//

import SwiftUI

struct ErrorBanner: View {
    let error: APIError
    let onDismiss: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
            
            Text(error.errorDescription ?? "An error occurred")
                .font(.subheadline)
                .lineLimit(2)
            
            Spacer()
            
            Button {
                onDismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(.red.opacity(0.3), lineWidth: 1)
        }
    }
}

#Preview {
    VStack {
        ErrorBanner(error: .networkError(URLError(.notConnectedToInternet))) {
            print("Dismissed")
        }
        
        ErrorBanner(error: .serverError(500, "Internal server error")) {
            print("Dismissed")
        }
    }
    .padding()
}
