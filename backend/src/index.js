const express = require('express');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const path = require('path');
const cors = require('cors');
const Product = require('./models/Product');
const Banner = require('./models/Banner');
const Coupon = require('./models/Coupon');
const User = require('./models/User');
const Address = require('./models/Address');

// Import routes
const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/users');
const vendorRoutes = require('./routes/vendors');
const productRoutes = require('./routes/products');
const orderRoutes = require('./routes/orders');
const addressRoutes = require('./routes/addresses');
const adminRoutes = require('./routes/admin');
const adminFeaturedProductsRoutes = require('./routes/adminFeaturedProducts');
const adminBannersRoutes = require('./routes/adminBanners');
const bannersRoutes = require('./routes/banners');
const adminCategoriesRoutes = require('./routes/adminCategories');
const categoriesRoutes = require('./routes/categories');
const adminOrdersRoutes = require('./routes/adminOrders');
const adminUsersRoutes = require('./routes/adminUsers');
const adminVendorsRoutes = require('./routes/adminVendors');
const adminProductsRoutes = require('./routes/adminProducts');
const adminAddressesRoutes = require('./routes/adminAddresses');
const favoritesRoutes = require('./routes/favorites');
const tmartRoutes = require('./routes/tmart');
const todayDealsRoutes = require('./routes/todayDeals');

// Load environment variables from .env
dotenv.config({ path: path.resolve(__dirname, '../.env') });

const app = express();

// Middleware to parse JSON requests
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cors());
// Log all incoming requests
app.use((req, res, next) => {
  console.log(`📥 ${req.method} ${req.url}`);
  console.log('🧾 Headers:', req.headers);
  console.log('📦 Body:', req.body);
  next();
});


// MongoDB connection
mongoose.connect(process.env.MONGO_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
  .then(() => console.log('✅ MongoDB connected'))
  .catch((err) => console.error('❌ MongoDB connection error:', err));

// Health check route
app.get('/', (req, res) => {
  res.send('Tuukatuu Backend API is running');
});

// Use routes
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/vendors', vendorRoutes);
app.use('/api/products', productRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/addresses', addressRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/admin/featured-products', adminFeaturedProductsRoutes);
app.use('/api/admin/banners', adminBannersRoutes);
app.use('/api/banners', bannersRoutes);
app.use('/api/admin/categories', adminCategoriesRoutes);
app.use('/api/categories', categoriesRoutes);
app.use('/api/admin/orders', adminOrdersRoutes);
app.use('/api/admin/users', adminUsersRoutes);
app.use('/api/admin/vendors', adminVendorsRoutes);
app.use('/api/admin/products', adminProductsRoutes);
app.use('/api/admin/addresses', adminAddressesRoutes);
app.use('/api/favorites', favoritesRoutes);
app.use('/api/tmart', tmartRoutes);
app.use('/api', todayDealsRoutes);

// Seed products if --seed-products flag is present
if (process.argv.includes('--seed-products')) {
  Product.seedProducts().then(() => {
    console.log('Products seeded successfully.');
    process.exit(0);
  }).catch((err) => {
    console.error('Error seeding products:', err);
    process.exit(1);
  });
}

// Seed banners if --seed-banners flag is present
if (process.argv.includes('--seed-banners')) {
  const adminId = process.env.ADMIN_ID || 'PASTE_ADMIN_USER_ID_HERE';
  Banner.seedBanners(adminId).then(() => {
    console.log('Banners seeded successfully.');
    process.exit(0);
  }).catch((err) => {
    console.error('Error seeding banners:', err);
    process.exit(1);
  });
}
// Seed coupons if --seed-coupons flag is present
if (process.argv.includes('--seed-coupons')) {
  const adminId = process.env.ADMIN_ID || 'PASTE_ADMIN_USER_ID_HERE';
  Coupon.seedCoupons(adminId).then(() => {
    console.log('Coupons seeded successfully.');
    process.exit(0);
  }).catch((err) => {
    console.error('Error seeding coupons:', err);
    process.exit(1);
  });
}

// Seed vendors if --seed-vendors flag is present
if (process.argv.includes('--seed-vendors')) {
  const Vendor = require('./models/Vendor');
  Vendor.seedVendors().then(() => {
    console.log('Vendors seeded successfully.');
    process.exit(0);
  }).catch((err) => {
    console.error('Error seeding vendors:', err);
    process.exit(1);
  });
}

// Seed vendor stores (vendors, addresses, products) if --seed-vendor-stores flag is present
if (process.argv.includes('--seed-vendor-stores')) {
  (async () => {
    try {
      const vendors = await User.seedVendors();
      const addresses = await Address.seedVendorAddresses(vendors);
      const products = await Product.seedVendorProducts(vendors);
      console.log('Vendors, addresses, and products seeded successfully.');
      console.log({ vendors, addresses, products });
      process.exit(0);
    } catch (err) {
      console.error('Error seeding vendor stores:', err);
      process.exit(1);
    }
  })();
}

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('🔥 Error:', err.stack);
  res.status(500).json({ message: 'Internal Server Error' });
});

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
});
 