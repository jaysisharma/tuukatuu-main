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

// Routes (Assuming you have an `index.js` inside /routes folder)
const apiRouter = require('./routes');
app.use('/api', apiRouter);

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
  User.seedVendors().then((vendors) => {
    console.log('Vendors seeded successfully.');
    console.log(vendors);
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
 