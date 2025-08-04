const mongoose = require('mongoose');
const Product = require('./src/models/Product');
const TMartBanner = require('./src/models/TMartBanner');
const TMartDeal = require('./src/models/TMartDeal');

// Connect to MongoDB
mongoose.connect('mongodb://localhost:27017/first_db2', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

const tmartProducts = [
  // Fruits & Vegetables
  {
    name: 'Fresh Apples',
    price: 120,
    imageUrl: 'https://images.unsplash.com/photo-1567306226416-28f0efdc88ce?w=400&h=400&fit=crop',
    category: 'Fruits & Vegetables',
    description: 'Fresh and juicy apples from local farms',
    unit: '1 kg',
    deliveryTime: '15 mins',
    isAvailable: true,
    deliveryFee: 20,
    dailyEssential: true,
    isPopular: true,
    isFeatured: true,
    rating: 4.5,
    reviews: 128,
    stock: 50,
    vendorId: null,
    vendorType: 'store',
    tags: ['fresh', 'organic', 'local']
  },
  {
    name: 'Organic Tomatoes',
    price: 80,
    imageUrl: 'https://images.unsplash.com/photo-1546094096-0dfbcaaa337?w=400&h=400&fit=crop',
    category: 'Fruits & Vegetables',
    description: 'Organic tomatoes rich in flavor',
    unit: '500g',
    deliveryTime: '15 mins',
    isAvailable: true,
    deliveryFee: 20,
    dailyEssential: true,
    isPopular: true,
    rating: 4.3,
    reviews: 95,
    stock: 30,
    vendorId: null,
    vendorType: 'store',
    tags: ['organic', 'fresh', 'healthy']
  },
  {
    name: 'Fresh Bananas',
    price: 60,
    imageUrl: 'https://images.unsplash.com/photo-1528825871115-3581a5387919?w=400&h=400&fit=crop',
    category: 'Fruits & Vegetables',
    description: 'Sweet and nutritious bananas',
    unit: '1 dozen',
    deliveryTime: '15 mins',
    isAvailable: true,
    deliveryFee: 20,
    dailyEssential: true,
    isPopular: true,
    rating: 4.2,
    reviews: 156,
    stock: 40,
    vendorId: null,
    vendorType: 'store',
    tags: ['sweet', 'nutritious', 'energy']
  },
  {
    name: 'Fresh Onions',
    price: 40,
    imageUrl: 'https://images.unsplash.com/photo-1518977676601-b53f82aba654?w=400&h=400&fit=crop',
    category: 'Fruits & Vegetables',
    description: 'Fresh onions for cooking',
    unit: '1 kg',
    deliveryTime: '15 mins',
    isAvailable: true,
    deliveryFee: 20,
    dailyEssential: true,
    rating: 4.1,
    reviews: 89,
    stock: 25,
    vendorId: null,
    vendorType: 'store',
    tags: ['cooking', 'essential', 'fresh']
  },

  // Dairy & Eggs
  {
    name: 'Fresh Milk',
    price: 65,
    imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=400&h=400&fit=crop',
    category: 'Dairy & Eggs',
    description: 'Pure and fresh milk from local farms',
    unit: '1L',
    deliveryTime: '15 mins',
    isAvailable: true,
    deliveryFee: 20,
    dailyEssential: true,
    isPopular: true,
    isFeatured: true,
    rating: 4.6,
    reviews: 234,
    stock: 35,
    vendorId: null,
    vendorType: 'store',
    tags: ['fresh', 'pure', 'nutritious']
  },
  {
    name: 'Fresh Eggs',
    price: 120,
    imageUrl: 'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=400&h=400&fit=crop',
    category: 'Dairy & Eggs',
    description: 'Farm fresh eggs',
    unit: '1 dozen',
    deliveryTime: '15 mins',
    isAvailable: true,
    deliveryFee: 20,
    dailyEssential: true,
    isPopular: true,
    rating: 4.4,
    reviews: 167,
    stock: 20,
    vendorId: null,
    vendorType: 'store',
    tags: ['farm fresh', 'protein', 'essential']
  },
  {
    name: 'Butter',
    price: 85,
    imageUrl: 'https://images.unsplash.com/photo-1586444248902-2f64eddc13df?w=400&h=400&fit=crop',
    category: 'Dairy & Eggs',
    description: 'Creamy butter for cooking and baking',
    unit: '250g',
    deliveryTime: '15 mins',
    isAvailable: true,
    deliveryFee: 20,
    dailyEssential: true,
    rating: 4.3,
    reviews: 78,
    stock: 15,
    vendorId: null,
    vendorType: 'store',
    tags: ['creamy', 'cooking', 'baking']
  },

  // Bakery
  {
    name: 'Fresh Bread',
    price: 45,
    imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&h=400&fit=crop',
    category: 'Bakery',
    description: 'Freshly baked bread',
    unit: '1 loaf',
    deliveryTime: '15 mins',
    isAvailable: true,
    deliveryFee: 20,
    dailyEssential: true,
    isPopular: true,
    rating: 4.5,
    reviews: 189,
    stock: 30,
    vendorId: null,
    vendorType: 'store',
    tags: ['fresh', 'baked', 'daily']
  },
  {
    name: 'Croissants',
    price: 35,
    imageUrl: 'https://images.unsplash.com/photo-1555507036-ab1f40388010?w=400&h=400&fit=crop',
    category: 'Bakery',
    description: 'Buttery and flaky croissants',
    unit: '2 pieces',
    deliveryTime: '15 mins',
    isAvailable: true,
    deliveryFee: 20,
    isPopular: true,
    rating: 4.7,
    reviews: 145,
    stock: 25,
    vendorId: null,
    vendorType: 'store',
    tags: ['buttery', 'flaky', 'breakfast']
  },

  // Beverages
  {
    name: 'Orange Juice',
    price: 90,
    imageUrl: 'https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?w=400&h=400&fit=crop',
    category: 'Beverages',
    description: 'Fresh orange juice',
    unit: '1L',
    deliveryTime: '15 mins',
    isAvailable: true,
    deliveryFee: 20,
    isPopular: true,
    rating: 4.4,
    reviews: 112,
    stock: 20,
    vendorId: null,
    vendorType: 'store',
    tags: ['fresh', 'vitamin c', 'healthy']
  },
  {
    name: 'Coffee Beans',
    price: 250,
    imageUrl: 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=400&h=400&fit=crop',
    category: 'Beverages',
    description: 'Premium coffee beans',
    unit: '500g',
    deliveryTime: '15 mins',
    isAvailable: true,
    deliveryFee: 20,
    isFeatured: true,
    rating: 4.6,
    reviews: 89,
    stock: 15,
    vendorId: null,
    vendorType: 'store',
    tags: ['premium', 'coffee', 'beans']
  },

  // Snacks
  {
    name: 'Potato Chips',
    price: 30,
    imageUrl: 'https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=400&h=400&fit=crop',
    category: 'Snacks',
    description: 'Crispy potato chips',
    unit: '100g',
    deliveryTime: '15 mins',
    isAvailable: true,
    deliveryFee: 20,
    isPopular: true,
    rating: 4.2,
    reviews: 234,
    stock: 50,
    vendorId: null,
    vendorType: 'store',
    tags: ['crispy', 'snack', 'chips']
  },
  {
    name: 'Chocolate Cookies',
    price: 55,
    imageUrl: 'https://images.unsplash.com/photo-1499636136210-6f4ee915583e?w=400&h=400&fit=crop',
    category: 'Snacks',
    description: 'Delicious chocolate cookies',
    unit: '200g',
    deliveryTime: '15 mins',
    isAvailable: true,
    deliveryFee: 20,
    isPopular: true,
    rating: 4.5,
    reviews: 167,
    stock: 30,
    vendorId: null,
    vendorType: 'store',
    tags: ['chocolate', 'cookies', 'sweet']
  }
];

const tmartBanners = [
  {
    title: 'Fresh Groceries',
    subtitle: 'Get fresh groceries delivered in 15 minutes',
    imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=400&h=200&fit=crop',
    isActive: true,
    startDate: new Date(),
    endDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // 30 days from now
    sortOrder: 1
  },
  {
    title: 'Fast Delivery',
    subtitle: 'Express delivery to your doorstep',
    imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=400&h=200&fit=crop',
    isActive: true,
    startDate: new Date(),
    endDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // 30 days from now
    sortOrder: 2
  }
];

const tmartDeals = [
  {
    name: '50% Off on Fruits',
    description: 'Get fresh fruits at half price',
    shortDescription: 'On selected fruits',
    imageUrl: 'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=300&h=150&fit=crop',
    dealType: 'percentage',
    discountValue: 50,
    applicableCategories: ['Fruits & Vegetables'],
    isActive: true,
    startDate: new Date(),
    endDate: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 days from now
    isFeatured: true,
    usageLimit: 1000,
    userUsageLimit: 2,
    backgroundColor: '#4CAF50',
    textColor: '#FFFFFF',
    buttonText: 'Shop Fruits',
    tags: ['fruits', 'discount', 'fresh']
  },
  {
    name: 'Buy 1 Get 1 Free',
    description: 'Buy any dairy product and get one free',
    shortDescription: 'On dairy products',
    imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=300&h=150&fit=crop',
    dealType: 'buy_one_get_one',
    applicableCategories: ['Dairy & Eggs'],
    isActive: true,
    startDate: new Date(),
    endDate: new Date(Date.now() + 5 * 24 * 60 * 60 * 1000), // 5 days from now
    isFeatured: true,
    usageLimit: 500,
    userUsageLimit: 1,
    backgroundColor: '#FF9800',
    textColor: '#FFFFFF',
    buttonText: 'Shop Dairy',
    tags: ['dairy', 'bogo', 'fresh']
  }
];

async function seedTMartData() {
  try {
    console.log('🌱 Seeding T-Mart data...');

    // Clear existing T-Mart data
    await Product.deleteMany({ vendorType: 'store' });
    await TMartBanner.deleteMany({});
    await TMartDeal.deleteMany({});

    console.log('✅ Cleared existing T-Mart data');

    // Insert T-Mart products
    const products = await Product.insertMany(tmartProducts);
    console.log(`✅ Inserted ${products.length} T-Mart products`);

    // Insert T-Mart banners
    const banners = await TMartBanner.insertMany(tmartBanners);
    console.log(`✅ Inserted ${banners.length} T-Mart banners`);

    // Insert T-Mart deals
    const deals = await TMartDeal.insertMany(tmartDeals);
    console.log(`✅ Inserted ${deals.length} T-Mart deals`);

    console.log('🎉 T-Mart data seeding completed successfully!');
    
    // Display summary
    console.log('\n📊 Summary:');
    console.log(`- Products: ${products.length}`);
    console.log(`- Banners: ${banners.length}`);
    console.log(`- Deals: ${deals.length}`);

  } catch (error) {
    console.error('❌ Error seeding T-Mart data:', error);
  } finally {
    mongoose.connection.close();
    console.log('🔌 Database connection closed');
  }
}

// Run the seeding
seedTMartData(); 