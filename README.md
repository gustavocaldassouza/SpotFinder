# SpotFinder - Parking Spot Sharing App

A modern iOS app for finding and sharing available parking spots in real-time, built with Swift 6, SwiftUI 3.0, and iOS 17+.

## Features

- 🗺️ **Interactive Map View** - Display parking spots as pins with MapKit clustering
- 📍 **Real-time Location** - Auto-populate location using device GPS
- ⚡ **Live Updates** - Real-time parking reports via WebSocket connection
- 👍 **Community Ratings** - Rate report accuracy with thumbs up/down
- 🔍 **Nearby Search** - Filter reports within 500m radius
- ⏱️ **Time Tracking** - Live timestamps showing "2 min ago" style updates
- ♿ **Accessibility** - Full VoiceOver and Dynamic Type support

## Technical Stack

- **Swift 6** - Latest safety features and performance improvements
- **SwiftUI 3.0** - Modern declarative UI framework
- **MapKit** - Map display with annotation clustering
- **CoreLocation** - GPS and location services
- **Structured Concurrency** - async/await, Task groups, actors
- **Combine** - Reactive data flow for real-time updates
- **iOS 17+** - Minimum deployment target

## Architecture

The app follows **MVVM (Model-View-ViewModel)** architecture with clear separation of concerns:

### Models

- `ParkingReport` - Core data model with Codable & Sendable conformance
- `ReportStatus` - Enum for available/taken status
- `LocationPermissionStatus` - Location authorization states
- `APIError` - Typed error handling

### Services

- `APIClient` - REST API communication with async/await
- `WebSocketManager` - Real-time updates via WebSocket
- `LocationManager` - CoreLocation wrapper with Observable macro

### ViewModels

- `ParkingReportViewModel` - Manages parking reports and API calls

### Views

- `MapScreen` - Main map interface with pins and report list
- `ReportSheet` - Form to submit new parking reports
- `SettingsView` - App settings and permission status

### Components

- `ParkingPinView` - Custom map annotation view
- `ReportCard` - Horizontal scrolling report cards
- `ErrorBanner` - User-friendly error display

## Project Structure

```
SpotFinder/
├── Models/
│   ├── ParkingReport.swift
│   ├── LocationPermissionStatus.swift
│   └── APIError.swift
├── Services/
│   ├── APIClient.swift
│   ├── WebSocketManager.swift
│   └── LocationManager.swift
├── ViewModels/
│   └── ParkingReportViewModel.swift
├── Views/
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

### REST API

- `GET /api/parking-reports/nearby?lat=X&lng=Y&radius=500` - Fetch nearby reports
- `POST /api/parking-reports` - Submit new parking report
- `PUT /api/parking-reports/{id}/rate` - Rate report accuracy

### WebSocket

- `WS /api/parking-reports/ws?lat=X&lng=Y` - Real-time report updates

## Setup Instructions

### Prerequisites

- Xcode 15+ with Swift 6 support
- iOS 17+ simulator or device
- Backend API running (default: `http://localhost:3000`)

### Configuration

1. **Update API URL** (if not using localhost):

   ```swift
   // In AppConfiguration.swift
   static var apiBaseURL: String {
       return "https://your-api-url.com"
   }
   ```

2. **Add Files to Xcode Project**:

   - Open `SpotFinder.xcodeproj` in Xcode
   - Right-click on SpotFinder folder → "Add Files to SpotFinder"
   - Select all new folders (Models, Services, ViewModels, Views, Utilities)
   - Ensure "Copy items if needed" is checked
   - Click "Add"

3. **Configure Info.plist**:
   The Info.plist is already created with required location permissions:
   - `NSLocationWhenInUseUsageDescription`
   - `NSLocationAlwaysAndWhenInUseUsageDescription`

### Building and Running

1. Open the project in Xcode:

   ```bash
   open SpotFinder.xcodeproj
   ```

2. Select a simulator or connected device (iOS 17+)

3. Build and run: `Cmd + R`

### Testing with Backend

1. Start your NestJS backend server:

   ```bash
   npm run start:dev
   ```

2. The app will automatically connect to `http://localhost:3000`

3. For physical device testing, update the API URL to your computer's IP address

## Swift 6 Features Used

- ✅ **@Observable macro** - Modern state management
- ✅ **Sendable conformance** - Thread-safe data types
- ✅ **Actor isolation** - APIClient uses actor for thread safety
- ✅ **Structured concurrency** - async/await throughout
- ✅ **MainActor isolation** - UI updates on main thread
- ✅ **Typed errors** - Custom APIError enum
- ✅ **Modern property wrappers** - @State, @Binding, @Environment

## SwiftUI Best Practices

- ✅ **MVVM architecture** - Clear separation of concerns
- ✅ **Proper memory management** - Weak references where needed
- ✅ **SwiftUI lifecycle** - .task and .onChange modifiers
- ✅ **Preview providers** - All views have #Preview
- ✅ **Accessibility** - VoiceOver labels and Dynamic Type
- ✅ **Haptic feedback** - Sensory feedback on interactions

## User Experience

### Colors

- **Blue** - Available parking spots
- **Red** - Taken parking spots
- **Gray** - Expired reports (older than 1 hour)

### Interactions

- Tap on map pins to see report details
- Horizontal scroll through recent reports
- Tap "+" button to submit new report
- Thumbs up/down to rate reports
- Pull to refresh for latest data

### Accessibility

- All buttons meet 44pt minimum touch target
- VoiceOver support for screen readers
- Dynamic Type for text scaling
- High contrast mode support
- Haptic feedback for actions

## Error Handling

The app implements comprehensive error handling:

- **Network errors** - Graceful handling with retry capability
- **Location errors** - Clear permission status and guidance
- **API errors** - User-friendly error messages
- **Loading states** - Progress indicators during operations
- **Validation** - Form validation before submission

## Performance Optimizations

- **Map clustering** - Efficient pin rendering for many reports
- **Lazy loading** - Only show first 10 reports in card list
- **WebSocket reconnection** - Automatic retry with exponential backoff
- **Actor isolation** - Thread-safe API client
- **Memory management** - Proper cleanup in deinit

## Future Enhancements

Potential features for future versions:

- [ ] User authentication and profiles
- [ ] Push notifications for nearby spots
- [ ] Favorite locations
- [ ] Advanced filtering (time, rating threshold)
- [ ] Route navigation to parking spot
- [ ] Photo uploads for spots
- [ ] Historical data and analytics
- [ ] Offline mode with local caching

## Troubleshooting

### Location Not Working

1. Check Settings → SpotFinder → Location
2. Ensure location services are enabled system-wide
3. Grant "While Using App" permission

### API Connection Failed

1. Verify backend is running on correct port
2. Check API URL in AppConfiguration.swift
3. For device testing, use computer's IP instead of localhost

### Build Errors

1. Ensure Xcode 15+ with Swift 6 support
2. Clean build folder: `Cmd + Shift + K`
3. Delete derived data if needed
4. Verify all files are added to target

## Contributing

When contributing, please follow these guidelines:

1. Use Swift 6 features and modern patterns
2. Follow Apple's Swift API Design Guidelines
3. Include SwiftUI previews for new views
4. Add unit tests for ViewModels and services
5. Maintain MVVM architecture
6. Document public APIs with doc comments

## License

This project is part of an MVP development exercise.

## Support

For issues or questions:

- Check the troubleshooting section above
- Review the inline code documentation
- Consult Apple's Human Interface Guidelines

---

Built with ❤️ using Swift 6 and SwiftUI 3.0
