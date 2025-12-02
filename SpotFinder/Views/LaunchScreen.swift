//
//  LaunchScreen.swift
//  SpotFinder
//
//  Launch screen view for the app
//

import SwiftUI

struct LaunchScreen: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.blue, Color.blue.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // App Icon
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 140, height: 140)
                    
                    Image(systemName: "car.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                        .scaleEffect(isAnimating ? 1.0 : 0.8)
                        .animation(
                            .easeInOut(duration: 0.8)
                            .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                }
                
                // App Name
                Text("SpotFinder")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                // Tagline
                Text("Find parking spots near you")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    LaunchScreen()
}
