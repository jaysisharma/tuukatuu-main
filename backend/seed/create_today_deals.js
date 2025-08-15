const mongoose = require('mongoose');
require('dotenv').config();

// Import models
const TodayDeal = require('../src/models/TodayDeal');
const Product = require('../src/models/Product');

async function createTodayDeals() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/first_db2');
    console.log('Connected to MongoDB');

    // Clear existing deals
    await TodayDeal.deleteMany({});
    console.log('Cleared existing deals');

    // Get some products to create deals for
    const products = await Product.find({}).limit(20);
    console.log(`Found ${products.length} products to create deals for`);

    if (products.length === 0) {
      console.log('❌ No products found. Please seed products first.');
      process.exit(1);
    }

    // Create sample deals
    const deals = [
      {
        productId: products[0]?._id,
        productName: 'Fresh Organic Bananas',
        productImage: 'https://via.placeholder.com/300x300/4CAF50/FFFFFF?text=Bananas',
        originalPrice: 120,
        dealPrice: 80,
        discountPercentage: 33,
        description: 'Sweet organic bananas at unbeatable price!',
        dealType: 'percentage',
        category: 'Fruits',
        featured: true,
        maxQuantity: 50,
        endDate: new Date(Date.now() + 24 * 60 * 60 * 1000), // 24 hours from now
        tags: ['organic', 'fruits', 'healthy']
      },
      {
        productId: products[1]?._id,
        productName: 'Premium Whole Milk',
        productImage: 'https://via.placeholder.com/300x300/2196F3/FFFFFF?text=Milk',
        originalPrice: 85,
        dealPrice: 65,
        discountPercentage: 24,
        description: 'Fresh whole milk with 3.5% fat content',
        dealType: 'percentage',
        category: 'Dairy',
        featured: true,
        maxQuantity: 30,
        endDate: new Date(Date.now() + 12 * 60 * 60 * 1000), // 12 hours from now
        tags: ['dairy', 'fresh', 'protein']
      },
      {
        productId: products[2]?._id,
        productName: 'Organic Brown Bread',
        productImage: 'https://via.placeholder.com/300x300/FF9800/FFFFFF?text=Bread',
        originalPrice: 95,
        dealPrice: 70,
        discountPercentage: 26,
        description: 'Healthy brown bread made with whole grains',
        dealType: 'percentage',
        category: 'Bakery',
        featured: false,
        maxQuantity: 25,
        endDate: new Date(Date.now() + 18 * 60 * 60 * 1000), // 18 hours from now
        tags: ['organic', 'bakery', 'whole-grain']
      },
      {
        productId: products[3]?._id,
        productName: 'Fresh Tomatoes',
        productImage: 'https://via.placeholder.com/300x300/F44336/FFFFFF?text=Tomatoes',
        originalPrice: 60,
        dealPrice: 40,
        discountPercentage: 33,
        description: 'Juicy red tomatoes perfect for salads',
        dealType: 'percentage',
        category: 'Vegetables',
        featured: true,
        maxQuantity: 40,
        endDate: new Date(Date.now() + 6 * 60 * 60 * 1000), // 6 hours from now
        tags: ['vegetables', 'fresh', 'salad']
      },
      {
        productId: products[4]?._id,
        productName: 'Greek Yogurt',
        productImage: 'https://via.placeholder.com/300x300/9C27B0/FFFFFF?text=Yogurt',
        originalPrice: 110,
        dealPrice: 85,
        discountPercentage: 23,
        description: 'Creamy Greek yogurt with live cultures',
        dealType: 'percentage',
        category: 'Dairy',
        featured: false,
        maxQuantity: 35,
        endDate: new Date(Date.now() + 15 * 60 * 60 * 1000), // 15 hours from now
        tags: ['dairy', 'protein', 'probiotic']
      },
      {
        productId: products[5]?._id,
        productName: 'Organic Eggs',
        productImage: 'https://via.placeholder.com/300x300/FFEB3B/FFFFFF?text=Eggs',
        originalPrice: 180,
        dealPrice: 140,
        discountPercentage: 22,
        description: 'Farm fresh organic eggs',
        dealType: 'percentage',
        category: 'Dairy',
        featured: true,
        maxQuantity: 20,
        endDate: new Date(Date.now() + 10 * 60 * 60 * 1000), // 10 hours from now
        tags: ['organic', 'protein', 'farm-fresh']
      },
      {
        productId: products[6]?._id,
        productName: 'Avocado',
        productImage: 'https://via.placeholder.com/300x300/4CAF50/FFFFFF?text=Avocado',
        originalPrice: 150,
        dealPrice: 100,
        discountPercentage: 33,
        description: 'Ripe and ready to eat avocados',
        dealType: 'percentage',
        category: 'Fruits',
        featured: false,
        maxQuantity: 15,
        endDate: new Date(Date.now() + 8 * 60 * 60 * 1000), // 8 hours from now
        tags: ['fruits', 'healthy', 'superfood']
      },
      {
        productId: products[7]?._id,
        productName: 'Chicken Breast',
        productImage: 'https://via.placeholder.com/300x300/FF5722/FFFFFF?text=Chicken',
        originalPrice: 350,
        dealPrice: 280,
        discountPercentage: 20,
        description: 'Boneless skinless chicken breast',
        dealType: 'percentage',
        category: 'Meat',
        featured: true,
        maxQuantity: 12,
        endDate: new Date(Date.now() + 20 * 60 * 60 * 1000), // 20 hours from now
        tags: ['meat', 'protein', 'lean']
      }
    ];

    // Create deals in database
    const createdDeals = await TodayDeal.insertMany(deals);
    console.log(`✅ Created ${createdDeals.length} today's deals`);

    // Log the created deals
    createdDeals.forEach((deal, index) => {
      console.log(`${index + 1}. ${deal.productName} - ${deal.discountPercentage}% OFF`);
      console.log(`   Original: ₹${deal.originalPrice} → Deal: ₹${deal.dealPrice}`);
      console.log(`   Valid until: ${deal.endDate.toLocaleString()}`);
      console.log(`   Remaining: ${deal.remainingQuantity}/${deal.maxQuantity}`);
      console.log('');
    });

    console.log('✅ Today\'s deals seeded successfully!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error creating today\'s deals:', error);
    process.exit(1);
  }
}

createTodayDeals(); 