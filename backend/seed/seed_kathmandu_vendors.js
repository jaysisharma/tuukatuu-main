const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

// Import models
const User = require('../src/models/User');

// Kathmandu area coordinates and addresses
const KATHMANDU_LOCATIONS = [
  {
    name: 'Thamel',
    coordinates: [85.3148, 27.7172], // [longitude, latitude]
    address: 'Thamel, Kathmandu, Nepal',
    description: 'Tourist hub with international restaurants and shops'
  },
  {
    name: 'Durbar Marg',
    coordinates: [85.3180, 27.7172],
    address: 'Durbar Marg, Kathmandu, Nepal',
    description: 'Upscale area with fine dining and luxury shops'
  },
  {
    name: 'New Road',
    coordinates: [85.3160, 27.7160],
    address: 'New Road, Kathmandu, Nepal',
    description: 'Historic shopping district with traditional markets'
  },
  {
    name: 'Asan',
    coordinates: [85.3150, 27.7180],
    address: 'Asan, Kathmandu, Nepal',
    description: 'Traditional market area with authentic Nepali food'
  },
  {
    name: 'Indra Chowk',
    coordinates: [85.3140, 27.7190],
    address: 'Indra Chowk, Kathmandu, Nepal',
    description: 'Historic square with traditional shops and eateries'
  },
  {
    name: 'Basantapur',
    coordinates: [85.3170, 27.7165],
    address: 'Basantapur, Kathmandu, Nepal',
    description: 'UNESCO World Heritage site with cultural significance'
  },
  {
    name: 'Jhochhen',
    coordinates: [85.3155, 27.7175],
    address: 'Jhochhen, Kathmandu, Nepal',
    description: 'Traditional Newari neighborhood with authentic cuisine'
  },
  {
    name: 'Boudha',
    coordinates: [85.3620, 27.7210],
    address: 'Boudha, Kathmandu, Nepal',
    description: 'Spiritual area with Tibetan restaurants and cafes'
  },
  {
    name: 'Patan',
    coordinates: [85.3250, 27.6770],
    address: 'Patan, Lalitpur, Nepal',
    description: 'Ancient city with traditional Newari architecture'
  },
  {
    name: 'Bhaktapur',
    coordinates: [85.4270, 27.6710],
    address: 'Bhaktapur, Nepal',
    description: 'Medieval city known for traditional pottery and food'
  },
  {
    name: 'Lazimpat',
    coordinates: [85.3200, 27.7200],
    address: 'Lazimpat, Kathmandu, Nepal',
    description: 'Diplomatic area with international restaurants'
  },
  {
    name: 'Jhamsikhel',
    coordinates: [85.3250, 27.6800],
    address: 'Jhamsikhel, Lalitpur, Nepal',
    description: 'Trendy area with modern cafes and restaurants'
  }
];

