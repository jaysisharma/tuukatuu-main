const mongoose = require('mongoose');
const dotenv = require('dotenv');
const path = require('path');

// Load environment variables
dotenv.config({ path: path.resolve(__dirname, '.env') });

// Import Vendor model
const Vendor = require('./src/models/Vendor');

async function seedVendors() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGO_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log('✅ Connected to MongoDB');

    // Seed vendors
    await Vendor.seedVendors();
    console.log('✅ Vendors seeded successfully');

    // Disconnect from MongoDB
    await mongoose.disconnect();
    console.log('✅ Disconnected from MongoDB');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding vendors:', error);
    process.exit(1);
  }
}

seedVendors(); 