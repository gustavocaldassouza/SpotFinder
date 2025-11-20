#!/bin/bash

# SpotFinder Backend - Heroku Deployment Script
# This script automates the deployment process to Heroku

set -e  # Exit on error

echo "🚀 SpotFinder Backend - Heroku Deployment"
echo "========================================"
echo ""

# Check if Heroku CLI is installed
if ! command -v heroku &> /dev/null; then
    echo "❌ Heroku CLI not found. Please install it first:"
    echo "   brew tap heroku/brew && brew install heroku"
    exit 1
fi

echo "✅ Heroku CLI found"
echo ""

# Check if logged in to Heroku
if ! heroku auth:whoami &> /dev/null; then
    echo "🔐 Please login to Heroku..."
    heroku login
fi

echo "✅ Logged in to Heroku"
echo ""

# Set app name
APP_NAME="${1:-spotfinder-backend}"
echo "📦 App name: $APP_NAME"
echo ""

# Check if app exists
if heroku apps:info -a $APP_NAME &> /dev/null; then
    echo "✅ App '$APP_NAME' already exists"
else
    echo "🆕 Creating new Heroku app: $APP_NAME"
    heroku create $APP_NAME
    echo "✅ App created"
fi
echo ""

# Check if PostgreSQL addon exists
if heroku addons:info -a $APP_NAME heroku-postgresql &> /dev/null; then
    echo "✅ PostgreSQL addon already exists"
else
    echo "🗄️  Adding PostgreSQL addon..."
    heroku addons:create heroku-postgresql:essential-0 -a $APP_NAME
    echo "✅ PostgreSQL addon added"
    echo "⏳ Waiting for database to be ready..."
    sleep 10
fi
echo ""

# Set environment variables
echo "🔧 Setting environment variables..."
heroku config:set -a $APP_NAME \
    NODE_ENV=production \
    LOG_LEVEL=info \
    WEBSOCKET_CORS_ORIGIN="*" \
    DEFAULT_SEARCH_RADIUS=500 \
    REPORT_EXPIRATION_TIME=1800000 \
    DATABASE_SSL=true

echo "✅ Environment variables set"
echo ""

# Add Heroku remote if not exists
if ! git remote | grep -q "^heroku$"; then
    echo "🔗 Adding Heroku remote..."
    heroku git:remote -a $APP_NAME
    echo "✅ Heroku remote added"
else
    echo "✅ Heroku remote already exists"
fi
echo ""

# Commit changes
echo "💾 Committing Heroku deployment files..."
git add .
if git diff --staged --quiet; then
    echo "✅ No changes to commit"
else
    git commit -m "Add Heroku deployment configuration"
    echo "✅ Changes committed"
fi
echo ""

# Deploy to Heroku
echo "🚢 Deploying to Heroku..."
echo "This may take a few minutes..."
git push heroku main

echo ""
echo "✅ Deployment complete!"
echo ""

# Get app URL
APP_URL=$(heroku info -a $APP_NAME -s | grep web_url | cut -d= -f2)
echo "🌐 Your app is available at: $APP_URL"
echo ""

# Run database migrations
echo "🗄️  Running database migrations..."
heroku run -a $APP_NAME npm run db:push

echo ""
echo "✅ Database migrations complete!"
echo ""

# Show app info
echo "📊 App Information:"
heroku info -a $APP_NAME
echo ""

echo "✨ Deployment successful! ✨"
echo ""
echo "📝 Next steps:"
echo "1. Update your iOS app to use: $APP_URL"
echo "2. View logs: heroku logs --tail -a $APP_NAME"
echo "3. Open app: heroku open -a $APP_NAME"
echo ""
