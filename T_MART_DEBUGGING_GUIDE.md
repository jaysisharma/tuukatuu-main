# T-Mart Screen Debugging Guide

## 🚀 Quick Start

### 1. Start Backend Server
```bash
cd backend
npm install  # If first time
npm run dev
```

### 2. Check MongoDB
Ensure MongoDB is running:
```bash
# macOS
brew services start mongodb-community

# Ubuntu
sudo systemctl start mongod

# Check status
mongosh
```

### 3. Test Backend Endpoints
Use the test script:
```bash
cd backend
node test_backend.js
```

## 🔍 Debugging Steps

### Step 1: Check Backend Server
- ✅ Server running on port 3000
- ✅ MongoDB connected
- ✅ API endpoints responding

### Step 2: Check Flutter App Configuration
- ✅ `AppConfig.baseUrl` set to `http://localhost:3000/api`
- ✅ Internet permissions in AndroidManifest.xml
- ✅ App Transport Security in iOS Info.plist

### Step 3: Check Network Requests
Open Flutter DevTools and check:
- Network tab for failed requests
- Console for error messages
- API response status codes

### Step 4: Check Data Flow
1. **Banners**: `/tmart/banners`
2. **Categories**: `/tmart/categories/featured?limit=8`
3. **Popular Products**: `/tmart/popular?limit=8`
4. **Daily Essentials**: `/daily-essentials?limit=6`
5. **Today's Deals**: `/tmart/deals/today?limit=4`
6. **Recommendations**: `/tmart/recommendations?limit=6`

## 🐛 Common Issues & Solutions

### Issue 1: Categories Not Loading
**Symptoms**: Empty categories section, error message
**Debug Steps**:
1. Check console logs for API responses
2. Verify `/tmart/categories/featured` endpoint
3. Check if categories exist in database
4. Verify `isFeatured: true` on categories

**Solutions**:
```bash
# Seed featured categories
cd backend
node seed/enhance_featured_categories.js
```

### Issue 2: Network Errors
**Symptoms**: "Failed to load data" errors
**Debug Steps**:
1. Check if backend server is running
2. Verify `localhost:3000` is accessible
3. Check firewall/antivirus settings
4. Test with `curl http://localhost:3000/api/tmart/banners`

**Solutions**:
- Ensure backend server is running
- Check network configuration
- Verify port 3000 is not blocked

### Issue 3: Empty Data
**Symptoms**: Sections show "No data available"
**Debug Steps**:
1. Check database for data
2. Verify API endpoints return data
3. Check data structure matches expected format

**Solutions**:
```bash
# Seed T-Mart data
cd backend
node seed/seed_tmart.js

# Seed daily essentials
node seed/test_daily_essentials.js
```

### Issue 4: iOS Network Issues
**Symptoms**: Works on Android but not iOS
**Debug Steps**:
1. Check Info.plist App Transport Security
2. Verify localhost exception
3. Check iOS simulator network settings

**Solutions**:
- Ensure Info.plist has localhost exception
- Check iOS simulator network configuration

## 🧪 Testing Endpoints

### Test Individual Endpoints
```bash
# Test banners
curl http://localhost:3000/api/tmart/banners

# Test categories
curl http://localhost:3000/api/tmart/categories/featured?limit=8

# Test daily essentials
curl http://localhost:3000/api/daily-essentials?limit=6
```

### Test with Sample Data
```bash
# Check if data exists
cd backend
node -e "
const mongoose = require('mongoose');
mongoose.connect('mongodb://localhost:27017/first_db');
const Category = require('./src/models/Category');
const Product = require('./src/models/Product');
const Banner = require('./src/models/Banner');

async function checkData() {
  const categories = await Category.countDocuments();
  const products = await Product.countDocuments();
  const banners = await Banner.countDocuments({bannerType: 'tmart'});
  
  console.log('Categories:', categories);
  console.log('Products:', products);
  console.log('T-Mart Banners:', banners);
  
  mongoose.disconnect();
}

checkData();
"
```

## 📱 Flutter App Debugging

### Enable Debug Logs
The T-Mart screen now includes comprehensive logging:
- 🚀 Data loading start
- 📱 Banners loading
- 📂 Categories loading
- 🛍️ Popular products loading
- 🥬 Daily essentials loading
- 🎯 Deals loading
- 🔥 Today's deals loading
- 💡 Recommendations loading

### Check Console Output
Look for these patterns:
- ✅ Success messages with data counts
- ⚠️ Warning messages for failed endpoints
- ❌ Error messages with details

### Test API Connectivity
Use the debug button (bug icon) in the categories section to test API connectivity.

## 🔧 Backend Configuration

### Environment Variables
Create `.env` file in backend directory:
```env
MONGODB_URI=mongodb://localhost:27017/first_db
PORT=3000
NODE_ENV=development
```

### Database Models
Ensure these models exist and are properly configured:
- `Category.js` - with `getFeatured()` static method
- `Product.js` - with proper category field
- `Banner.js` - with `bannerType: 'tmart'`
- `DailyEssential.js` - for daily essentials
- `TMartDeal.js` - for deals

## 📊 Expected Data Structure

### Categories Response
```json
{
  "success": true,
  "data": [
    {
      "_id": "...",
      "name": "Grocery",
      "displayName": "Grocery",
      "isFeatured": true,
      "sortOrder": 1,
      "productCount": 25
    }
  ]
}
```

### Products Response
```json
{
  "success": true,
  "data": [
    {
      "_id": "...",
      "name": "Product Name",
      "price": 99.99,
      "imageUrl": "https://...",
      "category": "Grocery",
      "isAvailable": true
    }
  ]
}
```

## 🚨 Emergency Fixes

### If Nothing Works
1. **Restart Backend**: `Ctrl+C` then `npm run dev`
2. **Restart MongoDB**: `brew services restart mongodb-community`
3. **Clear Flutter Cache**: `flutter clean && flutter pub get`
4. **Check Port Conflicts**: `lsof -i :3000`

### Reset Database
```bash
cd backend
node seed/seed_all.js
```

## 📞 Support

If issues persist:
1. Check console logs for specific error messages
2. Verify backend server is running and accessible
3. Test endpoints with curl or Postman
4. Check database for data existence
5. Verify network configuration

## 🎯 Success Indicators

You'll know everything is working when:
- ✅ Backend server shows "🚀 Server running on port 3000"
- ✅ MongoDB shows "MongoDB connected"
- ✅ Flutter console shows successful data loading
- ✅ T-Mart screen displays categories, products, and banners
- ✅ No error messages in console
- ✅ All sections populated with data
