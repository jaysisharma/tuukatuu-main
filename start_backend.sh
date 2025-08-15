#!/bin/bash

echo "🚀 Starting Tuukatuu Backend Server..."
echo "======================================"

# Check if MongoDB is running
echo "🔍 Checking MongoDB status..."
if pgrep -x "mongod" > /dev/null; then
    echo "✅ MongoDB is running"
else
    echo "⚠️  MongoDB is not running. Please start MongoDB first."
    echo "   On macOS: brew services start mongodb-community"
    echo "   On Ubuntu: sudo systemctl start mongod"
    exit 1
fi

# Navigate to backend directory
cd backend

# Install dependencies if needed
echo "📦 Checking dependencies..."
if [ ! -d "node_modules" ]; then
    echo "Installing dependencies..."
    npm install
fi

# Start the server
echo "🌐 Starting server on port 3000..."
echo "   API will be available at: http://localhost:3000/api"
echo "   T-Mart endpoints:"
echo "     - /api/tmart/banners"
echo "     - /api/tmart/categories/featured"
echo "     - /api/tmart/popular"
echo "     - /api/daily-essentials"
echo "     - /api/tmart/deals/today"
echo "     - /api/tmart/recommendations"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

# Start the development server
npm run dev