// Enhanced restaurant data
const RESTAURANTS = [
  {
    storeName: 'Himalayan Kitchen',
    storeDescription: 'Authentic Nepali cuisine with traditional flavors. Specializing in dal bhat, momos, and traditional Nepali dishes. Family-owned restaurant serving the best of Nepali hospitality.',
    vendorType: 'restaurant',
    vendorSubType: 'nepali',
    isFeatured: true,
    storeRating: 4.5,
    storeReviews: 128,
    storeTags: ['Nepali', 'Traditional', 'Authentic', 'Family-Owned', 'Dal Bhat', 'Momos'],
    storeCategories: ['Nepali', 'Traditional', 'Local Cuisine']
  },
  {
    storeName: 'Thamel House Restaurant',
    storeDescription: 'International cuisine in the heart of Thamel. Serving continental, Chinese, Indian, and Nepali dishes. Perfect for tourists and locals alike with a cozy atmosphere.',
    vendorType: 'restaurant',
    vendorSubType: 'international',
    isFeatured: true,
    storeRating: 4.3,
    storeReviews: 95,
    storeTags: ['International', 'Thamel', 'Fine Dining', 'Tourist-Friendly', 'Multi-Cuisine'],
    storeCategories: ['International', 'Chinese', 'Indian', 'Nepali']
  },
  {
    storeName: 'Newa Restaurant',
    storeDescription: 'Traditional Newari cuisine and culture. Experience authentic Newari flavors with dishes like choila, bara, and traditional Newari thali. Cultural dining experience.',
    vendorType: 'restaurant',
    vendorSubType: 'newari',
    isFeatured: true,
    storeRating: 4.7,
    storeReviews: 156,
    storeTags: ['Newari', 'Traditional', 'Cultural', 'Authentic', 'Choila', 'Bara'],
    storeCategories: ['Newari', 'Traditional', 'Cultural Cuisine']
  },
  {
    storeName: 'Boudha Stupa Cafe',
    storeDescription: 'Peaceful cafe near the famous Boudha Stupa. Serving Tibetan, Nepali, and international dishes. Perfect spot for meditation and healthy eating.',
    vendorType: 'restaurant',
    vendorSubType: 'tibetan',
    isFeatured: false,
    storeRating: 4.2,
    storeReviews: 78,
    storeTags: ['Cafe', 'Boudha', 'Peaceful', 'Tibetan', 'Healthy', 'Meditation'],
    storeCategories: ['Tibetan', 'Cafe', 'Healthy Food']
  },
  {
    storeName: 'Patan Durbar Restaurant',
    storeDescription: 'Fine dining in historic Patan. Newari and international cuisine with traditional architecture. Perfect for special occasions and cultural experiences.',
    vendorType: 'restaurant',
    vendorSubType: 'newari',
    isFeatured: true,
    storeRating: 4.6,
    storeReviews: 112,
    storeTags: ['Newari', 'Fine Dining', 'Patan', 'Cultural', 'Special Occasions'],
    storeCategories: ['Newari', 'Fine Dining', 'Cultural Cuisine']
  },
  {
    storeName: 'Bhaktapur Traditional Kitchen',
    storeDescription: 'Traditional Newari and Nepali cuisine in historic Bhaktapur. Famous for traditional thali and local specialties. Authentic taste of ancient Nepal.',
    vendorType: 'restaurant',
    vendorSubType: 'newari',
    isFeatured: false,
    storeRating: 4.4,
    storeReviews: 89,
    storeTags: ['Newari', 'Bhaktapur', 'Traditional', 'Thali', 'Local Specialties'],
    storeCategories: ['Newari', 'Traditional', 'Local Cuisine']
  },
  {
    storeName: 'Lazimpat International',
    storeDescription: 'Upscale international dining in diplomatic area. Continental, Mediterranean, and fusion cuisine. Perfect for business meetings and special occasions.',
    vendorType: 'restaurant',
    vendorSubType: 'international',
    isFeatured: true,
    storeRating: 4.5,
    storeReviews: 134,
    storeTags: ['International', 'Upscale', 'Diplomatic Area', 'Business', 'Fine Dining'],
    storeCategories: ['International', 'Continental', 'Mediterranean']
  },
  {
    storeName: 'Jhamsikhel Modern Cafe',
    storeDescription: 'Trendy modern cafe with fusion cuisine. International dishes with Nepali twist. Popular among young professionals and expats.',
    vendorType: 'restaurant',
    vendorSubType: 'fusion',
    isFeatured: false,
    storeRating: 4.1,
    storeReviews: 67,
    storeTags: ['Modern', 'Fusion', 'Trendy', 'Young Crowd', 'International'],
    storeCategories: ['Fusion', 'Modern', 'International']
  }
];

