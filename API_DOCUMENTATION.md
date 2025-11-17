# API Integration Guide

This document describes how SpotFinder integrates with the backend API.

## Backend Requirements

The app expects a NestJS backend with the following endpoints:

### Base URL Configuration

Default (Development): `http://localhost:3000`
WebSocket (Development): `ws://localhost:3000`

Configure in `Utilities/AppConfiguration.swift`

## REST API Endpoints

### 1. Get Nearby Parking Reports

**Endpoint:** `GET /api/parking-reports/nearby`

**Query Parameters:**

- `lat` (number, required) - Latitude coordinate
- `lng` (number, required) - Longitude coordinate
- `radius` (number, optional) - Search radius in meters (default: 500)

**Request Example:**

```http
GET /api/parking-reports/nearby?lat=37.7749&lng=-122.4194&radius=500
```

**Response Example:**

```json
[
  {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "latitude": 37.7749,
    "longitude": -122.4194,
    "streetName": "Market Street",
    "crossStreets": "5th & 6th Street",
    "status": "available",
    "createdAt": "2024-11-17T21:00:00.000Z",
    "upvotes": 5,
    "downvotes": 1
  }
]
```

**Status Codes:**

- `200` - Success
- `400` - Invalid parameters
- `500` - Server error

### 2. Create Parking Report

**Endpoint:** `POST /api/parking-reports`

**Headers:**

```
Content-Type: application/json
```

**Request Body:**

```json
{
  "latitude": 37.7749,
  "longitude": -122.4194,
  "streetName": "Market Street",
  "crossStreets": "5th & 6th Street",
  "status": "available"
}
```

**Response Example:**

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "latitude": 37.7749,
  "longitude": -122.4194,
  "streetName": "Market Street",
  "crossStreets": "5th & 6th Street",
  "status": "available",
  "createdAt": "2024-11-17T21:00:00.000Z",
  "upvotes": 0,
  "downvotes": 0
}
```

**Status Codes:**

- `201` - Created successfully
- `400` - Invalid request body
- `500` - Server error

**Validation Rules:**

- `latitude`: -90 to 90
- `longitude`: -180 to 180
- `streetName`: Required, 1-200 characters
- `crossStreets`: Optional, max 200 characters
- `status`: Must be "available" or "taken"

### 3. Rate Parking Report

**Endpoint:** `PUT /api/parking-reports/:id/rate`

**Headers:**

```
Content-Type: application/json
```

**Path Parameters:**

- `id` (string, required) - Report UUID

**Request Body:**

```json
{
  "isUpvote": true
}
```

**Response Example:**

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "latitude": 37.7749,
  "longitude": -122.4194,
  "streetName": "Market Street",
  "crossStreets": "5th & 6th Street",
  "status": "available",
  "createdAt": "2024-11-17T21:00:00.000Z",
  "upvotes": 6,
  "downvotes": 1
}
```

**Status Codes:**

- `200` - Rated successfully
- `404` - Report not found
- `400` - Invalid request
- `500` - Server error

## WebSocket Connection

### Connection

**Endpoint:** `WS /api/parking-reports/ws`

**Query Parameters:**

- `lat` (number, required) - Latitude for filtering updates
- `lng` (number, required) - Longitude for filtering updates

**Connection Example:**

```
ws://localhost:3000/api/parking-reports/ws?lat=37.7749&lng=-122.4194
```

### Message Format

**Server → Client (New Report):**

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "latitude": 37.775,
  "longitude": -122.4195,
  "streetName": "Mission Street",
  "crossStreets": "6th Street",
  "status": "available",
  "createdAt": "2024-11-17T21:05:00.000Z",
  "upvotes": 0,
  "downvotes": 0
}
```

**Server → Client (Updated Report):**

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "latitude": 37.7749,
  "longitude": -122.4194,
  "streetName": "Market Street",
  "crossStreets": "5th & 6th Street",
  "status": "taken",
  "createdAt": "2024-11-17T21:00:00.000Z",
  "upvotes": 10,
  "downvotes": 2
}
```

### Connection Lifecycle

1. **Connect** - Establish WebSocket on app launch with user location
2. **Subscribe** - Automatically receive updates for nearby reports
3. **Reconnect** - Auto-retry with exponential backoff (max 5 attempts)
4. **Disconnect** - Close connection when app goes to background

## Swift Implementation

### APIClient Usage

```swift
// Fetch nearby reports
let reports = try await APIClient.shared.fetchNearbyReports(
    latitude: 37.7749,
    longitude: -122.4194,
    radius: 500
)

// Create new report
let request = CreateParkingReportRequest(
    latitude: 37.7749,
    longitude: -122.4194,
    streetName: "Market Street",
    crossStreets: "5th & 6th Street",
    status: .available
)
let newReport = try await APIClient.shared.createParkingReport(request)

// Rate a report
let updatedReport = try await APIClient.shared.rateReport(
    reportId: "550e8400-e29b-41d4-a716-446655440000",
    isUpvote: true
)
```

