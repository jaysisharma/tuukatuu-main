const mongoose = require('mongoose');
const Product = require('./src/models/Product');

mongoose.connect('mongodb://localhost:27017/first_db', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

const markPopularProducts = async () => {
  try {
    console.log('🏆 Marking products as popular...');

    // Mark some products as popular based on different criteria
    const popularProductNames = [
      'Jam Shed Red Blend',
      'Gran Cuvée Brut – Fratelli Wines',
      'Cadbury Dairy Milk Silk Bubbly Chocolate Bar – Quick Pantry',
      'Mother Dairy Cheese Slices, 200 g Pack : Amazon.in: Grocery & Gourmet Foods',
      'Buy Farm Fresh Speciality Eggs – Suguna Delfrez',
      'TUBORG STRONG BEER – Mansionz',
      'Buy Pantene Advanced Hairfall Solution, Hairfall Control Shampoo, Pack of 1, 650ML, Pink',
      'Apple',
      'Grape Wine, 750ml Fresh Grape Homemade Wine'
    ];

    // Update products to mark them as popular
    const result = await Product.updateMany(
      { 
        name: { $in: popularProductNames },
        isAvailable: true 
      },
      { 
        $set: { isPopular: true }
      }
    );

    console.log(`✅ Marked ${result.modifiedCount} products as popular`);

    // Also mark some products as popular based on high ratings
    const highRatedResult = await Product.updateMany(
      { 
        rating: { $gte: 4.5 },
        reviews: { $gte: 10 },
        isAvailable: true,
        isPopular: { $ne: true } // Don't update already popular products
      },
      { 
        $set: { isPopular: true } 
      }
    );

    console.log(`✅ Marked ${highRatedResult.modifiedCount} high-rated products as popular`);

    // Show some popular products
    const popularProducts = await Product.find({ isPopular: true, isAvailable: true })
      .sort({ rating: -1, reviews: -1 })
      .limit(10);

    console.log('\n🏆 Popular products:');
    popularProducts.forEach((product, index) => {
      console.log(`${index + 1}. ${product.name} - Rating: ${product.rating} (${product.reviews} reviews)`);
    });

    console.log('\n🎉 Popular products setup completed!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error marking popular products:', error);
    process.exit(1);
  }
};

markPopularProducts(); 