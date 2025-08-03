const mongoose = require('mongoose');
const TMartProduct = require('./src/models/TMartProduct');
const TMartCategory = require('./src/models/TMartCategory');
require('dotenv').config();

async function seedWineProducts() {
  try {
    console.log('🍷 Starting wine products seeding...');
    
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/tuukatuu');
    console.log('✅ Connected to MongoDB');
    
    // Seed categories first
    console.log('📂 Seeding T-Mart categories...');
    await TMartCategory.seedTMartCategories();
    console.log('✅ Categories seeded successfully');
    
    // Seed products
    console.log('📦 Seeding T-Mart products...');
    await TMartProduct.seedTMartProducts();
    console.log('✅ Products seeded successfully');
    
    // Verify wine products were added
    console.log('🔍 Verifying wine products...');
    const wineProducts = await TMartProduct.find({ category: 'Wine & Beer' });
    console.log(`✅ Found ${wineProducts.length} wine products:`);
    wineProducts.forEach(product => {
      console.log(`   - ${product.name}: Rs. ${product.price}`);
    });
    
    // Verify category exists
    const wineCategory = await TMartCategory.findOne({ name: 'wine-beer' });
    if (wineCategory) {
      console.log(`✅ Wine & Beer category found: ${wineCategory.displayName}`);
    } else {
      console.log('❌ Wine & Beer category not found');
    }
    
    console.log('🎉 Wine products seeding completed successfully!');
    
  } catch (error) {
    console.error('❌ Error seeding wine products:', error);
  } finally {
    await mongoose.disconnect();
    console.log('🔌 Disconnected from MongoDB');
  }
}

// Run the seeding
seedWineProducts(); 