# SpotFinder

A real-time parking spot sharing iOS application built with Swift 6, SwiftUI, and modern iOS development practices.

![iOS](https://img.shields.io/badge/iOS-17.0+-blue)
![Swift](https://img.shields.io/badge/Swift-6.0-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## Overview

SpotFinder helps drivers find available parking spots in real-time through community reporting. Users can share parking availability, view nearby spots on an interactive map, and receive live updates as conditions change.

## Features

- 🗺️ **Interactive Map** - Display parking spots with MapKit clustering
- 📍 **Real-time Location** - GPS-based location tracking
- ⚡ **Live Updates** - WebSocket-powered real-time notifications
- 👤 **User Authentication** - Secure JWT-based authentication with profiles
- 👍 **Community Ratings** - Rate parking spot accuracy with abuse prevention (one rating per user)
- 🔍 **Nearby Search** - Find spots within 500m radius
- ⏱️ **Time Tracking** - Live timestamps and automatic expiration
- 🔐 **Secure Storage** - Keychain-based token storage
- ♿ **Accessibility** - Full VoiceOver and Dynamic Type support

## Screenshots

<!-- Add your app screenshots here -->

_Screenshots coming soon_

## Technical Stack

- **Swift 6** - Modern safety features and concurrency
- **SwiftUI** - Declarative UI framework
- **MapKit** - Map display with annotation clustering
- **CoreLocation** - GPS and location services
- **Structured Concurrency** - async/await, actors
- **Combine** - Reactive data flow
- **iOS 17+** - Minimum deployment target

## Architecture

The app follows **MVVM (Model-View-ViewModel)** architecture:

- **Models** - Data structures (`ParkingReport`, `APIError`)
- **Views** - SwiftUI views (`MapScreen`, `ReportSheet`)
- **ViewModels** - Business logic (`ParkingReportViewModel`)
- **Services** - External integrations (API, WebSocket, Location)

## Project Structure

```
SpotFinder/
├── Models/
│   ├── Auth/
│   │   └── User.swift
│   ├── ParkingReport.swift
│   ├── LocationPermissionStatus.swift
│   └── APIError.swift
├── Services/
│   ├── Auth/
│   │   ├── AuthService.swift
│   │   └── KeychainManager.swift
│   ├── APIClient.swift
│   ├── WebSocketManager.swift
│   └── LocationManager.swift
├── ViewModels/
│   ├── Auth/
│   │   └── AuthViewModel.swift
│   └── ParkingReportViewModel.swift
├── Views/
│   ├── Auth/
│   │   ├── SignInView.swift
│   │   ├── SignUpView.swift
│   │   └── ProfileView.swift
│   ├── MapScreen.swift
│   ├── ReportSheet.swift
│   ├── SettingsView.swift
│   └── Components/
│       ├── ParkingPinView.swift
│       ├── ReportCard.swift
│       └── ErrorBanner.swift
├── Utilities/
│   └── AppConfiguration.swift
└── SpotFinderApp.swift
```

## API Integration

The app communicates with a NestJS backend using these endpoints:

### Authentication

- `POST /auth/signup` - Register new user account
- `POST /auth/signin` - Sign in with email/password
- `POST /auth/refresh` - Refresh access token
- `POST /auth/signout` - Sign out and invalidate tokens
- `GET /auth/profile` - Get current user profile (protected)

### REST API

- `GET /api/parking-reports/nearby?lat=X&lng=Y&radius=500` - Fetch nearby reports
- `POST /api/parking-reports` - Submit new parking report (protected)
- `PUT /api/parking-reports/{id}/rate` - Rate report accuracy (protected)

### WebSocket

- `WS /api/parking-reports/ws?lat=X&lng=Y` - Real-time report updates

**Note:** Protected endpoints require JWT authentication via `Authorization: Bearer <token>` header.

## Setup

### Prerequisites

- Xcode 15+ with Swift 6 support
- iOS 17+ simulator or device
- Backend API (see `/backend` directory)

### Installation

1. Clone the repository

```bash
git clone https://github.com/yourusername/SpotFinder.git
cd SpotFinder
```

2. Open in Xcode

```bash
open SpotFinder.xcodeproj
```

3. Configure API URL in `Utilities/AppConfiguration.swift`

4. Build and run (⌘R)

## Backend API

See the `/backend` directory for the NestJS backend implementation with:

- RESTful API endpoints
- JWT authentication with refresh tokens
- User account management
- WebSocket real-time updates
- PostgreSQL database with Drizzle ORM
- Docker support

Refer to `/backend/README.md` for setup instructions.

For authentication implementation details, see:
- `AUTHENTICATION.md` - Detailed authentication documentation
- `QUICK_START_AUTH.md` - Quick reference for developers
- `IMPLEMENTATION_SUMMARY.md` - Complete implementation overview

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
