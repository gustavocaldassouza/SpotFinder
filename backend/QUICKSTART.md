# SpotFinder Backend - Quick Start Guide

## 🚀 Quick Setup (5 minutes)

### Step 1: Prerequisites Check
Ensure you have:
- Node.js 20+ installed
- PostgreSQL 15+ (or Docker)
- npm installed

### Step 2: Install Dependencies
```bash
cd backend
npm install
```

### Step 3: Set Up Database

**Option A: Using Docker (Recommended)**
```bash
docker run --name spotfinder-db \
  -e POSTGRES_USER=spotfinder \
  -e POSTGRES_PASSWORD=spotfinder123 \
  -e POSTGRES_DB=spotfinder \
  -p 5432:5432 \
  -d postgres:15-alpine
```

**Option B: Using existing PostgreSQL**
Create a database called `spotfinder` and update the `.env` file with your credentials.

### Step 4: Configure Environment
```bash
cp .env.example .env
```

Edit `.env` if needed (default works with Docker setup above):
```env
DATABASE_URL=postgresql://spotfinder:spotfinder123@localhost:5432/spotfinder
PORT=3000
```

### Step 5: Push Database Schema
```bash
npm run db:push
```

### Step 6: Start Development Server
```bash
npm run start:dev
```

✅ **Done!** Your API is running at `http://localhost:3000`

## 🧪 Test Your API

### Health Check
```bash
curl http://localhost:3000/health
```

### Create a Parking Report
```bash
curl -X POST http://localhost:3000/api/parking-reports \
  -H "Content-Type: application/json" \
  -d '{
    "latitude": 45.5017,
    "longitude": -73.5673,
    "status": "available",
    "description": "Near coffee shop on Queen St"
  }'
```

### Get Nearby Reports
```bash
curl "http://localhost:3000/api/parking-reports/nearby?lat=45.5017&lng=-73.5673&radius=1000"
```

## 🐳 Docker Quick Start

**Easiest way to run everything:**
```bash
docker-compose up -d
```

This starts:
- PostgreSQL database
- SpotFinder API
- All configured and ready to use

View logs:
```bash
docker-compose logs -f
```

Stop:
```bash
docker-compose down
```

## 📚 Next Steps

- Read the full [README.md](./README.md) for detailed documentation
- Explore API endpoints at `http://localhost:3000`
- Test WebSocket connections with Socket.io client
- Check out the database schema in `src/database/schema.ts`

## 🛠️ Common Commands

```bash
# Development
npm run start:dev        # Start with hot reload
npm run build            # Build for production

# Database
npm run db:generate      # Generate migration files
npm run db:push          # Push schema to database
npm run db:studio        # Open database GUI

# Testing
npm run test             # Run tests
npm run lint             # Lint code
```

## 🐛 Troubleshooting

**Database connection error?**
- Ensure PostgreSQL is running
- Check your `.env` DATABASE_URL is correct
- Verify database credentials

**Port 3000 already in use?**
- Change `PORT` in `.env` file
- Or kill the process using port 3000

**Build errors?**
- Run `npm install` again
- Clear `node_modules` and reinstall: `rm -rf node_modules && npm install`

## 💡 Pro Tips

1. Use `npm run db:studio` to visually browse your database
2. Check logs with structured output via Pino logger
3. WebSocket events are logged in debug mode
4. API responses follow a consistent format: `{ success: true, data: {...} }`

---

Need help? Check the [README.md](./README.md) or open an issue on GitHub.
