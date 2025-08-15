const mongoose = require('mongoose');
require('dotenv').config();

console.log('🚀 Starting Enhanced Kathmandu Seeding Process...\n');

async function seedEnhancedKathmandu() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/first_db');
    console.log('✅ Connected to MongoDB\n');

    // Step 1: Create Admin User
    console.log('👑 Step 1: Creating Admin User...');
    try {
      const { execSync } = require('child_process');
      execSync('node seed/create_admin.js', { stdio: 'inherit' });
      console.log('✅ Admin user created/verified\n');
    } catch (error) {
      console.log('ℹ️  Admin user already exists or error occurred\n');
    }

    // Step 2: Create Enhanced Vendors
    console.log('🏪 Step 2: Creating Enhanced Kathmandu Vendors...');
    try {
      const { execSync } = require('child_process');
      execSync('node seed/seed_kathmandu_vendors.js', { stdio: 'inherit' });
      console.log('✅ Enhanced vendors created\n');
    } catch (error) {
      console.log('❌ Error creating vendors:', error.message);
      throw error;
    }

    // Step 3: Create Enhanced Products (this will auto-create categories)
    console.log('🛍️  Step 3: Creating Enhanced Kathmandu Products...');
    try {
      const { execSync } = require('child_process');
      execSync('node seed/seed_kathmandu_products.js', { stdio: 'inherit' });
      console.log('✅ Enhanced products created\n');
    } catch (error) {
      console.log('❌ Error creating products:', error.message);
      throw error;
    }

    // Step 4: Verify Categories were auto-created
    console.log('📊 Step 4: Verifying Auto-Created Categories...');
    try {
      const Category = require('../src/models/Category');
      const Product = require('../src/models/Product');
      
      const categories = await Category.find({});
      const products = await Product.find({});
      
      console.log(`✅ Categories: ${categories.length}`);
      console.log(`✅ Products: ${products.length}`);
      
      // Show category distribution
      const categoryCounts = {};
      products.forEach(product => {
        categoryCounts[product.category] = (categoryCounts[product.category] || 0) + 1;
      });
      
      console.log('\n📊 Category Distribution:');
      Object.entries(categoryCounts).forEach(([category, count]) => {
        console.log(`- ${category}: ${count} products`);
      });
      
      console.log('\n🎯 Auto-category creation verification:');
      categories.forEach(category => {
        const productCount = categoryCounts[category.name] || 0;
        console.log(`✅ ${category.name}: ${productCount} products (auto-created: ${category.createdBy ? 'Yes' : 'No'})`);
      });
      
    } catch (error) {
      console.log('❌ Error verifying categories:', error.message);
    }

    console.log('\n🎉 Enhanced Kathmandu Seeding Process Completed Successfully!');
    console.log('\n📋 Summary:');
    console.log('- ✅ Admin user created/verified');
    console.log('- ✅ Enhanced vendors created with detailed information');
    console.log('- ✅ Enhanced products created with comprehensive data');
    console.log('- ✅ Categories auto-created from products');
    console.log('- ✅ All data properly linked and categorized');
    
    console.log('\n🔑 Login Credentials:');
    console.log('- Email: admin@tuukatuu.com');
    console.log('- Password: admin123');
    
    console.log('\n🌐 Next Steps:');
    console.log('1. Start your backend server: npm run dev');
    console.log('2. Start your client application');
    console.log('3. Login with admin credentials');
    console.log('4. Navigate to admin categories and products pages');
    console.log('5. You should now see all categories and products!');

    process.exit(0);
  } catch (error) {
    console.error('\n❌ Enhanced Kathmandu Seeding Failed:', error);
    console.error('Stack trace:', error.stack);
    process.exit(1);
  }
}

seedEnhancedKathmandu();