### WebSocketManager Usage

```swift
// Connect to WebSocket
webSocketManager.connect(latitude: 37.7749, longitude: -122.4194)

// Subscribe to updates
webSocketManager.reportPublisher
    .sink { newReport in
        print("Received update: \(newReport)")
    }
    .store(in: &cancellables)

// Disconnect
webSocketManager.disconnect()
```

## Error Handling

### HTTP Error Codes

The app handles these error scenarios:

- **Network Errors** - No internet connection, timeout
- **400 Bad Request** - Invalid parameters or request body
- **404 Not Found** - Report doesn't exist
- **500 Server Error** - Backend issue
- **Decoding Errors** - Invalid JSON format

### Error Messages

User-friendly error messages are shown for:

- ❌ No internet connection
- ❌ Server unreachable
- ❌ Invalid location data
- ❌ Report submission failed
- ❌ WebSocket disconnected

## Date/Time Format

All timestamps use **ISO 8601** format with fractional seconds:

```
2024-11-17T21:00:00.000Z
```

Swift automatically handles encoding/decoding with:

```swift
decoder.dateDecodingStrategy = .iso8601
encoder.dateEncodingStrategy = .iso8601
```

## Testing the API

### Using curl

**Fetch nearby reports:**

```bash
curl "http://localhost:3000/api/parking-reports/nearby?lat=37.7749&lng=-122.4194&radius=500"
```

**Create a report:**

```bash
curl -X POST http://localhost:3000/api/parking-reports \
  -H "Content-Type: application/json" \
  -d '{
    "latitude": 37.7749,
    "longitude": -122.4194,
    "streetName": "Market Street",
    "crossStreets": "5th Street",
    "status": "available"
  }'
```

**Rate a report:**

```bash
curl -X PUT http://localhost:3000/api/parking-reports/550e8400-e29b-41d4-a716-446655440000/rate \
  -H "Content-Type: application/json" \
  -d '{"isUpvote": true}'
```

### Using Postman

1. Import the endpoints above
2. Set base URL to `http://localhost:3000`
3. Test each endpoint with sample data
4. Verify response format matches expected structure

## Backend Implementation Notes

Your NestJS backend should:

1. **Store reports** in a database (PostgreSQL, MongoDB, etc.)
2. **Calculate distances** using geospatial queries
3. **Broadcast updates** via WebSocket to connected clients
4. **Validate input** before storing
5. **Handle concurrent requests** safely
6. **Clean up old reports** (older than 1 hour)

### Sample NestJS Controller

```typescript
@Controller("api/parking-reports")
export class ParkingReportsController {
  @Get("nearby")
  async getNearbyReports(
    @Query("lat") lat: number,
    @Query("lng") lng: number,
    @Query("radius") radius: number = 500
  ) {
    // Implement geospatial query
  }

  @Post()
  async createReport(@Body() dto: CreateReportDto) {
    // Validate and save report
    // Broadcast to WebSocket clients
  }

  @Put(":id/rate")
  async rateReport(@Param("id") id: string, @Body() dto: RateReportDto) {
    // Update vote counts
    // Broadcast update
  }
}
```

## Performance Considerations

### Client-Side

- **Debounce map updates** - Don't fetch on every pan/zoom
- **Cache reports** - Keep recent data in memory
- **Batch rating requests** - Prevent spam
- **WebSocket reconnection** - Exponential backoff

### Server-Side

- **Database indexing** - Add geospatial indexes
- **Rate limiting** - Prevent abuse
- **Pagination** - Limit results to reasonable count
- **Connection pooling** - Handle many WebSocket connections

## Security Considerations

For MVP (current implementation):

- ✅ No authentication required
- ✅ Anonymous submissions allowed
- ⚠️ Rate limiting recommended
- ⚠️ Input validation required

For Production:

- 🔒 Add user authentication (JWT, OAuth)
- 🔒 Implement rate limiting per IP/user
- 🔒 Add report moderation system
- 🔒 Sanitize user input
- 🔒 Use HTTPS/WSS in production

## Monitoring & Logging

Recommended metrics to track:

- **Request latency** - API response times
- **Error rates** - 4xx, 5xx responses
- **WebSocket connections** - Active connections count
- **Report creation rate** - Reports per hour
- **Rating activity** - Votes per report

---

For implementation questions, refer to:

- `Services/APIClient.swift` - REST implementation
- `Services/WebSocketManager.swift` - WebSocket implementation
- `Models/ParkingReport.swift` - Data model definitions
