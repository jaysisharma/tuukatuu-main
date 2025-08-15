const mongoose = require('mongoose');
const TMartProduct = require('../src/models/TMartProduct');

mongoose.connect('mongodb://localhost:27017/first_db', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

const testVendorIds = async () => {
  try {
    console.log('🔍 Checking T-Mart products for vendor IDs...');
    
    const products = await TMartProduct.find({}).limit(5);
    
    console.log(`Found ${products.length} products:`);
    products.forEach((product, index) => {
      console.log(`${index + 1}. ${product.name}`);
      console.log(`   Vendor ID: ${product.vendorId}`);
      console.log(`   Category: ${product.category}`);
      console.log('   ---');
    });
    
    // Check if any products are missing vendor IDs
    const productsWithoutVendorId = await TMartProduct.find({ vendorId: { $exists: false } });
    console.log(`\nProducts without vendor ID: ${productsWithoutVendorId.length}`);
    
    if (productsWithoutVendorId.length > 0) {
      console.log('Products missing vendor ID:');
      productsWithoutVendorId.forEach(p => console.log(`- ${p.name}`));
    }
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
};

testVendorIds(); 