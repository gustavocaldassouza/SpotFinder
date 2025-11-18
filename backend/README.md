# SpotFinder Backend API

A high-performance, real-time parking spot sharing API built with NestJS, TypeScript, Drizzle ORM, and PostgreSQL.

## 🚀 Features

- **Real-time Updates**: WebSocket support for live parking report notifications
- **Geographic Queries**: Efficient nearby parking search using Haversine formula
- **Type-Safe Database**: Drizzle ORM with full TypeScript inference
- **Validation**: Runtime schema validation with Zod
- **Structured Logging**: Production-ready logging with Pino
- **Docker Support**: Containerized deployment ready
- **Modular Architecture**: Clean separation of concerns with DI

## 📋 Prerequisites

- Node.js 20+ 
- PostgreSQL 15+
- npm or yarn
- Docker (optional)

## 🛠️ Installation

### Local Development

1. **Clone and navigate to backend**
```bash
cd backend
```

2. **Install dependencies**
```bash
npm install
```

3. **Set up environment**
```bash
cp .env.example .env
# Edit .env with your database credentials
```

4. **Start PostgreSQL** (if not using Docker)
```bash
# Using Docker
docker run --name spotfinder-db \
  -e POSTGRES_USER=spotfinder \
  -e POSTGRES_PASSWORD=spotfinder123 \
  -e POSTGRES_DB=spotfinder \
  -p 5432:5432 \
  -d postgres:15-alpine
```

5. **Run database migrations**
```bash
npm run db:generate
npm run db:push
```

6. **Start development server**
```bash
npm run start:dev
```

The API will be available at `http://localhost:3000`

### Docker Deployment

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

## 📡 API Endpoints

### Health Check
```
GET /health
Response: { "status": "ok", "timestamp": "2025-11-17T...", "service": "SpotFinder API" }
```

### Get Nearby Parking Reports
```
GET /api/parking-reports/nearby?lat=45.5017&lng=-73.5673&radius=500

Response:
{
  "success": true,
  "data": {
    "reports": [
      {
        "id": "uuid",
        "latitude": 45.5017,
        "longitude": -73.5673,
        "status": "available",
        "description": "Queen St, between Pine and Oak",
        "createdAt": "2025-11-16T20:30:00Z",
        "createdAgo": "2 min ago",
        "accuracyRating": 4.5,
        "totalRatings": 12,
        "distance": 124.5,
        "isActive": true,
        "expiresAt": "2025-11-16T21:00:00Z"
      }
    ],
    "count": 1
  }
}
```

### Submit New Parking Report
```
POST /api/parking-reports
Content-Type: application/json

Request:
{
  "latitude": 45.5017,
  "longitude": -73.5673,
  "status": "available",
  "description": "Queen St, between Pine and Oak"
}

Response:
{
  "success": true,
  "data": {
    "id": "uuid",
    "createdAt": "2025-11-16T20:30:00Z"
  }
}
```

### Get Report Details
```
GET /api/parking-reports/:id

Response:
{
  "success": true,
  "data": {
    "id": "uuid",
    "latitude": 45.5017,
    "longitude": -73.5673,
    "status": "available",
    "description": "Queen St, between Pine and Oak",
    "createdAt": "2025-11-16T20:30:00Z",
    "createdAgo": "2 min ago",
    "accuracyRating": 4.5,
    "totalRatings": 12,
    "isActive": true,
    "expiresAt": "2025-11-16T21:00:00Z"
  }
}
```

### Rate Report Accuracy
```
PUT /api/parking-reports/:id/rate
Content-Type: application/json

Request:
{
  "rating": 1  // 1 for accurate, -1 for inaccurate
}

Response:
{
  "success": true,
  "data": {
    "accuracyRating": 4.5,
    "totalRatings": 13
  }
}
```

## 🔌 WebSocket Events

Connect to WebSocket at `ws://localhost:3000`

### Subscribe to Nearby Updates
```javascript
socket.emit('parking:nearby', {
  lat: 45.5017,
  lng: -73.5673,
  radius: 500
});

// Response
{
  "success": true,
  "message": "Subscribed to nearby parking updates",
  "room": "nearby:45.502:-73.567:500"
}
```

### Receive Real-time Events
```javascript
// New parking report
socket.on('parking:report:new', (report) => {
  console.log('New report:', report);
});

// Report rated
socket.on('parking:report:rated', (data) => {
  console.log('Rating update:', data);
  // { id: "uuid", accuracyRating: 4.5, totalRatings: 13 }
});

// Report expired
socket.on('parking:report:expired', (data) => {
  console.log('Report expired:', data);
  // { id: "uuid" }
});
```

### Unsubscribe
```javascript
socket.emit('parking:unsubscribe');
```

## 🗄️ Database Schema

### parking_reports
- `id` - UUID (PK)
- `latitude` - REAL (NOT NULL)
- `longitude` - REAL (NOT NULL)
- `status` - VARCHAR(50) - 'available' | 'taken'
- `description` - TEXT
- `user_id` - UUID (for future auth)
- `created_at` - TIMESTAMP
- `updated_at` - TIMESTAMP
- `expires_at` - TIMESTAMP (NOT NULL)
- `total_ratings` - INTEGER (default 0)
- `sum_ratings` - INTEGER (default 0)
- `is_active` - BOOLEAN (default true)

