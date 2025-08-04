const mongoose = require('mongoose');
require('dotenv').config();

const Product = require('./src/models/Product');

mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/first_db2', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

async function updateStock() {
  try {
    console.log('🔄 Updating stock values for existing products...');
    
    // Update restaurant products
    await Product.updateMany(
      { vendorType: 'restaurant', stock: { $lt: 10 } },
      { $set: { stock: 50 } }
    );
    
    // Update store products
    await Product.updateMany(
      { vendorType: 'store', stock: { $lt: 10 } },
      { $set: { stock: 100 } }
    );
    
    // Update specific products with realistic stock values
    const updates = [
      { name: 'Kung Pao Chicken', stock: 100 },
      { name: 'Sweet and Sour Pork', stock: 80 },
      { name: 'Vegetable Fried Rice', stock: 120 },
      { name: 'Classic Burger', stock: 100 },
      { name: 'Chicken Wings', stock: 80 },
      { name: 'Fresh Bananas', stock: 200 },
      { name: 'Fresh Milk', stock: 150 },
      { name: 'Whole Wheat Bread', stock: 100 },
      { name: 'Paracetamol 500mg', stock: 50 },
      { name: 'Vitamin C 1000mg', stock: 50 },
      { name: 'Toothpaste', stock: 50 },
      { name: 'USB-C Cable', stock: 30 },
      { name: 'Wireless Earbuds', stock: 15 }
    ];
    
    for (const update of updates) {
      await Product.updateMany(
        { name: update.name },
        { $set: { stock: update.stock } }
      );
    }
    
    console.log('✅ Stock values updated successfully!');
    
    // Show some products with their stock
    const products = await Product.find().limit(5);
    console.log('\n📦 Sample products with stock:');
    products.forEach(p => {
      console.log(`- ${p.name}: ${p.stock} units`);
    });
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error updating stock:', error);
    process.exit(1);
  }
}

updateStock(); 