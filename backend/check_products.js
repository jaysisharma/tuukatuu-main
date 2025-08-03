const mongoose = require('mongoose');
const Product = require('./src/models/Product');

mongoose.connect('mongodb://localhost:27017/first_db', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

const checkProducts = async () => {
  try {
    console.log('🔍 Checking products in database...');
    
    const products = await Product.find({}).limit(20);
    
    console.log(`Found ${products.length} products:`);
    products.forEach((product, index) => {
      console.log(`${index + 1}. ${product.name} - Category: ${product.category} - Available: ${product.isAvailable}`);
    });
    
    // Check categories
    const categories = await Product.distinct('category');
    console.log('\n📂 Categories found:');
    categories.forEach(cat => console.log(`- ${cat}`));
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
};

checkProducts(); 