# SpotFinder Backend - Heroku Deployment Guide

## Prerequisites
1. Install Heroku CLI: `brew tap heroku/brew && brew install heroku`
2. Login to Heroku: `heroku login`

## Initial Setup

### 1. Create Heroku App
```bash
cd backend
heroku create spotfinder-backend
```

### 2. Add PostgreSQL Database
```bash
heroku addons:create heroku-postgresql:essential-0
```

### 3. Set Environment Variables
```bash
heroku config:set NODE_ENV=production
heroku config:set LOG_LEVEL=info
heroku config:set WEBSOCKET_CORS_ORIGIN=*
heroku config:set DEFAULT_SEARCH_RADIUS=500
heroku config:set REPORT_EXPIRATION_TIME=1800000
heroku config:set DATABASE_SSL=true
```

### 4. Deploy to Heroku
```bash
# Initialize git in backend folder (if not already done)
git init
git add .
git commit -m "Initial backend setup for Heroku"

# Add Heroku remote
heroku git:remote -a spotfinder-backend

# Deploy
git push heroku main
```

### 5. Run Database Migrations
```bash
# Set DATABASE_URL locally to run migrations
heroku config:get DATABASE_URL

# Copy the URL and run migrations locally
export DATABASE_URL="<paste-url-here>"
npm run db:push

# OR run migrations directly on Heroku
heroku run npm run db:push
```

### 6. Open Your App
```bash
heroku open
heroku logs --tail
```

## Update iOS App Configuration

After deployment, update the iOS app to use your Heroku URL:

```swift
// In AppConfiguration.swift
self.baseURL = "https://spotfinder-backend-xxxx.herokuapp.com"
```

## Useful Commands

```bash
# View logs
heroku logs --tail

# View app info
heroku info

# Restart app
heroku restart

# Run console commands
heroku run bash

# Check database connection
heroku pg:info

# Open database console
heroku pg:psql

# View config
heroku config

# Scale dynos
heroku ps:scale web=1
```

## Environment Variables on Heroku

Your app automatically gets:
- `DATABASE_URL` - PostgreSQL connection string (from addon)
- `PORT` - Port to bind to (set by Heroku)

You set:
- `NODE_ENV=production`
- `LOG_LEVEL=info`
- `WEBSOCKET_CORS_ORIGIN=*`
- `DEFAULT_SEARCH_RADIUS=500`
- `REPORT_EXPIRATION_TIME=1800000`
- `DATABASE_SSL=true`

## Troubleshooting

### App crashes on startup
```bash
heroku logs --tail
```

### Database connection issues
```bash
heroku config:get DATABASE_URL
heroku pg:info
```

### Build failures
```bash
heroku builds
heroku builds:info <build-id>
```

## Deployment from GitHub (Optional)

1. Push your code to GitHub
2. Connect Heroku to GitHub: `heroku git:remote -a spotfinder-backend`
3. Enable automatic deploys from GitHub in Heroku dashboard
4. Or manually deploy: `git push heroku main`
