const mongoose = require('mongoose');
require('dotenv').config();

// Import models
const User = require('../src/models/User');
const Product = require('../src/models/Product');

// Connect to the database
const MONGODB_URI = 'mongodb+srv://testbuddy1221:jaysi123@cluster0.1bjhspl.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0';
mongoose.connect(MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

async function checkResults() {
  try {
    console.log('🔍 Checking database results...\n');

    // Check grocery and wine vendors
    const groceryVendors = await User.find({ 
      role: 'vendor', 
      vendorSubType: { $in: ['grocery', 'supermarket', 'organic_market'] } 
    });
    
    const wineVendors = await User.find({ 
      role: 'vendor', 
      vendorSubType: 'wine' 
    });

    console.log('🏪 GROCERY VENDORS:');
    groceryVendors.forEach(vendor => {
      console.log(`- ${vendor.storeName} (${vendor.vendorSubType})`);
      console.log(`  Email: ${vendor.email}`);
      console.log(`  Address: ${vendor.storeAddress}`);
      console.log(`  Rating: ${vendor.storeRating} ⭐`);
      console.log('');
    });

    console.log('🍷 WINE VENDORS:');
    wineVendors.forEach(vendor => {
      console.log(`- ${vendor.storeName} (${vendor.vendorSubType})`);
      console.log(`  Email: ${vendor.email}`);
      console.log(`  Address: ${vendor.storeAddress}`);
      console.log(`  Rating: ${vendor.storeRating} ⭐`);
      console.log('');
    });

    // Check products
    const groceryProducts = await Product.find({ 
      vendorSubType: { $in: ['grocery', 'supermarket', 'organic_market'] } 
    });
    
    const wineProducts = await Product.find({ 
      vendorSubType: 'wine' 
    });

    console.log('🛍️ GROCERY PRODUCTS:');
    groceryProducts.forEach(product => {
      console.log(`- ${product.name} (${product.category})`);
      console.log(`  Price: Rs. ${product.price}`);
      console.log(`  Unit: ${product.unit}`);
      console.log(`  Rating: ${product.rating} ⭐`);
      console.log('');
    });

    console.log('🍷 WINE PRODUCTS:');
    wineProducts.forEach(product => {
      console.log(`- ${product.name} (${product.category})`);
      console.log(`  Price: Rs. ${product.price}`);
      console.log(`  Unit: ${product.unit}`);
      console.log(`  Rating: ${product.rating} ⭐`);
      console.log('');
    });

    console.log('📊 SUMMARY:');
    console.log(`- Total Grocery Vendors: ${groceryVendors.length}`);
    console.log(`- Total Wine Vendors: ${wineVendors.length}`);
    console.log(`- Total Grocery Products: ${groceryProducts.length}`);
    console.log(`- Total Wine Products: ${wineProducts.length}`);

    process.exit(0);
  } catch (error) {
    console.error('❌ Error checking results:', error);
    process.exit(1);
  }
}

checkResults(); 