// Enhanced store data
const STORES = [
  {
    storeName: 'Kathmandu Grocery Hub',
    storeDescription: 'Comprehensive grocery store with fresh vegetables, fruits, and household items. Best prices in town with quality guarantee.',
    vendorType: 'store',
    vendorSubType: 'grocery',
    isFeatured: true,
    storeRating: 4.3,
    storeReviews: 89,
    storeTags: ['Grocery', 'Fresh', 'Vegetables', 'Fruits', 'Household', 'Best Prices'],
    storeCategories: ['Grocery', 'Fresh Produce', 'Household']
  },
  {
    storeName: 'Thamel Electronics',
    storeDescription: 'Electronics store with latest gadgets and accessories. Mobile phones, laptops, and electronic components. Competitive prices and warranty.',
    vendorType: 'store',
    vendorSubType: 'electronics',
    isFeatured: false,
    storeRating: 4.0,
    storeReviews: 56,
    storeTags: ['Electronics', 'Mobile', 'Laptop', 'Gadgets', 'Warranty'],
    storeCategories: ['Electronics', 'Mobile Phones', 'Computers']
  },
  {
    storeName: 'Boudha Pharmacy',
    storeDescription: 'Full-service pharmacy with prescription and over-the-counter medicines. Health supplements and personal care products. Professional service.',
    vendorType: 'store',
    vendorSubType: 'pharmacy',
    isFeatured: false,
    storeRating: 4.4,
    storeReviews: 78,
    storeTags: ['Pharmacy', 'Medicine', 'Health', 'Supplements', 'Professional'],
    storeCategories: ['Pharmacy', 'Health', 'Personal Care']
  },
  {
    storeName: 'Asan Traditional Market',
    storeDescription: 'Traditional market with authentic Nepali products. Spices, traditional clothes, and handicrafts. Cultural shopping experience.',
    vendorType: 'store',
    vendorSubType: 'traditional',
    isFeatured: true,
    storeRating: 4.2,
    storeReviews: 92,
    storeTags: ['Traditional', 'Market', 'Spices', 'Handicrafts', 'Cultural'],
    storeCategories: ['Traditional', 'Handicrafts', 'Spices']
  },
  {
    storeName: 'Patan Handicraft Center',
    storeDescription: 'Handicraft store with traditional Nepali and Newari items. Wooden crafts, metalwork, and traditional jewelry. Authentic souvenirs.',
    vendorType: 'store',
    vendorSubType: 'handicrafts',
    isFeatured: true,
    storeRating: 4.6,
    storeReviews: 145,
    storeTags: ['Handicrafts', 'Traditional', 'Newari', 'Wooden Crafts', 'Jewelry'],
    storeCategories: ['Handicrafts', 'Traditional', 'Souvenirs']
  },
  {
    storeName: 'Bhaktapur Pottery Store',
    storeDescription: 'Traditional pottery and ceramic store. Handcrafted items from local artisans. Cultural heritage preservation.',
    vendorType: 'store',
    vendorSubType: 'pottery',
    isFeatured: false,
    storeRating: 4.5,
    storeReviews: 67,
    storeTags: ['Pottery', 'Ceramic', 'Handcrafted', 'Local Artisans', 'Cultural'],
    storeCategories: ['Pottery', 'Handicrafts', 'Cultural Items']
  },
  {
    storeName: 'Lazimpat Wine & Spirits',
    storeDescription: 'Premium wine and spirits store. International brands and local favorites. Expert recommendations and delivery service.',
    vendorType: 'store',
    vendorSubType: 'wine',
    isFeatured: true,
    storeRating: 4.7,
    storeReviews: 123,
    storeTags: ['Wine', 'Spirits', 'Premium', 'International', 'Expert Service'],
    storeCategories: ['Wine', 'Spirits', 'Beverages']
  },
  {
    storeName: 'Jhamsikhel Fashion Boutique',
    storeDescription: 'Modern fashion boutique with international and local designer clothes. Trendy styles for young professionals.',
    vendorType: 'store',
    vendorSubType: 'fashion',
    isFeatured: false,
    storeRating: 4.1,
    storeReviews: 45,
    storeTags: ['Fashion', 'Boutique', 'Designer', 'Trendy', 'Young Style'],
    storeCategories: ['Fashion', 'Clothing', 'Accessories']
  }
];

