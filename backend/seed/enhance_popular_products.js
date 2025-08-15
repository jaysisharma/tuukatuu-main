const mongoose = require('mongoose');
require('dotenv').config();

// Import Product model
const Product = require('../src/models/Product');

mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/tuukatuu', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

const enhancePopularProducts = async () => {
  try {
    console.log('🏆 Enhancing popular products with better variety...');

    // Mark products as popular based on different criteria
    const popularProductNames = [
      'Jam Shed Red Blend',
      'Gran Cuvée Brut – Fratelli Wines',
      'Cadbury Dairy Milk Silk Bubbly Chocolate Bar',
      'Mother Dairy Cheese Slices',
      'Farm Fresh Speciality Eggs',
      'TUBORG STRONG BEER',
      'Pantene Advanced Hairfall Solution',
      'Apple',
      'Grape Wine',
      'Fresh Milk',
      'Cheese Block',
      'Yogurt',
      'Organic Bananas',
      'Organic Carrots',
      'Red Wine',
      'White Wine',
      'Beer',
      'Bread',
      'Cake',
      'Chocolate',
      'Snacks',
      'Cookies',
      'Chips',
      'Nuts',
      'Dried Fruits',
      'Fresh Fruits',
      'Vegetables',
      'Meat',
      'Fish',
      'Chicken',
      'Rice',
      'Pasta',
      'Sauce',
      'Oil',
      'Butter',
      'Eggs',
      'Juice',
      'Soda',
      'Water',
      'Tea',
      'Coffee',
      'Sugar',
      'Salt',
      'Spices',
      'Herbs',
      'Flour',
      'Yeast',
      'Honey',
      'Jam',
      'Pickle'
    ];

    // Update products to mark them as popular
    const result = await Product.updateMany(
      { 
        name: { $in: popularProductNames },
        isAvailable: true 
      },
      { 
        $set: { 
          isPopular: true,
          rating: { $gte: 4.0 },
          reviews: { $gte: 5 }
        }
      }
    );

    console.log(`✅ Marked ${result.modifiedCount} products as popular`);

    // Also mark some products as popular based on high ratings
    const highRatedResult = await Product.updateMany(
      { 
        rating: { $gte: 4.2 },
        reviews: { $gte: 8 },
        isAvailable: true,
        isPopular: { $ne: true } // Don't update already popular products
      },
      { 
        $set: { isPopular: true } 
      }
    );

    console.log(`✅ Marked ${highRatedResult.modifiedCount} high-rated products as popular`);

    // Mark some products as featured for variety
    const featuredResult = await Product.updateMany(
      { 
        rating: { $gte: 4.0 },
        reviews: { $gte: 5 },
        isAvailable: true,
        isFeatured: { $ne: true }
      },
      { 
        $set: { 
          isFeatured: true,
          featuredOrder: Math.floor(Math.random() * 100)
        } 
      }
    );

    console.log(`✅ Marked ${featuredResult.modifiedCount} products as featured`);

    // Mark some products as best sellers
    const bestSellerResult = await Product.updateMany(
      { 
        rating: { $gte: 4.0 },
        reviews: { $gte: 3 },
        isAvailable: true,
        isBestSeller: { $ne: true }
      },
      { 
        $set: { isBestSeller: true } 
      }
    );

    console.log(`✅ Marked ${bestSellerResult.modifiedCount} products as best sellers`);

    // Mark some products as new arrivals
    const newArrivalResult = await Product.updateMany(
      { 
        isAvailable: true,
        isNewArrival: { $ne: true },
        createdAt: { $gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) } // Last 7 days
      },
      { 
        $set: { isNewArrival: true } 
      }
    );

    console.log(`✅ Marked ${newArrivalResult.modifiedCount} products as new arrivals`);

    // Show some popular products
    const popularProducts = await Product.find({ isPopular: true, isAvailable: true })
      .sort({ rating: -1, reviews: -1 })
      .limit(10);

    console.log('\n🏆 Popular products:');
    popularProducts.forEach((product, index) => {
      console.log(`${index + 1}. ${product.name} - Rating: ${product.rating} (${product.reviews} reviews)`);
    });

    // Show some featured products
    const featuredProducts = await Product.find({ isFeatured: true, isAvailable: true })
      .sort({ featuredOrder: 1, rating: -1 })
      .limit(5);

    console.log('\n⭐ Featured products:');
    featuredProducts.forEach((product, index) => {
      console.log(`${index + 1}. ${product.name} - Order: ${product.featuredOrder}`);
    });

    // Show some best sellers
    const bestSellers = await Product.find({ isBestSeller: true, isAvailable: true })
      .sort({ rating: -1, reviews: -1 })
      .limit(5);

    console.log('\n🔥 Best sellers:');
    bestSellers.forEach((product, index) => {
      console.log(`${index + 1}. ${product.name} - Rating: ${product.rating}`);
    });

    console.log('\n🎉 Popular products enhancement completed!');
    console.log('\nSummary:');
    console.log(`- Popular products: ${popularProducts.length}`);
    console.log(`- Featured products: ${featuredProducts.length}`);
    console.log(`- Best sellers: ${bestSellers.length}`);
    console.log(`- Total enhanced: ${result.modifiedCount + highRatedResult.modifiedCount + featuredResult.modifiedCount + bestSellerResult.modifiedCount + newArrivalResult.modifiedCount}`);

    process.exit(0);
  } catch (error) {
    console.error('❌ Error enhancing popular products:', error);
    process.exit(1);
  }
};

enhancePopularProducts(); 