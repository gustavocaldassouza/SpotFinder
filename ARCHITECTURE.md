# SpotFinder Architecture Diagram

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         SpotFinder App                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌───────────────────────── VIEW LAYER ─────────────────┐  │
│  │                                                        │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌────────────┐  │  │
│  │  │  MapScreen   │  │ ReportSheet  │  │  Settings  │  │  │
│  │  │              │  │              │  │    View    │  │  │
│  │  │ • Map View   │  │ • Form       │  │ • Perms    │  │  │
│  │  │ • Pins       │  │ • Validation │  │ • Info     │  │  │
│  │  │ • Cards      │  │ • Submit     │  │ • Links    │  │  │
│  │  └──────────────┘  └──────────────┘  └────────────┘  │  │
│  │                                                        │  │
│  │  ┌─────────────── COMPONENTS ───────────────┐        │  │
│  │  │ ParkingPinView │ ReportCard │ ErrorBanner │        │  │
│  │  └───────────────────────────────────────────┘        │  │
│  └────────────────────────────────────────────────────────┘  │
│                              │                               │
│                              ▼                               │
│  ┌──────────────────── VIEWMODEL LAYER ─────────────────┐  │
│  │                                                        │  │
│  │          ┌─────────────────────────────┐              │  │
│  │          │ ParkingReportViewModel      │              │  │
│  │          │                             │              │  │
│  │          │ • @Observable              │              │  │
│  │          │ • reports: [ParkingReport]│              │  │
│  │          │ • isLoading: Bool          │              │  │
│  │          │ • error: APIError?         │              │  │
│  │          │                             │              │  │
│  │          │ • fetchNearbyReports()     │              │  │
│  │          │ • createReport()           │              │  │
│  │          │ • rateReport()             │              │  │
│  │          └─────────────────────────────┘              │  │
│  └────────────────────────────────────────────────────────┘  │
│                              │                               │
│                              ▼                               │
│  ┌──────────────────── SERVICE LAYER ────────────────────┐  │
│  │                                                        │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌────────────┐  │  │
│  │  │  APIClient   │  │  WebSocket   │  │ Location   │  │  │
│  │  │   (Actor)    │  │   Manager    │  │  Manager   │  │  │
│  │  │              │  │              │  │            │  │  │
│  │  │ • GET nearby │  │ • connect()  │  │ • Request  │  │  │
│  │  │ • POST       │  │ • receive()  │  │   perms    │  │  │
│  │  │ • PUT rate   │  │ • reconnect()│  │ • Updates  │  │  │
│  │  │              │  │              │  │ • Current  │  │  │
│  │  │ async/await  │  │ Combine      │  │   location │  │  │
│  │  └──────────────┘  └──────────────┘  └────────────┘  │  │
│  └────────────────────────────────────────────────────────┘  │
│                              │                               │
│                              ▼                               │
│  ┌──────────────────── MODEL LAYER ──────────────────────┐  │
│  │                                                        │  │
│  │  ┌──────────────────────────────────────────────────┐ │  │
│  │  │           ParkingReport (Sendable)               │ │  │
│  │  │  • id, lat, lng, street, status, votes, date    │ │  │
│  │  │  • Codable for JSON encoding/decoding           │ │  │
│  │  │  • Computed properties for UI display           │ │  │
│  │  └──────────────────────────────────────────────────┘ │  │
│  │                                                        │  │
│  │  ┌──────────────┐  ┌──────────────────────────────┐  │  │
│  │  │ ReportStatus │  │  APIError (Error)            │  │  │
│  │  │ • available  │  │  • networkError              │  │  │
│  │  │ • taken      │  │  • serverError               │  │  │
│  │  └──────────────┘  │  • decodingError             │  │  │
│  │                    └──────────────────────────────┘  │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
         ┌─────────────────────────────────────┐
         │      External Dependencies          │
         ├─────────────────────────────────────┤
         │  • MapKit (Apple)                   │
         │  • CoreLocation (Apple)             │
         │  • Combine (Apple)                  │
         │  • SwiftUI (Apple)                  │
         └─────────────────────────────────────┘
                              │
                              ▼
         ┌─────────────────────────────────────┐
         │         Backend API                 │
         ├─────────────────────────────────────┤
         │  REST:                              │
         │  • GET /api/parking-reports/nearby  │
         │  • POST /api/parking-reports        │
         │  • PUT /api/parking-reports/:id/rate│
         │                                     │
         │  WebSocket:                         │
         │  • WS /api/parking-reports/ws       │
         └─────────────────────────────────────┘
```

## Data Flow

### 1. Fetching Nearby Reports

```
User Opens App
      │
      ▼
LocationManager ──────► Get Current Location
      │
      ▼
MapScreen ────────────► Request nearby reports
      │
      ▼
ParkingReportViewModel ► APIClient.fetchNearbyReports()
      │
      ▼
