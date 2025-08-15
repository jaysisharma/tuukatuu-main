#!/bin/bash

echo "🔍 Checking Backend Server Status..."
echo "===================================="

# Check if server is running on port 3000
echo "🌐 Checking if server is running on port 3000..."
if lsof -i :3000 > /dev/null 2>&1; then
    echo "✅ Server is running on port 3000"
else
    echo "❌ No server running on port 3000"
    echo "   Start the server with: cd backend && npm run dev"
    exit 1
fi

# Test basic connectivity
echo -e "\n🔗 Testing basic connectivity..."
if curl -s http://localhost:3000 > /dev/null; then
    echo "✅ Basic connectivity successful"
else
    echo "❌ Basic connectivity failed"
    exit 1
fi

# Test API endpoints
echo -e "\n🧪 Testing API endpoints..."

endpoints=(
    "/api/tmart/banners"
    "/api/tmart/categories/featured?limit=8"
    "/api/tmart/popular?limit=8"
    "/api/daily-essentials?limit=6"
    "/api/tmart/deals/today?limit=4"
    "/api/tmart/recommendations?limit=6"
)

for endpoint in "${endpoints[@]}"; do
    echo -n "Testing $endpoint... "
    if response=$(curl -s "http://localhost:3000$endpoint" 2>/dev/null); then
        if echo "$response" | grep -q '"success":true'; then
            echo "✅ SUCCESS"
        else
            echo "⚠️  RESPONDED (but no success)"
        fi
    else
        echo "❌ FAILED"
    fi
done

echo -e "\n🎉 Backend check completed!"
echo -e "\n📱 Next steps:"
echo "   1. Run the Flutter app"
echo "   2. Navigate to T-Mart screen"
echo "   3. Check console logs for detailed API responses"
echo "   4. Use the debug button (bug icon) in categories section"