### report_ratings
- `id` - UUID (PK)
- `report_id` - UUID (FK → parking_reports.id, CASCADE)
- `user_id` - UUID (for future auth)
- `rating` - SMALLINT (1 or -1)
- `created_at` - TIMESTAMP

## 🧪 Development

### Available Scripts

```bash
# Development
npm run start:dev          # Start with hot reload
npm run start:debug        # Start with debugger

# Building
npm run build              # Build for production
npm run start:prod         # Run production build

# Database
npm run db:generate        # Generate migrations
npm run db:push            # Push schema to database
npm run db:studio          # Open Drizzle Studio

# Testing
npm run test               # Run unit tests
npm run test:watch         # Run tests in watch mode
npm run test:cov           # Generate coverage report
npm run test:e2e           # Run e2e tests

# Code Quality
npm run lint               # Lint and fix
npm run format             # Format code
```

### Project Structure

```
backend/
├── src/
│   ├── main.ts                    # Application entry point
│   ├── app.module.ts              # Root module
│   ├── app.controller.ts          # Health check endpoint
│   ├── config/
│   │   └── environment.ts         # Environment validation
│   ├── database/
│   │   ├── schema.ts              # Drizzle schema
│   │   ├── client.ts              # Database client
│   │   ├── database.module.ts     # Database module
│   │   └── migrations/            # SQL migrations
│   ├── parking/
│   │   ├── parking.module.ts      # Parking module
│   │   ├── parking.controller.ts  # REST endpoints
│   │   ├── parking.service.ts     # Business logic
│   │   ├── parking.repository.ts  # Database queries
│   │   ├── dto/                   # Data transfer objects
│   │   └── entities/              # Domain entities
│   ├── websocket/
│   │   ├── websocket.module.ts    # WebSocket module
│   │   ├── websocket.gateway.ts   # Socket.io gateway
│   │   └── websocket.service.ts   # WebSocket logic
│   ├── common/
│   │   ├── filters/
│   │   │   └── exception.filter.ts # Global error handler
│   │   └── pipes/
│   │       └── validation.pipe.ts  # Zod validation
│   └── utils/
│       └── geolocation.ts         # Distance calculations
├── drizzle.config.ts              # Drizzle configuration
├── docker-compose.yml             # Docker setup
├── Dockerfile                     # Container definition
└── package.json                   # Dependencies
```

## 🔧 Configuration

Environment variables in `.env`:

```env
# Database
DATABASE_URL=postgresql://user:password@localhost:5432/spotfinder
DATABASE_SSL=false

# Server
NODE_ENV=development
PORT=3000
LOG_LEVEL=debug

# WebSocket
WEBSOCKET_CORS_ORIGIN=http://localhost:3000

# Business Logic
DEFAULT_SEARCH_RADIUS=500           # meters
REPORT_EXPIRATION_TIME=1800000      # 30 minutes in milliseconds
```

## 🏗️ Architecture

### Modular Design
- **DatabaseModule**: Global module for Drizzle ORM
- **ParkingModule**: Report management business logic
- **WebSocketModule**: Real-time communication

### Design Patterns
- **Repository Pattern**: Database abstraction
- **Dependency Injection**: NestJS DI container
- **DTO Pattern**: Input validation with Zod
- **Exception Filters**: Centralized error handling

### Key Features
- Type-safe database queries with Drizzle ORM
- Runtime validation with Zod schemas
- Structured logging with Pino
- WebSocket rooms for location-based subscriptions
- Haversine formula for accurate distance calculation
- Automatic report expiration handling

## 🚢 Deployment

### Docker Production

```bash
# Build and run
docker-compose up -d

# Scale horizontally (requires Redis adapter for WebSocket)
docker-compose up -d --scale api=3
```

### Manual Deployment

```bash
# Build
npm run build

# Run migrations
npm run db:push

# Start production server
npm run start:prod
```

## 📝 API Client Example

```typescript
// TypeScript client example
import { io } from 'socket.io-client';

const API_BASE = 'http://localhost:3000';

// REST API
async function getNearbyReports(lat: number, lng: number, radius: number) {
  const response = await fetch(
    `${API_BASE}/api/parking-reports/nearby?lat=${lat}&lng=${lng}&radius=${radius}`
  );
  return response.json();
}

async function createReport(data: { 
  latitude: number; 
  longitude: number; 
  status: 'available' | 'taken'; 
  description?: string 
}) {
  const response = await fetch(`${API_BASE}/api/parking-reports`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data),
  });
  return response.json();
}

async function rateReport(id: string, rating: 1 | -1) {
  const response = await fetch(`${API_BASE}/api/parking-reports/${id}/rate`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ rating }),
  });
  return response.json();
}

// WebSocket
const socket = io(API_BASE);

socket.on('connect', () => {
  console.log('Connected to WebSocket');
  
  // Subscribe to nearby updates
  socket.emit('parking:nearby', {
    lat: 45.5017,
    lng: -73.5673,
    radius: 500,
  });
});

socket.on('parking:report:new', (report) => {
  console.log('New report:', report);
});

socket.on('parking:report:rated', (data) => {
  console.log('Rating update:', data);
});
```

## 📄 License

UNLICENSED - Private project

---

Built with ❤️ using NestJS, TypeScript, and modern best practices for 2025.