async function seedKathmanduVendors() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/first_db');
    console.log('✅ Connected to MongoDB');

    // Only clear existing Kathmandu vendors (by email pattern) to preserve other vendors
    const kathmanduEmails = [
      'restaurant1@tuukatuu.com', 'restaurant2@tuukatuu.com', 'restaurant3@tuukatuu.com',
      'restaurant4@tuukatuu.com', 'restaurant5@tuukatuu.com', 'restaurant6@tuukatuu.com',
      'restaurant7@tuukatuu.com', 'restaurant8@tuukatuu.com',
      'store1@tuukatuu.com', 'store2@tuukatuu.com', 'store3@tuukatuu.com',
      'store4@tuukatuu.com', 'store5@tuukatuu.com', 'store6@tuukatuu.com',
      'store7@tuukatuu.com', 'store8@tuukatuu.com'
    ];
    
    await User.deleteMany({ 
      role: 'vendor', 
      email: { $in: kathmanduEmails } 
    });
    console.log('🗑️  Cleared existing Kathmandu vendors only');

    const vendors = [];
    let vendorIndex = 0;

    // Seed restaurants
    console.log('\n🍽️  Seeding restaurants...');
    for (const restaurant of RESTAURANTS) {
      const location = KATHMANDU_LOCATIONS[vendorIndex % KATHMANDU_LOCATIONS.length];
      
      const vendor = new User({
        name: restaurant.storeName,
        email: `restaurant${vendorIndex + 1}@tuukatuu.com`,
        phone: `+977-${Math.floor(Math.random() * 9000000000) + 1000000000}`,
        password: await bcrypt.hash('password123', 10),
        role: 'vendor',
        isActive: true,
        storeName: restaurant.storeName,
        storeDescription: restaurant.storeDescription,
        storeImage: `https://via.placeholder.com/300x200/FF6B35/FFFFFF?text=${encodeURIComponent(restaurant.storeName)}`,
        storeBanner: `https://via.placeholder.com/800x300/FF6B35/FFFFFF?text=${encodeURIComponent(restaurant.storeName)}`,
        storeTags: restaurant.storeTags,
        vendorType: restaurant.vendorType,
        storeRating: restaurant.storeRating,
        storeReviews: restaurant.storeReviews,
        isFeatured: restaurant.isFeatured,
        storeCoordinates: {
          type: 'Point',
          coordinates: location.coordinates
        },
        storeAddress: location.address,
        storeCategories: restaurant.storeCategories,
        vendorSubType: restaurant.vendorSubType
      });

      await vendor.save();
      vendors.push(vendor);
      console.log(`✅ Created restaurant: ${restaurant.storeName} at ${location.name}`);
      vendorIndex++;
    }

    // Seed stores
    console.log('\n🛍️  Seeding stores...');
    for (const store of STORES) {
      const location = KATHMANDU_LOCATIONS[vendorIndex % KATHMANDU_LOCATIONS.length];
      
      const vendor = new User({
        name: store.storeName,
        email: `store${vendorIndex + 1}@tuukatuu.com`,
        phone: `+977-${Math.floor(Math.random() * 9000000000) + 1000000000}`,
        password: await bcrypt.hash('password123', 10),
        role: 'vendor',
        isActive: true,
        storeName: store.storeName,
        storeDescription: store.storeDescription,
        storeImage: `https://via.placeholder.com/300x200/4CAF50/FFFFFF?text=${encodeURIComponent(store.storeName)}`,
        storeBanner: `https://via.placeholder.com/800x300/4CAF50/FFFFFF?text=${encodeURIComponent(store.storeName)}`,
        storeTags: store.storeTags,
        vendorType: store.vendorType,
        storeRating: store.storeRating,
        storeReviews: store.storeReviews,
        isFeatured: store.isFeatured,
        storeCoordinates: {
          type: 'Point',
          coordinates: location.coordinates
        },
        storeAddress: location.address,
        storeCategories: store.storeCategories,
        vendorSubType: store.vendorSubType
      });

      await vendor.save();
      vendors.push(vendor);
      console.log(`✅ Created store: ${store.storeName} at ${location.name}`);
      vendorIndex++;
    }

    // Summary
    console.log('\n🎉 Kathmandu vendors seeding completed!');
    console.log('\n📊 Summary:');
    console.log(`- Total vendors created: ${vendors.length}`);
    console.log(`- Restaurants: ${RESTAURANTS.length}`);
    console.log(`- Stores: ${STORES.length}`);
    console.log(`- Featured vendors: ${vendors.filter(v => v.isFeatured).length}`);
    
    // Show total vendors in system
    const totalVendors = await User.countDocuments({ role: 'vendor' });
    console.log(`- Total vendors in system: ${totalVendors}`);
    
    console.log('\n📍 Locations used:');
    KATHMANDU_LOCATIONS.forEach((location, index) => {
      console.log(`${index + 1}. ${location.name}: [${location.coordinates[1]}, ${location.coordinates[0]}]`);
    });

    console.log('\n🍽️  Featured Restaurants:');
    vendors.filter(v => v.vendorType === 'restaurant' && v.isFeatured).forEach(vendor => {
      console.log(`- ${vendor.storeName} (${vendor.storeRating}⭐)`);
    });

    console.log('\n🛍️  Featured Stores:');
    vendors.filter(v => v.vendorType === 'store' && v.isFeatured).forEach(vendor => {
      console.log(`- ${vendor.storeName} (${vendor.storeRating}⭐)`);
    });

    // Test the geoNear query
    console.log('\n🧪 Testing geoNear query...');
    const testLat = 27.7172;
    const testLon = 85.3148;
    
    const nearbyVendors = await User.aggregate([
      {
        $geoNear: {
          near: { type: 'Point', coordinates: [testLon, testLat] },
          distanceField: 'distance',
          spherical: true,
          maxDistance: 10000, // 10km
          query: { role: 'vendor', vendorType: 'restaurant', isFeatured: true }
        }
      },
      {
        $project: {
          storeName: 1,
          storeAddress: 1,
          distance: 1,
          isFeatured: 1
        }
      },
      {
        $sort: { distance: 1 }
      }
    ]);
    
    console.log(`📍 Found ${nearbyVendors.length} nearby featured restaurants from test coordinates [${testLat}, ${testLon}]:`);
    nearbyVendors.forEach((vendor, index) => {
      console.log(`${index + 1}. ${vendor.storeName} - ${Math.round(vendor.distance)}m away`);
    });

    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding Kathmandu vendors:', error);
    console.error('Stack trace:', error.stack);
    process.exit(1);
  }
}

seedKathmanduVendors();
