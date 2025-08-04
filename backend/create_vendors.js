const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
require('dotenv').config();

// Import User model
const User = require('./src/models/User');

mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/first_db2', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

const createVendors = async () => {
  try {
    console.log('🏪 Creating vendors with different types...');

    // Check if vendors already exist
    const existingVendors = await User.find({ role: 'vendor' });
    if (existingVendors.length > 0) {
      console.log(`Found ${existingVendors.length} existing vendors. Updating them with new types...`);
    }

    const vendors = [
      // Restaurant Vendor - Chinese Restaurant
      {
        name: 'Golden Dragon Restaurant',
        email: 'goldendragon@restaurant.com',
        phone: '9800000001',
        password: await bcrypt.hash('password123', 10),
        role: 'vendor',
        vendorType: 'restaurant',
        vendorSubType: 'chinese',
        storeName: 'Golden Dragon Restaurant',
        storeDescription: 'Authentic Chinese cuisine with a modern twist. Fresh ingredients and traditional recipes.',
        storeImage: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400&h=400&fit=crop',
        storeBanner: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&h=400&fit=crop',
        storeTags: ['Chinese', 'Restaurant', 'Fine Dining', 'Authentic'],
        storeCategories: ['Chinese', 'Asian', 'Restaurant'],
        storeRating: 4.6,
        storeReviews: 850,
        isFeatured: true,
        storeCoordinates: {
          latitude: 27.7172,
          longitude: 85.3240
        },
        storeAddress: 'Thamel, Kathmandu',
      },
      
      // Store Vendor - Grocery Store
      {
        name: 'Fresh Mart Grocery',
        email: 'freshmart@grocery.com',
        phone: '9800000002',
        password: await bcrypt.hash('password123', 10),
        role: 'vendor',
        vendorType: 'store',
        vendorSubType: 'grocery',
        storeName: 'Fresh Mart Grocery',
        storeDescription: 'Your one-stop shop for fresh groceries, household essentials, and daily necessities.',
        storeImage: 'https://images.unsplash.com/photo-1604719312566-8912e9227c6a?w=400&h=400&fit=crop',
        storeBanner: 'https://images.unsplash.com/photo-1604719312566-8912e9227c6a?w=800&h=400&fit=crop',
        storeTags: ['Grocery', 'Fresh', 'Convenience', 'Essentials'],
        storeCategories: ['Grocery', 'Fresh Produce', 'Household'],
        storeRating: 4.8,
        storeReviews: 1200,
        isFeatured: true,
        storeCoordinates: {
          latitude: 27.7089,
          longitude: 85.3300
        },
        storeAddress: 'Durbarmarg, Kathmandu',
      },
      
      // Restaurant Vendor - Italian Restaurant
      {
        name: 'Bella Italia',
        email: 'bellaitalia@restaurant.com',
        phone: '9800000003',
        password: await bcrypt.hash('password123', 10),
        role: 'vendor',
        vendorType: 'restaurant',
        vendorSubType: 'italian',
        storeName: 'Bella Italia',
        storeDescription: 'Authentic Italian cuisine with fresh pasta, wood-fired pizzas, and fine wines.',
        storeImage: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=400&h=400&fit=crop',
        storeBanner: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=800&h=400&fit=crop',
        storeTags: ['Italian', 'Pizza', 'Pasta', 'Fine Dining'],
        storeCategories: ['Italian', 'European', 'Restaurant'],
        storeRating: 4.7,
        storeReviews: 650,
        isFeatured: true,
        storeCoordinates: {
          latitude: 27.7250,
          longitude: 85.3400
        },
        storeAddress: 'Baneshwor, Kathmandu',
      },
      
      // Store Vendor - Pharmacy
      {
        name: 'Health First Pharmacy',
        email: 'healthfirst@pharmacy.com',
        phone: '9800000004',
        password: await bcrypt.hash('password123', 10),
        role: 'vendor',
        vendorType: 'store',
        vendorSubType: 'pharmacy',
        storeName: 'Health First Pharmacy',
        storeDescription: 'Your trusted pharmacy for medicines, health supplements, and personal care products.',
        storeImage: 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=400&h=400&fit=crop',
        storeBanner: 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=800&h=400&fit=crop',
        storeTags: ['Pharmacy', 'Medicine', 'Health', 'Personal Care'],
        storeCategories: ['Pharmacy', 'Health', 'Medicine'],
        storeRating: 4.5,
        storeReviews: 420,
        isFeatured: true,
        storeCoordinates: {
          latitude: 27.7300,
          longitude: 85.3500
        },
        storeAddress: 'Patan, Lalitpur',
      },
      
      // Restaurant Vendor - Fast Food
      {
        name: 'Quick Bites',
        email: 'quickbites@restaurant.com',
        phone: '9800000005',
        password: await bcrypt.hash('password123', 10),
        role: 'vendor',
        vendorType: 'restaurant',
        vendorSubType: 'fast_food',
        storeName: 'Quick Bites',
        storeDescription: 'Fast, delicious food for when you\'re on the go. Burgers, fries, and more!',
        storeImage: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=400&h=400&fit=crop',
        storeBanner: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=800&h=400&fit=crop',
        storeTags: ['Fast Food', 'Burgers', 'Quick', 'Casual'],
        storeCategories: ['Fast Food', 'Burgers', 'Casual Dining'],
        storeRating: 4.3,
        storeReviews: 780,
        isFeatured: false,
        storeCoordinates: {
          latitude: 27.7200,
          longitude: 85.3250
        },
        storeAddress: 'Kupondole, Lalitpur',
      },
      
      // Store Vendor - Electronics Store
      {
        name: 'Tech Hub Electronics',
        email: 'techhub@electronics.com',
        phone: '9800000006',
        password: await bcrypt.hash('password123', 10),
        role: 'vendor',
        vendorType: 'store',
        vendorSubType: 'electronics',
        storeName: 'Tech Hub Electronics',
        storeDescription: 'Latest electronics, gadgets, and tech accessories. Quality products at competitive prices.',
        storeImage: 'https://images.unsplash.com/photo-1468495244123-6c6c332eeece?w=400&h=400&fit=crop',
        storeBanner: 'https://images.unsplash.com/photo-1468495244123-6c6c332eeece?w=800&h=400&fit=crop',
        storeTags: ['Electronics', 'Gadgets', 'Tech', 'Accessories'],
        storeCategories: ['Electronics', 'Gadgets', 'Technology'],
        storeRating: 4.4,
        storeReviews: 320,
        isFeatured: false,
        storeCoordinates: {
          latitude: 27.7150,
          longitude: 85.3350
        },
        storeAddress: 'New Road, Kathmandu',
      }
    ];

    // Create or update vendors
    for (const vendorData of vendors) {
      const existingVendor = await User.findOne({ 
        $or: [
          { email: vendorData.email },
          { phone: vendorData.phone }
        ]
      });
      
      if (existingVendor) {
        // Update existing vendor with new type information
        await User.findByIdAndUpdate(existingVendor._id, {
          vendorType: vendorData.vendorType,
          vendorSubType: vendorData.vendorSubType,
          storeName: vendorData.storeName,
          storeDescription: vendorData.storeDescription,
          storeTags: vendorData.storeTags,
          storeCategories: vendorData.storeCategories,
          isFeatured: vendorData.isFeatured
        });
        console.log(`✅ Updated vendor: ${vendorData.storeName}`);
      } else {
        // Create new vendor
        const vendor = new User(vendorData);
        await vendor.save();
        console.log(`✅ Created vendor: ${vendorData.storeName}`);
      }
    }

    // Display summary
    const allVendors = await User.find({ role: 'vendor' });
    const restaurants = allVendors.filter(v => v.vendorType === 'restaurant');
    const stores = allVendors.filter(v => v.vendorType === 'store');

    console.log('\n🎉 Vendors created/updated successfully!');
    console.log('\nSummary:');
    console.log(`- Total vendors: ${allVendors.length}`);
    console.log(`- Restaurants: ${restaurants.length}`);
    console.log(`- Stores: ${stores.length}`);

    console.log('\n🏪 Restaurants:');
    restaurants.forEach((vendor, index) => {
      console.log(`${index + 1}. ${vendor.storeName} (${vendor.vendorSubType})`);
    });

    console.log('\n🛒 Stores:');
    stores.forEach((vendor, index) => {
      console.log(`${index + 1}. ${vendor.storeName} (${vendor.vendorSubType})`);
    });

    console.log('\n📧 Vendor login credentials:');
    vendors.forEach((vendor, index) => {
      console.log(`${index + 1}. ${vendor.storeName}: ${vendor.email} / password123`);
    });

    process.exit(0);
  } catch (error) {
    console.error('❌ Error creating vendors:', error);
    process.exit(1);
  }
};

createVendors(); 