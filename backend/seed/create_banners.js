const mongoose = require('mongoose');
require('dotenv').config();

// Import models
const Banner = require('../src/models/Banner');
const User = require('../src/models/User');

mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/first_db', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

const createBanners = async () => {
  try {
    console.log('🎨 Creating banners...');

    // Get admin user for createdBy field
    const adminUser = await User.findOne({ role: 'admin' });
    if (!adminUser) {
      console.error('❌ No admin user found. Please create an admin user first.');
      process.exit(1);
    }

    // Check if banners already exist
    const existingBanners = await Banner.find();
    if (existingBanners.length > 0) {
      console.log(`Found ${existingBanners.length} existing banners. Updating them...`);
    }

    const banners = [
      // Banner 1: Restaurant Promotion
      {
        title: '🍕 Restaurant Week',
        subtitle: 'Up to 40% OFF on your favorite restaurants',
        imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&h=400&fit=crop',
        link: '/restaurants',
        isActive: true,
        createdBy: adminUser._id,
        priority: 1,
        category: 'restaurant',
        backgroundColor: '#FF6B35',
        textColor: '#FFFFFF'
      },
      
      // Banner 2: Grocery Store Promotion
      {
        title: '🛒 Fresh Groceries',
        subtitle: 'Get fresh groceries delivered in 30 minutes',
        imageUrl: 'https://images.unsplash.com/photo-1604719312566-8912e9227c6a?w=800&h=400&fit=crop',
        link: '/grocery',
        isActive: true,
        createdBy: adminUser._id,
        priority: 2,
        category: 'grocery',
        backgroundColor: '#4CAF50',
        textColor: '#FFFFFF'
      },
      
      // Banner 3: Pharmacy Promotion
      {
        title: '💊 Health Essentials',
        subtitle: 'Free delivery on medicines & health products',
        imageUrl: 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=800&h=400&fit=crop',
        link: '/pharmacy',
        isActive: true,
        createdBy: adminUser._id,
        priority: 3,
        category: 'pharmacy',
        backgroundColor: '#2196F3',
        textColor: '#FFFFFF'
      }
    ];

    // Clear existing banners and create new ones
    await Banner.deleteMany({});
    
    for (const bannerData of banners) {
      const banner = new Banner(bannerData);
      await banner.save();
      console.log(`✅ Created banner: ${bannerData.title}`);
    }

    // Display summary
    const allBanners = await Banner.find().populate('createdBy', 'name email');
    
    console.log('\n🎉 Banners created successfully!');
    console.log('\nSummary:');
    console.log(`- Total banners: ${allBanners.length}`);
    
    console.log('\n📢 Active banners:');
    allBanners.forEach((banner, index) => {
      console.log(`${index + 1}. ${banner.title} - ${banner.subtitle}`);
      console.log(`   Category: ${banner.category || 'General'}`);
      console.log(`   Link: ${banner.link}`);
      console.log(`   Created by: ${banner.createdBy?.name || 'Admin'}`);
      console.log('');
    });

    process.exit(0);
  } catch (error) {
    console.error('❌ Error creating banners:', error);
    process.exit(1);
  }
};

createBanners(); 