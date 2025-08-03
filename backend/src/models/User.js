const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  phone: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  role: {
    type: String,
    enum: ['admin', 'vendor', 'rider', 'customer'],
    default: 'customer',
    required: true,
  },
  isActive: { type: Boolean, default: true },
  // Store details for vendors
  storeName: { type: String },
  storeDescription: { type: String },
  storeImage: { type: String }, // logo
  storeBanner: { type: String },
  storeTags: [{ type: String }],
  storeCategories: [{ type: String }], // Primary categories the store belongs to
  storeRating: { type: Number, default: 0 },
  storeReviews: { type: Number, default: 0 },
  isFeatured: { type: Boolean, default: false },
  // Store location coordinates for vendors
  storeCoordinates: {
    latitude: { type: Number },
    longitude: { type: Number }
  },
  storeAddress: { type: String }, // Store address for display
}, { timestamps: true });

userSchema.statics.seedVendors = async function() {
  const vendors = [
    {
      name: 'T-Mart Express',
      email: 'tmart@vendor.com',
      phone: '9800000001',
      password: await bcrypt.hash('password123', 10),
      role: 'vendor',
      storeName: 'T-Mart Express',
      storeDescription: 'Get your essentials delivered in 15-30 minutes',
      storeImage: 'https://images.unsplash.com/photo-1604719312566-8912e9227c6a',
      storeBanner: 'https://images.unsplash.com/photo-1604719312566-8912e9227c6a',
      storeTags: ['Grocery', 'Express'],
      storeCategories: ['T-Mart', 'Grocery', 'Express'],
      storeRating: 4.8,
      storeReviews: 1200,
      isFeatured: true,
      storeCoordinates: {
        latitude: 27.7172,
        longitude: 85.3240
      },
      storeAddress: 'Thamel, Kathmandu',
    },
    {
      name: 'Wine Gallery',
      email: 'winegallery@vendor.com',
      phone: '9800000002',
      password: await bcrypt.hash('password123', 10),
      role: 'vendor',
      storeName: 'Wine Gallery',
      storeDescription: 'Premium wines and spirits delivered to your door',
      storeImage: 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3',
      storeBanner: 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3',
      storeTags: ['Wine', 'Beer', 'Spirits'],
      storeCategories: ['Wine & Beer', 'Beverages'],
      storeRating: 4.5,
      storeReviews: 800,
      isFeatured: true,
      storeCoordinates: {
        latitude: 27.7089,
        longitude: 85.3300
      },
      storeAddress: 'Durbarmarg, Kathmandu',
    },
    {
      name: 'Sweet Bakery',
      email: 'sweetbakery@vendor.com',
      phone: '9800000003',
      password: await bcrypt.hash('password123', 10),
      role: 'vendor',
      storeName: 'Sweet Bakery',
      storeDescription: 'Fresh baked goods, cakes, and pastries',
      storeImage: 'https://images.unsplash.com/photo-1517433670267-08bbd4be890f',
      storeBanner: 'https://images.unsplash.com/photo-1517433670267-08bbd4be890f',
      storeTags: ['Bakery', 'Desserts'],
      storeCategories: ['Bakery', 'Desserts'],
      storeRating: 4.7,
      storeReviews: 950,
      isFeatured: true,
      storeCoordinates: {
        latitude: 27.7250,
        longitude: 85.3400
      },
      storeAddress: 'Baneshwor, Kathmandu',
    },
    {
      name: 'City Pharmacy',
      email: 'citypharmacy@vendor.com',
      phone: '9800000004',
      password: await bcrypt.hash('password123', 10),
      role: 'vendor',
      storeName: 'City Pharmacy',
      storeDescription: 'Medicines and healthcare products',
      storeImage: 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88',
      storeBanner: 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88',
      storeTags: ['Pharmacy', 'Healthcare'],
      storeCategories: ['Pharmacy', 'Healthcare'],
      storeRating: 4.9,
      storeReviews: 1100,
      isFeatured: false,
      storeCoordinates: {
        latitude: 27.7150,
        longitude: 85.3150
      },
      storeAddress: 'New Road, Kathmandu',
    },
    {
      name: 'Fresh Mart Grocery',
      email: 'freshmart@vendor.com',
      phone: '9800000005',
      password: await bcrypt.hash('password123', 10),
      role: 'vendor',
      storeName: 'Fresh Mart Grocery',
      storeDescription: 'Groceries and fresh produce',
      storeImage: 'https://images.unsplash.com/photo-1578916171728-46686eac8d58',
      storeBanner: 'https://images.unsplash.com/photo-1578916171728-46686eac8d58',
      storeTags: ['Grocery', 'Fresh Produce'],
      storeCategories: ['Grocery', 'Fresh Fruits', 'Vegetables'],
      storeRating: 4.7,
      storeReviews: 900,
      isFeatured: false,
      storeCoordinates: {
        latitude: 27.7200,
        longitude: 85.3250
      },
      storeAddress: 'Asan, Kathmandu',
    },
    {
      name: 'Quick Bites Fast Food',
      email: 'quickbites@vendor.com',
      phone: '9800000006',
      password: await bcrypt.hash('password123', 10),
      role: 'vendor',
      storeName: 'Quick Bites Fast Food',
      storeDescription: 'Delicious fast food delivered quickly',
      storeImage: 'https://images.unsplash.com/photo-1550547660-d9450f859349',
      storeBanner: 'https://images.unsplash.com/photo-1550547660-d9450f859349',
      storeTags: ['Fast Food', 'Burgers', 'Pizza'],
      storeCategories: ['Fast Food', 'Restaurants'],
      storeRating: 4.6,
      storeReviews: 750,
      isFeatured: false,
      storeCoordinates: {
        latitude: 27.7100,
        longitude: 85.3200
      },
      storeAddress: 'Pulchowk, Lalitpur',
    },
    {
      name: 'Organic Valley',
      email: 'organicvalley@vendor.com',
      phone: '9800000007',
      password: await bcrypt.hash('password123', 10),
      role: 'vendor',
      storeName: 'Organic Valley',
      storeDescription: 'Fresh organic fruits and vegetables',
      storeImage: 'https://images.unsplash.com/photo-1542838132-92c53300491e',
      storeBanner: 'https://images.unsplash.com/photo-1542838132-92c53300491e',
      storeTags: ['Organic', 'Fresh Fruits', 'Vegetables'],
      storeCategories: ['Fresh Fruits', 'Vegetables', 'Organic'],
      storeRating: 4.8,
      storeReviews: 650,
      isFeatured: false,
      storeCoordinates: {
        latitude: 27.7300,
        longitude: 85.3350
      },
      storeAddress: 'Kirtipur, Kathmandu',
    },
    {
      name: 'Dairy Delight',
      email: 'dairydelight@vendor.com',
      phone: '9800000008',
      password: await bcrypt.hash('password123', 10),
      role: 'vendor',
      storeName: 'Dairy Delight',
      storeDescription: 'Fresh dairy products and milk',
      storeImage: 'https://images.unsplash.com/photo-1628088062854-d1870b4553da',
      storeBanner: 'https://images.unsplash.com/photo-1628088062854-d1870b4553da',
      storeTags: ['Dairy', 'Milk', 'Cheese'],
      storeCategories: ['Dairy', 'Fresh Products'],
      storeRating: 4.5,
      storeReviews: 500,
      isFeatured: false,
      storeCoordinates: {
        latitude: 27.7050,
        longitude: 85.3100
      },
      storeAddress: 'Chabahil, Kathmandu',
    },
  ];
  await this.deleteMany({ role: 'vendor' });
  return await this.insertMany(vendors);
};

module.exports = mongoose.model('User', userSchema); 