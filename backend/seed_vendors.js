const mongoose = require('mongoose');
require('dotenv').config();

// Import the User model
const User = require('./src/models/User');

async function seedVendors() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/tuukatuu');
    console.log('Connected to MongoDB');

    // Seed vendors
    const vendors = await User.seedVendors();
    console.log('Vendors seeded successfully:', vendors.length);
    console.log('Vendor details:', vendors.map(v => ({
      name: v.storeName,
      address: v.storeAddress,
      coordinates: v.storeCoordinates
    })));

    process.exit(0);
  } catch (error) {
    console.error('Error seeding vendors:', error);
    process.exit(1);
  }
}

seedVendors(); 