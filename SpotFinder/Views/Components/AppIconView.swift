//
//  AppIconView.swift
//  SpotFinder
//
//  App icon design that can be exported as PNG
//  Use this view in a preview and export at 1024x1024
//

import SwiftUI

/// App Icon Design - Export this view as 1024x1024 PNG for App Store
struct AppIconView: View {
    let size: CGFloat
    let variant: IconVariant
    
    enum IconVariant {
        case light
        case dark
        case tinted
    }
    
    init(size: CGFloat = 1024, variant: IconVariant = .light) {
        self.size = size
        self.variant = variant
    }
    
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: size * 0.2237) // iOS icon corner radius ratio
                .fill(backgroundGradient)
            
            // Pin/Location marker
            VStack(spacing: 0) {
                ZStack {
                    // Outer pin shape
                    PinShape()
                        .fill(pinColor)
                        .frame(width: size * 0.55, height: size * 0.7)
                        .shadow(color: .black.opacity(0.2), radius: size * 0.02, x: 0, y: size * 0.01)
                    
                    // Inner circle with car
                    Circle()
                        .fill(innerCircleColor)
                        .frame(width: size * 0.32, height: size * 0.32)
                        .offset(y: -size * 0.08)
                    
                    // Car icon
                    Image(systemName: "car.fill")
                        .font(.system(size: size * 0.15, weight: .semibold))
                        .foregroundColor(carColor)
                        .offset(y: -size * 0.08)
                }
            }
            .offset(y: -size * 0.02)
        }
        .frame(width: size, height: size)
    }
    
    private var backgroundGradient: LinearGradient {
        switch variant {
        case .light:
            return LinearGradient(
                colors: [Color(red: 0.20, green: 0.46, blue: 0.98),
                         Color(red: 0.15, green: 0.35, blue: 0.85)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .dark:
            return LinearGradient(
                colors: [Color(red: 0.12, green: 0.12, blue: 0.14),
                         Color(red: 0.08, green: 0.08, blue: 0.10)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .tinted:
            return LinearGradient(
                colors: [Color(red: 0.20, green: 0.46, blue: 0.98).opacity(0.8),
                         Color(red: 0.15, green: 0.35, blue: 0.85).opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var pinColor: Color {
        switch variant {
        case .light, .tinted:
            return .white
        case .dark:
            return Color(red: 0.38, green: 0.58, blue: 1.0)
        }
    }
    
    private var innerCircleColor: Color {
        switch variant {
        case .light:
            return Color(red: 0.20, green: 0.46, blue: 0.98)
        case .dark:
            return Color(red: 0.12, green: 0.12, blue: 0.14)
        case .tinted:
            return Color(red: 0.20, green: 0.46, blue: 0.98)
        }
    }
    
    private var carColor: Color {
        switch variant {
        case .light, .tinted:
            return .white
        case .dark:
            return Color(red: 0.38, green: 0.58, blue: 1.0)
        }
    }
}

/// Custom pin/marker shape
struct PinShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
        // Starting point at bottom tip
        path.move(to: CGPoint(x: width * 0.5, y: height))
        
        // Left curve going up
        path.addQuadCurve(
            to: CGPoint(x: 0, y: height * 0.35),
            control: CGPoint(x: 0, y: height * 0.65)
        )
        
        // Top arc (left side)
        path.addArc(
            center: CGPoint(x: width * 0.5, y: height * 0.35),
            radius: width * 0.5,
            startAngle: .degrees(180),
            endAngle: .degrees(0),
            clockwise: false
        )
        
        // Right curve going down
        path.addQuadCurve(
            to: CGPoint(x: width * 0.5, y: height),
            control: CGPoint(x: width, y: height * 0.65)
        )
        
        return path
    }
}

// MARK: - Previews for Export

#Preview("Light Icon") {
    AppIconView(size: 512, variant: .light)
}

#Preview("Dark Icon") {
    AppIconView(size: 512, variant: .dark)
}

#Preview("Tinted Icon") {
    AppIconView(size: 512, variant: .tinted)
}

#Preview("All Variants") {
    HStack(spacing: 20) {
        VStack {
            AppIconView(size: 200, variant: .light)
            Text("Light")
        }
        VStack {
            AppIconView(size: 200, variant: .dark)
            Text("Dark")
        }
        VStack {
            AppIconView(size: 200, variant: .tinted)
            Text("Tinted")
        }
    }
    .padding()
}
