# Admin Deals Management System

This document describes the fully functional admin deals management system for the Tuukatuu application.

## 🎯 Overview

The admin deals system allows administrators to:
- Create, read, update, and delete daily deals
- Manage deal features (featured status, expiration dates, quantities)
- Upload and manage deal images
- View deal statistics and analytics
- Display deals in the T-Mart customer interface

## 🏗️ Architecture

### Frontend (React Admin Panel)
- **Location**: `client/src/pages/admin/TodayDeals.jsx`
- **Features**: Full CRUD operations, image upload, search, filtering, statistics
- **UI Components**: Modal forms, deal cards, statistics dashboard

### Backend (Node.js/Express)
- **Routes**: `backend/src/routes/todayDeals.js`
- **Controller**: `backend/src/controllers/todayDealsController.js`
- **Service**: `backend/src/services/todayDealsService.js`
- **Model**: `backend/src/models/TodayDeal.js`

### Flutter App (T-Mart Interface)
- **Screen**: `lib/presentation/screens/mart/mart.dart`
- **Widgets**: `lib/presentation/widgets/tmart_today_deal_card.dart`

## 🚀 Getting Started

### 1. Start the Backend Server
```bash
cd backend
npm install
npm start
```

### 2. Start the React Admin Panel
```bash
cd client
npm install
npm run dev
```

### 3. Start the Flutter App
```bash
flutter run
```

## 📱 Admin Panel Features

### Dashboard
- **Statistics Cards**: Total deals, active deals, featured deals, expired deals
- **Quick Actions**: Create new deal button
- **Search & Filter**: Search deals by name, filter by status

### Deal Management
- **Create Deal**: Modal form with all required fields
- **Edit Deal**: Update existing deal information
- **Delete Deal**: Remove deals with confirmation
- **Toggle Featured**: Mark/unmark deals as featured

### Deal Fields
- **Basic Info**: Name, description, category
- **Pricing**: Original price, deal price, discount percentage
- **Inventory**: Maximum quantity, sold quantity
- **Timing**: Start date, end date
- **Media**: Product image (upload or URL)
- **Settings**: Featured status, deal type

## 🔌 API Endpoints

### Public Endpoints
```
GET /api/today-deals - Get all active deals
GET /api/today-deals/stats - Get deal statistics
GET /api/featured-deals - Get featured deals
GET /api/deals/category/:category - Get deals by category
GET /api/deals/:dealId - Get specific deal
```

### Admin Endpoints (Protected)
```
POST /api/today-deals/deals - Create new deal
PUT /api/today-deals/deals/:dealId - Update deal
PATCH /api/today-deals/deals/:dealId - Partial update (e.g., featured status)
DELETE /api/today-deals/deals/:dealId - Delete deal
POST /api/today-deals/upload-image - Upload deal image
```

### T-Mart Endpoints
```
GET /api/tmart/deals - Get T-Mart deals
GET /api/tmart/categories - Get T-Mart categories
GET /api/tmart/daily-essentials - Get daily essentials
GET /api/tmart/popular-products - Get popular products
GET /api/tmart/banners - Get T-Mart banners
```

## 🧪 Testing

Run the test script to verify all endpoints work:
```bash
node test_admin_deals.js
```

This will test:
- Public deal endpoints
- T-Mart integration endpoints
- Response formats and data structures

## 🎨 T-Mart Customer Interface

### Features
- **Banner Carousel**: Special offers and promotions
- **Today's Deals**: Horizontal scrolling deal cards
- **Categories**: Grid layout of product categories
- **Daily Essentials**: Horizontal product list
- **Popular Products**: Grid layout of trending items

### Deal Display
- **Deal Cards**: Show discount, countdown timer, stock status
- **Real-time Updates**: Countdown timers, stock progress bars
- **Responsive Design**: Works on all screen sizes
- **Pull-to-Refresh**: Update content manually

## 🔐 Authentication & Security

### Admin Access
- JWT token required for admin operations
- Role-based authorization (admin role required)
- Secure image upload with file validation

### Data Validation
- Required field validation
- Date range validation
- Price and quantity validation
- Image format validation

## 📊 Data Models

### TodayDeal Schema
```javascript
{
  name: String (required),
  description: String (required),
  imageUrl: String (required),
  originalPrice: Number (required),
  price: Number (required),
  discount: Number (required),
  dealType: String (enum: percentage, fixed, buy_one_get_one),
  category: String (required),
  featured: Boolean (default: false),
  maxQuantity: Number (default: 10),
  soldQuantity: Number (default: 0),
  startDate: Date (default: now),
  endDate: Date (required),
  tags: [String],
  isActive: Boolean (default: true)
}
```

### Virtual Fields
- `remainingQuantity`: Calculated from maxQuantity - soldQuantity
- `isExpired`: Check if current date > endDate
- `isValid`: Check if deal is active, not expired, and has stock

## 🚀 Deployment

### Environment Variables
```bash
# Backend
PORT=3000
MONGODB_URI=mongodb://localhost:27017/tuukatuu
JWT_SECRET=your_jwt_secret
NODE_ENV=development

# Frontend
VITE_API_BASE_URL=http://localhost:3000/api
```

### Production Considerations
- Enable HTTPS
- Set up proper CORS policies
- Configure image CDN
- Set up monitoring and logging
- Enable rate limiting

## 🔧 Troubleshooting

### Common Issues

1. **Deals not loading**
   - Check MongoDB connection
   - Verify API endpoints are accessible
   - Check browser console for errors

2. **Image upload fails**
   - Verify upload directory permissions
   - Check file size limits
   - Validate image formats

3. **Admin operations fail**
   - Verify JWT token is valid
   - Check user has admin role
   - Verify authentication middleware

### Debug Mode
Enable debug logging in the backend:
```javascript
// In backend/src/index.js
if (process.env.NODE_ENV !== 'production') {
  app.use(morgan('dev'));
}
```

## 📈 Future Enhancements

- **Bulk Operations**: Import/export deals via CSV
- **Advanced Analytics**: Deal performance metrics
- **A/B Testing**: Test different deal configurations
- **Automated Scheduling**: Auto-activate/deactivate deals
- **Multi-language Support**: Internationalization
- **Mobile Admin App**: Native mobile admin interface

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

---

For support or questions, please contact the development team.
