const mongoose = require('mongoose');
const Product = require('./src/models/Product');
const User = require('./src/models/User');

mongoose.connect('mongodb://localhost:27017/first_db', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

const markFeaturedProducts = async () => {
  try {
    console.log('⭐ Marking products as featured...');

    // Mark some products as featured with order
    const featuredProducts = [
      {
        name: 'Cadbury Dairy Milk Silk Bubbly Chocolate Bar – Quick Pantry',
        featuredOrder: 1
      },
      {
        name: 'Jam Shed Red Blend',
        featuredOrder: 2
      },
      {
        name: 'TUBORG STRONG BEER – Mansionz',
        featuredOrder: 3
      },
      {
        name: 'Mother Dairy Cheese Slices, 200 g Pack : Amazon.in: Grocery & Gourmet Foods',
        featuredOrder: 4
      },
      {
        name: 'Apple',
        featuredOrder: 5
      },
      {
        name: 'Grape Wine, 750ml Fresh Grape Homemade Wine',
        featuredOrder: 6
      }
    ];

    // Update products to mark them as featured
    for (const product of featuredProducts) {
      const result = await Product.updateOne(
        { 
          name: product.name,
          isAvailable: true 
        },
        { 
          $set: { 
            isFeatured: true,
            featuredOrder: product.featuredOrder
          } 
        }
      );
      
      if (result.modifiedCount > 0) {
        console.log(`✅ Marked "${product.name}" as featured (order: ${product.featuredOrder})`);
      } else {
        console.log(`⚠️ Product "${product.name}" not found or already featured`);
      }
    }

    // Show featured products
    const featuredProductsList = await Product.find({ isFeatured: true, isAvailable: true })
      .sort({ featuredOrder: 1 })
      .populate('vendorId', 'storeName');

    console.log('\n⭐ Featured products:');
    featuredProductsList.forEach((product, index) => {
      console.log(`${index + 1}. ${product.name} - Order: ${product.featuredOrder} - Vendor: ${product.vendorId?.storeName || 'Unknown'}`);
    });

    console.log('\n🎉 Featured products setup completed!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error marking featured products:', error);
    process.exit(1);
  }
};

markFeaturedProducts(); 