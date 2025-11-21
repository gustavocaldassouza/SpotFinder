# SpotFinder Backend API

Real-time parking spot sharing API built with NestJS, TypeScript, Drizzle ORM, and PostgreSQL.

## Features

- RESTful API endpoints for parking reports
- WebSocket support for real-time updates
- Geographic queries with Haversine formula
- Type-safe database operations with Drizzle ORM
- Runtime validation with Zod
- Structured logging with Pino
- Docker support

## Prerequisites

- Node.js 20+
- PostgreSQL 15+
- npm or yarn
- Docker (optional)

## Installation

```bash
cd backend
npm install

# Setup environment
cp .env.example .env

# Start PostgreSQL (Docker)
docker run --name spotfinder-db \
  -e POSTGRES_USER=spotfinder \
  -e POSTGRES_PASSWORD=spotfinder123 \
  -e POSTGRES_DB=spotfinder \
  -p 5432:5432 \
  -d postgres:15-alpine

# Run database migrations
npm run db:push

# Start development server
npm run start:dev
```

API will be available at `http://localhost:3000`

## API Endpoints

### REST API

- `GET /health` - Health check
- `GET /api/parking-reports/nearby?lat=X&lng=Y&radius=500` - Nearby reports
- `POST /api/parking-reports` - Create report
- `GET /api/parking-reports/:id` - Get report
- `PUT /api/parking-reports/:id/rate` - Rate report

### WebSocket

Connect to `ws://localhost:3000`

- `parking:nearby` - Subscribe to location updates
- `parking:report:new` - New report broadcast
- `parking:report:rated` - Rating update
- `parking:unsubscribe` - Unsubscribe from updates

## Database Schema

### parking_reports

- `id` - UUID primary key
- `latitude` / `longitude` - Location coordinates
- `status` - 'available' | 'taken'
- `description` - Optional text description
- `created_at` / `updated_at` - Timestamps
- `expires_at` - Auto-expiration timestamp
- `total_ratings` / `sum_ratings` - Rating aggregates
- `is_active` - Active status

### report_ratings

- `id` - UUID primary key
- `report_id` - Foreign key to parking_reports
- `rating` - 1 (upvote) or -1 (downvote)
- `created_at` - Timestamp

## Development Commands

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
npm run test:e2e           # Run e2e tests

# Code Quality
npm run lint               # Lint and fix
npm run format             # Format code
```

## Docker Deployment

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

## Environment Variables

Create a `.env` file:

```env
DATABASE_URL=postgresql://user:password@localhost:5432/spotfinder
DATABASE_SSL=false
NODE_ENV=development
PORT=3000
LOG_LEVEL=debug
WEBSOCKET_CORS_ORIGIN=http://localhost:3000
DEFAULT_SEARCH_RADIUS=500
REPORT_EXPIRATION_TIME=1800000
```

## Contributing

Contributions are welcome! Please ensure:

- Code follows the existing style
- Tests pass
- Documentation is updated

## License

This project is licensed under the MIT License.
