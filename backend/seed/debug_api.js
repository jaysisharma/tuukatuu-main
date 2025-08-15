const mongoose = require('mongoose');
require('dotenv').config();

// Import the User model
const User = require('../src/models/User');

async function debugAPI() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/tuukatuu');
    console.log('Connected to MongoDB');

    console.log('🔍 Debugging API logic...\n');

    // Test 1: Check if vendors exist
    console.log('1. Checking all vendors:');
    const allVendors = await User.find({ role: 'vendor', isActive: true }).select('-password');
    console.log(`   Found ${allVendors.length} vendors`);
    
    allVendors.forEach(vendor => {
      console.log(`   - ${vendor.storeName}: tags=${JSON.stringify(vendor.storeTags)}`);
    });

    // Test 2: Test the exact query from the API
    console.log('\n2. Testing API query for "Wine":');
    const category = 'Wine';
    const query = { 
      role: 'vendor', 
      isActive: true,
      storeTags: { $regex: category, $options: 'i' }
    };
    
    console.log('   Query:', JSON.stringify(query));
    
    const wineVendors = await User.find(query).select('-password');
    console.log(`   Found ${wineVendors.length} vendors`);
    
    wineVendors.forEach(vendor => {
      console.log(`   - ${vendor.storeName}: ${vendor.storeTags.join(', ')}`);
    });

    // Test 3: Test with different category
    console.log('\n3. Testing API query for "Grocery":');
    const groceryQuery = { 
      role: 'vendor', 
      isActive: true,
      storeTags: { $regex: 'Grocery', $options: 'i' }
    };
    
    const groceryVendors = await User.find(groceryQuery).select('-password');
    console.log(`   Found ${groceryVendors.length} vendors`);
    
    groceryVendors.forEach(vendor => {
      console.log(`   - ${vendor.storeName}: ${vendor.storeTags.join(', ')}`);
    });

    // Test 4: Check if there are any vendors with empty storeTags
    console.log('\n4. Checking vendors with empty storeTags:');
    const emptyTagsVendors = await User.find({ 
      role: 'vendor', 
      isActive: true,
      $or: [
        { storeTags: { $exists: false } },
        { storeTags: { $size: 0 } },
        { storeTags: null }
      ]
    }).select('-password');
    
    console.log(`   Found ${emptyTagsVendors.length} vendors with empty tags`);
    emptyTagsVendors.forEach(vendor => {
      console.log(`   - ${vendor.storeName}: tags=${JSON.stringify(vendor.storeTags)}`);
    });

    console.log('\n✅ Debug completed!');

    process.exit(0);
  } catch (error) {
    console.error('❌ Error debugging API:', error);
    process.exit(1);
  }
}

debugAPI(); 