const mongoose = require('mongoose');
const config = require('../src/config');

// Import T-Mart models
const TMartCategory = require('../src/models/TMartCategory');
const TMartProduct = require('../src/models/TMartProduct');
const Banner = require('../src/models/Banner');
const TMartDeal = require('../src/models/TMartDeal');

async function seedTMartData() {
  try {
    console.log('🌱 Starting T-Mart data seeding...');
    
    // Connect to database
    await mongoose.connect(config.mongoUri);
    console.log('✅ Connected to MongoDB');
    
    // Seed categories first
    console.log('📂 Seeding T-Mart categories...');
    await TMartCategory.seedTMartCategories();
    console.log('✅ Categories seeded successfully');
    
    // Seed products
    console.log('🛍️ Seeding T-Mart products...');
    await TMartProduct.seedTMartProducts();
    console.log('✅ Products seeded successfully');
    
    // Seed banners
    console.log('🖼️ Seeding T-Mart banners...');
    await seedTMartBanners();
    console.log('✅ Banners seeded successfully');
    
    // Seed deals
    console.log('🎯 Seeding T-Mart deals...');
    await TMartDeal.seedTMartDeals();
    console.log('✅ Deals seeded successfully');
    
    // Update product counts in categories
    console.log('📊 Updating category product counts...');
    const categories = await TMartCategory.find();
    for (const category of categories) {
      const count = await TMartProduct.countDocuments({ category: category.displayName });
      await TMartCategory.findByIdAndUpdate(category._id, { productCount: count });
    }
    console.log('✅ Category product counts updated');
    
    console.log('🎉 T-Mart data seeding completed successfully!');
    
    // Display summary
    const categoryCount = await TMartCategory.countDocuments();
    const productCount = await TMartProduct.countDocuments();
    const bannerCount = await Banner.countDocuments({ bannerType: 'tmart' });
    const dealCount = await TMartDeal.countDocuments();
    
    console.log('\n📈 Seeding Summary:');
    console.log(`   Categories: ${categoryCount}`);
    console.log(`   Products: ${productCount}`);
    console.log(`   T-Mart Banners: ${bannerCount}`);
    console.log(`   Deals: ${dealCount}`);
    
  } catch (error) {
    console.error('❌ Error seeding T-Mart data:', error);
  } finally {
    await mongoose.disconnect();
    console.log('🔌 Disconnected from MongoDB');
  }
}

// Seed T-Mart banners using the unified Banner model
async function seedTMartBanners() {
  try {
    // Remove existing T-Mart banners
    await Banner.deleteMany({ bannerType: 'tmart' });
    console.log('🗑️  Removed existing T-Mart banners');
    
    // Sample T-Mart banners
    const banners = [
      {
        title: 'Get 20% OFF',
        subtitle: 'On your first T-Mart order',
        description: 'Special discount for new customers',
        image: 'https://images.unsplash.com/photo-1608686207856-001b95cf60ca',
        imageAlt: 'T-Mart 20% off promotion',
        link: '/tmart/products',
        linkType: 'category',
        linkTarget: 'tmart',
        bannerType: 'tmart',
        category: 'grocery',
        sortOrder: 1,
        priority: 1,
        backgroundColor: '#FF6B35',
        textColor: '#FFFFFF',
        isActive: true,
        isFeatured: true,
        startDate: new Date(),
        endDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // 30 days from now
        targetAudience: ['new-customers'],
        createdBy: '687f14db32e676d13d3a3cf2', // Admin user ID
        updatedBy: '687f14db32e676d13d3a3cf2'
      },
      {
        title: 'Free Delivery',
        subtitle: 'On orders above Rs. 500',
        description: 'Free delivery for orders above Rs. 500',
        image: 'https://images.unsplash.com/photo-1581056771107-24ca5f033842',
        imageAlt: 'T-Mart free delivery promotion',
        link: '/tmart/delivery-info',
        linkType: 'external',
        linkTarget: 'delivery',
        bannerType: 'tmart',
        category: 'general',
        sortOrder: 2,
        priority: 1,
        backgroundColor: '#4CAF50',
        textColor: '#FFFFFF',
        isActive: true,
        isFeatured: false,
        startDate: new Date(),
        endDate: null, // No end date
        targetAudience: ['all-customers'],
        createdBy: '687f14db32e676d13d3a3cf2',
        updatedBy: '687f14db32e676d13d3a3cf2'
      },
      {
        title: '15% Cashback',
        subtitle: 'On all grocery items',
        description: 'Get 15% cashback on grocery purchases',
        image: 'https://images.unsplash.com/photo-1621939514649-280e2ee25f60',
        imageAlt: 'T-Mart grocery cashback promotion',
        link: '/tmart/grocery',
        linkType: 'category',
        linkTarget: 'grocery',
        bannerType: 'tmart',
        category: 'grocery',
        sortOrder: 3,
        priority: 1,
        backgroundColor: '#2196F3',
        textColor: '#FFFFFF',
        isActive: true,
        isFeatured: true,
        startDate: new Date(),
        endDate: new Date(Date.now() + 15 * 24 * 60 * 60 * 1000), // 15 days from now
        targetAudience: ['grocery-customers'],
        createdBy: '687f14db32e676d13d3a3cf2',
        updatedBy: '687f14db32e676d13d3a3cf2'
      }
    ];
    
    const createdBanners = await Banner.insertMany(banners);
    console.log(`✅ Created ${createdBanners.length} T-Mart banners`);
    
    return createdBanners;
  } catch (error) {
    console.error('❌ Error seeding T-Mart banners:', error);
    throw error;
  }
}

// Run seeding if this file is executed directly
if (require.main === module) {
  seedTMartData();
}

module.exports = seedTMartData; 