APIClient (async/await) ► Backend API GET request
      │
      ▼
JSON Response ─────────► Decode to [ParkingReport]
      │
      ▼
ViewModel Updates ─────► SwiftUI View Re-renders
      │
      ▼
Map Shows Pins ────────► User sees parking spots
```

### 2. Creating a Report

```
User Taps "Report Spot"
      │
      ▼
ReportSheet Opens ─────► Auto-fill GPS location
      │
      ▼
User Fills Form
      │
      ▼
User Taps Submit ──────► Validation
      │
      ▼
ViewModel.createReport()► APIClient.createParkingReport()
      │
      ▼
Backend API POST ───────► Create report in database
      │
      ▼
Response Returns ───────► New ParkingReport
      │
      ▼
ViewModel Updates ──────► Add to reports array
      │
      ▼
Map Updates ────────────► New pin appears
      │
      ▼
WebSocket Broadcasts ───► Other users see update
```

### 3. Real-time Updates

```
WebSocket Connection
      │
      ▼
WebSocketManager.connect(lat, lng)
      │
      ▼
Backend WS Endpoint ────► Subscribe to area
      │
      ▼
Another User Creates ───► Backend broadcasts
      │
      ▼
WebSocketManager.receive()
      │
      ▼
Decode JSON ────────────► ParkingReport
      │
      ▼
reportPublisher.send(report)
      │
      ▼
ViewModel receives ─────► Update reports array
      │
      ▼
SwiftUI updates ────────► New pin appears live
```

## Key Architectural Patterns

### MVVM (Model-View-ViewModel)

- **View**: SwiftUI views (MapScreen, ReportSheet)
- **ViewModel**: ParkingReportViewModel (@Observable)
- **Model**: ParkingReport, ReportStatus, etc.

### Separation of Concerns

- **Views**: Only UI logic, no business logic
- **ViewModels**: Business logic, state management
- **Services**: External communication (API, Location)
- **Models**: Data structures only

### Dependency Injection Ready

```swift
// Can inject mock services for testing
ParkingReportViewModel(
    apiClient: MockAPIClient(),
    webSocketManager: MockWebSocketManager()
)
```

### Swift 6 Concurrency

- **Actor**: APIClient for thread-safe networking
- **@MainActor**: ViewModels and Views on main thread
- **async/await**: All API calls use structured concurrency
- **Sendable**: All models thread-safe

### Reactive Programming

- **@Observable**: Modern SwiftUI state management
- **Combine**: WebSocket messages via PassthroughSubject
- **Published changes**: Auto-update UI on data changes

## Communication Patterns

### View ↔ ViewModel

```swift
// View observes ViewModel
@State private var viewModel = ParkingReportViewModel()

// View calls ViewModel methods
await viewModel.fetchNearbyReports(...)

// ViewModel updates trigger View refresh
viewModel.reports.append(newReport) // Auto-updates UI
```

### ViewModel ↔ Service

```swift
// ViewModel uses Services
let reports = try await apiClient.fetchNearbyReports(...)

// Services are injected (can be mocked)
init(apiClient: APIClient, webSocketManager: WebSocketManager)
```

### Service ↔ Backend

```swift
// REST API
let (data, response) = try await session.data(for: request)

// WebSocket
webSocketTask?.receive { result in ... }
```

## Thread Safety

### Actor Isolation

```swift
actor APIClient {
    // All methods automatically thread-safe
    func fetchNearbyReports(...) async throws -> [ParkingReport]
}
```

### MainActor for UI

```swift
@MainActor
@Observable
final class ParkingReportViewModel {
    // All properties and methods on main thread
}
```

### Sendable Data

```swift
struct ParkingReport: Sendable {
    // Can safely pass between threads
}
```

## Error Handling Flow

```
Error Occurs in Service
      │
      ▼
Throw APIError ─────────► ViewModel catches
      │
      ▼
Set error property ─────► @Observable triggers update
      │
      ▼
View shows ErrorBanner ─► User sees friendly message
      │
      ▼
User dismisses ─────────► error = nil
      │
      ▼
Banner disappears ──────► Clean state
```

## State Management

### ViewModel State

```swift
@Observable class ParkingReportViewModel {
    var reports: [ParkingReport] = []      // List of reports
    var isLoading: Bool = false            // Loading indicator
    var error: APIError? = nil             // Error state
}
```

### View State

```swift
struct MapScreen: View {
    @State private var showingReportSheet = false
    @State private var selectedReport: ParkingReport?
    @State private var cameraPosition: MapCameraPosition
}
```

### Location State

```swift
@Observable class LocationManager {
    var currentLocation: CLLocation?
    var permissionStatus: LocationPermissionStatus
}
```

This architecture ensures:

- ✅ Clear separation of concerns
- ✅ Testable components
- ✅ Thread-safe operations
- ✅ Scalable structure
- ✅ Easy to maintain
- ✅ Following iOS best practices
