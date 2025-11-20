# 🚀 Quick Deployment to Heroku

## Option 1: Automated Script (Recommended)

```bash
cd backend
./deploy-heroku.sh
```

This script will:

- Check if Heroku CLI is installed
- Login to Heroku (if needed)
- Create app and PostgreSQL database
- Set environment variables
- Deploy the code
- Run database migrations

## Option 2: Manual Deployment

### Step 1: Install Heroku CLI (if not installed)

```bash
brew tap heroku/brew && brew install heroku
```

### Step 2: Login

```bash
heroku login
```

### Step 3: Create App and Database

```bash
cd backend
heroku create spotfinder-backend
heroku addons:create heroku-postgresql:essential-0
```

### Step 4: Configure Environment

```bash
heroku config:set \
    NODE_ENV=production \
    LOG_LEVEL=info \
    WEBSOCKET_CORS_ORIGIN="*" \
    DEFAULT_SEARCH_RADIUS=500 \
    REPORT_EXPIRATION_TIME=1800000 \
    DATABASE_SSL=true
```

### Step 5: Deploy

```bash
git push heroku main
```

### Step 6: Run Migrations

```bash
heroku run npm run db:push
```

## After Deployment

### Get Your App URL

```bash
heroku info -s | grep web_url
```

### Update iOS App

Update `AppConfiguration.swift`:

```swift
self.baseURL = "https://your-app-name.herokuapp.com"
```

### Monitor Logs

```bash
heroku logs --tail
```

### Test API

```bash
curl https://your-app-name.herokuapp.com/health
```

## Common Issues

### Build fails

- Check logs: `heroku logs --tail`
- Verify all dependencies are in `dependencies`, not `devDependencies`

### App crashes

- Check environment variables: `heroku config`
- Verify DATABASE_URL is set: `heroku config:get DATABASE_URL`

### Database connection fails

- Check database status: `heroku pg:info`
- Verify DATABASE_SSL=true is set

### Need to redeploy

```bash
git push heroku main
```
