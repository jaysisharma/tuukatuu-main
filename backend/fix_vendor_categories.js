const mongoose = require('mongoose');
require('dotenv').config();

// Import the User model
const User = require('./src/models/User');

async function fixVendorCategories() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/tuukatuu');
    console.log('Connected to MongoDB');

    console.log('Fixing vendor categories...');

    // First, let's see all vendors
    const allVendors = await User.find({ role: 'vendor' });
    console.log(`Found ${allVendors.length} vendors in database:`);
    
    allVendors.forEach(vendor => {
      console.log(`- ${vendor.storeName} (${vendor.email}): categories=${JSON.stringify(vendor.storeCategories)}, tags=${JSON.stringify(vendor.storeTags)}`);
    });

    // Update categories based on store names and tags
    const categoryMappings = {
      'Wine Gallery': ['Wine & Beer', 'Beverages'],
      'T-Mart Express': ['T-Mart', 'Grocery', 'Express'],
      'Sweet Bakery': ['Bakery', 'Desserts'],
      'City Pharmacy': ['Pharmacy', 'Healthcare'],
      'Fresh Mart Grocery': ['Grocery', 'Fresh Fruits', 'Vegetables'],
      'Quick Bites Fast Food': ['Fast Food', 'Restaurants'],
      'Organic Valley': ['Fresh Fruits', 'Vegetables', 'Organic'],
      'Dairy Delight': ['Dairy', 'Fresh Products']
    };

    let updatedCount = 0;
    for (const vendor of allVendors) {
      const categories = categoryMappings[vendor.storeName];
      if (categories) {
        const result = await User.updateOne(
          { _id: vendor._id },
          { 
            $set: { 
              storeCategories: categories,
              storeCoordinates: {
                latitude: 27.7172,
                longitude: 85.324
              },
              storeAddress: 'Kathmandu, Nepal'
            }
          }
        );
        
        if (result.modifiedCount > 0) {
          console.log(`✅ Updated ${vendor.storeName} with categories: ${categories.join(', ')}`);
          updatedCount++;
        } else {
          console.log(`⚠️  No changes for ${vendor.storeName}`);
        }
      } else {
        console.log(`❓ No category mapping found for ${vendor.storeName}`);
      }
    }

    console.log(`\n🎉 Updated ${updatedCount} vendors with categories`);

    // Test the Wine & Beer category
    console.log('\nTesting Wine & Beer category...');
    const wineVendors = await User.find({
      role: 'vendor',
      storeCategories: { $regex: 'Wine & Beer', $options: 'i' }
    });
    
    console.log(`Found ${wineVendors.length} vendors in Wine & Beer category:`);
    wineVendors.forEach(vendor => {
      console.log(`- ${vendor.storeName}: ${vendor.storeCategories.join(', ')}`);
    });

    // Test the API endpoint
    console.log('\nTesting API endpoint...');
    const testVendors = await User.find({
      role: 'vendor',
      storeCategories: { $regex: 'Wine & Beer', $options: 'i' }
    }).select('-password');
    
    console.log(`API would return ${testVendors.length} vendors for Wine & Beer category`);

    process.exit(0);
  } catch (error) {
    console.error('❌ Error fixing vendor categories:', error);
    console.error('Stack trace:', error.stack);
    process.exit(1);
  }
}

fixVendorCategories(); 