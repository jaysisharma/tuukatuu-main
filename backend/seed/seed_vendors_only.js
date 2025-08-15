const mongoose = require('mongoose');
require('dotenv').config();

// Import the User model
const User = require('../src/models/User');

async function seedVendorsOnly() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/tuukatuu');
    console.log('Connected to MongoDB');

    console.log('Seeding vendors only...');

    // Seed vendors
    const vendors = await User.seedVendors();
    console.log(`✅ Vendors seeded successfully: ${vendors.length}`);
    
    console.log('\nVendor details:');
    vendors.forEach((vendor, index) => {
      console.log(`${index + 1}. ${vendor.storeName}`);
      console.log(`   Email: ${vendor.email}`);
      console.log(`   Address: ${vendor.storeAddress}`);
      console.log(`   Categories: ${vendor.storeCategories?.join(', ') || 'None'}`);
      console.log(`   Coordinates: ${vendor.storeCoordinates?.latitude}, ${vendor.storeCoordinates?.longitude}`);
      console.log('');
    });

    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding vendors:', error);
    console.error('Stack trace:', error.stack);
    process.exit(1);
  }
}

seedVendorsOnly(); 