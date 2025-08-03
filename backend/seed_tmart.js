const mongoose = require('mongoose');
const config = require('./src/config');

// Import T-Mart models
const TMartCategory = require('./src/models/TMartCategory');
const TMartProduct = require('./src/models/TMartProduct');
const TMartBanner = require('./src/models/TMartBanner');
const TMartDeal = require('./src/models/TMartDeal');

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
    await TMartBanner.seedTMartBanners();
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
    const bannerCount = await TMartBanner.countDocuments();
    const dealCount = await TMartDeal.countDocuments();
    
    console.log('\n📈 Seeding Summary:');
    console.log(`   Categories: ${categoryCount}`);
    console.log(`   Products: ${productCount}`);
    console.log(`   Banners: ${bannerCount}`);
    console.log(`   Deals: ${dealCount}`);
    
  } catch (error) {
    console.error('❌ Error seeding T-Mart data:', error);
  } finally {
    await mongoose.disconnect();
    console.log('🔌 Disconnected from MongoDB');
  }
}

// Run seeding if this file is executed directly
if (require.main === module) {
  seedTMartData();
}

module.exports = seedTMartData; 