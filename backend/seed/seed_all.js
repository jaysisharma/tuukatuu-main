const mongoose = require('mongoose');
require('dotenv').config();

// Import models
const User = require('../src/models/User');
const Address = require('../src/models/Address');
const Product = require('../src/models/Product');

async function seedAll() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/tuukatuu');
    console.log('Connected to MongoDB');

    console.log('Starting comprehensive seeding...');

    // 1. Seed vendors
    console.log('1. Seeding vendors...');
    const vendors = await User.seedVendors();
    console.log(`✅ Vendors seeded: ${vendors.length}`);

    // 2. Seed vendor addresses
    console.log('2. Seeding vendor addresses...');
    try {
      const addresses = await Address.seedVendorAddresses(vendors);
      console.log(`✅ Vendor addresses seeded: ${addresses.length}`);
    } catch (error) {
      console.log(`⚠️  Warning: Could not seed vendor addresses: ${error.message}`);
      console.log('Continuing with product seeding...');
    }

    // 3. Seed products
    console.log('3. Seeding products...');
    try {
      const products = await Product.seedVendorProducts(vendors);
      console.log(`✅ Products seeded: ${products.length}`);
    } catch (error) {
      console.log(`⚠️  Warning: Could not seed products: ${error.message}`);
    }

    console.log('\n🎉 Seeding completed!');
    console.log('\nSummary:');
    console.log(`- Vendors: ${vendors.length}`);
    
    // Try to get addresses count
    try {
      const addressCount = await Address.countDocuments();
      console.log(`- Addresses: ${addressCount}`);
    } catch (error) {
      console.log('- Addresses: Error counting');
    }
    
    // Try to get products count
    try {
      const productCount = await Product.countDocuments();
      console.log(`- Products: ${productCount}`);
    } catch (error) {
      console.log('- Products: Error counting');
    }

    console.log('\nVendor details:');
    vendors.forEach((vendor, index) => {
      console.log(`${index + 1}. ${vendor.storeName} - ${vendor.storeAddress}`);
      if (vendor.storeCategories && vendor.storeCategories.length > 0) {
        console.log(`   Categories: ${vendor.storeCategories.join(', ')}`);
      }
    });

    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding data:', error);
    console.error('Stack trace:', error.stack);
    process.exit(1);
  }
}

seedAll(); 