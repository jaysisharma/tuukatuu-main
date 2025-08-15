const mongoose = require('mongoose');
const User = require('../src/models/User');
const Product = require('../src/models/Product');
const Category = require('../src/models/Category');
const Banner = require('../src/models/Banner');
require('dotenv').config({ path: require('path').resolve(__dirname, '../.env') });

// Connect to MongoDB
const connectDB = require('../src/config/db');

// Sample store vendors
const storeVendors = [
  {
    name: 'SuperMart Express',
    email: 'supermart@example.com',
    phone: '+977-1-4444444',
    password: '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', // password
    role: 'vendor',
    vendorType: 'store',
    storeName: 'SuperMart Express',
    storeDescription: 'Your one-stop shop for all daily essentials and groceries',
    storeImage: 'https://images.unsplash.com/photo-1563013544-824ae1b704d3?w=400',
    storeTags: ['grocery', 'daily-essentials', 'convenience'],
    storeRating: 4.5,
    storeReviews: 128,
    storeAddress: 'Thamel, Kathmandu',
    storeCoordinates: {
      type: 'Point',
      coordinates: [85.3170, 27.7172]
    },
    isFeatured: true,
    isActive: true
  },
  {
    name: 'Fresh Grocery Hub',
    email: 'freshgrocery@example.com',
    phone: '+977-1-5555555',
    password: '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
    role: 'vendor',
    vendorType: 'store',
    storeName: 'Fresh Grocery Hub',
    storeDescription: 'Fresh and organic groceries delivered to your doorstep',
    storeImage: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=400',
    storeTags: ['organic', 'fresh', 'healthy'],
    storeRating: 4.7,
    storeReviews: 95,
    storeAddress: 'Baneshwor, Kathmandu',
    storeCoordinates: {
      type: 'Point',
      coordinates: [85.3450, 27.7172]
    },
    isFeatured: true,
    isActive: true
  },
  {
    name: 'Quick Mart Plus',
    email: 'quickmart@example.com',
    phone: '+977-1-6666666',
    password: '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
    role: 'vendor',
    vendorType: 'store',
    storeName: 'Quick Mart Plus',
    storeDescription: 'Fast delivery of household items and snacks',
    storeImage: 'https://images.unsplash.com/photo-1563013544-824ae1b704d3?w=400',
    storeTags: ['household', 'snacks', 'quick-delivery'],
    storeRating: 4.3,
    storeReviews: 67,
    storeAddress: 'Pulchowk, Lalitpur',
    storeCoordinates: {
      type: 'Point',
      coordinates: [85.3450, 27.6800]
    },
    isFeatured: false,
    isActive: true
  }
];

// Sample categories
const categories = [
  {
    name: 'Dairy & Eggs',
    displayName: 'Dairy & Eggs',
    description: 'Fresh dairy products and eggs',
    color: 'blue',
    isActive: true,
    isFeatured: true,
    sortOrder: 1
  },
  {
    name: 'Fruits & Vegetables',
    displayName: 'Fruits & Vegetables',
    description: 'Fresh fruits and vegetables',
    color: 'green',
    isActive: true,
    isFeatured: true,
    sortOrder: 2
  },
  {
    name: 'Beverages',
    displayName: 'Beverages',
    description: 'Soft drinks, juices, and hot beverages',
    color: 'orange',
    isActive: true,
    isFeatured: true,
    sortOrder: 3
  },
  {
    name: 'Snacks',
    displayName: 'Snacks',
    description: 'Chips, cookies, and other snacks',
    color: 'red',
    isActive: true,
    isFeatured: true,
    sortOrder: 4
  },
  {
    name: 'Household',
    displayName: 'Household',
    description: 'Cleaning supplies and household items',
    color: 'purple',
    isActive: true,
    isFeatured: false,
    sortOrder: 5
  }
];

// Sample products
const products = [
  // Dairy & Eggs
  {
    name: 'Fresh Milk 1L',
    price: 120,
    imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=400',
    category: 'Dairy & Eggs',
    rating: 4.5,
    reviews: 45,
    isAvailable: true,
    dailyEssential: true,
    isFeaturedDailyEssential: true,
    vendorType: 'store',
    unit: '1 Liter',
    stock: 50,
    isFeatured: true,
    isPopular: true
  },
  {
    name: 'Farm Fresh Eggs (12)',
    price: 180,
    imageUrl: 'https://images.unsplash.com/photo-1506976785307-8732e854ad0f?w=400',
    category: 'Dairy & Eggs',
    rating: 4.7,
    reviews: 32,
    isAvailable: true,
    dailyEssential: true,
    vendorType: 'store',
    unit: '12 pieces',
    stock: 30,
    isFeatured: false,
    isPopular: true
  },
  // Fruits & Vegetables
  {
    name: 'Organic Bananas (1kg)',
    price: 140,
    imageUrl: 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400',
    category: 'Fruits & Vegetables',
    rating: 4.6,
    reviews: 28,
    isAvailable: true,
    dailyEssential: true,
    vendorType: 'store',
    unit: '1 kg',
    stock: 25,
    isFeatured: true,
    isOrganic: true
  },
  {
    name: 'Fresh Tomatoes (500g)',
    price: 80,
    imageUrl: 'https://images.unsplash.com/photo-1546094096-0df4bcaaa337?w=400',
    category: 'Fruits & Vegetables',
    rating: 4.4,
    reviews: 19,
    isAvailable: true,
    dailyEssential: true,
    vendorType: 'store',
    unit: '500g',
    stock: 40,
    isFeatured: false
  },
  // Beverages
  {
    name: 'Orange Juice 1L',
    price: 160,
    imageUrl: 'https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?w=400',
    category: 'Beverages',
    rating: 4.3,
    reviews: 23,
    isAvailable: true,
    dailyEssential: false,
    vendorType: 'store',
    unit: '1 Liter',
    stock: 35,
    isFeatured: false,
    isPopular: true
  },
  {
    name: 'Green Tea (20 bags)',
    price: 120,
    imageUrl: 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=400',
    category: 'Beverages',
    rating: 4.8,
    reviews: 41,
    isAvailable: true,
    dailyEssential: false,
    vendorType: 'store',
    unit: '20 bags',
    stock: 60,
    isFeatured: true,
    isBestSeller: true
  },
  // Snacks
  {
    name: 'Potato Chips Classic',
    price: 45,
    imageUrl: 'https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=400',
    category: 'Snacks',
    rating: 4.2,
    reviews: 67,
    isAvailable: true,
    dailyEssential: false,
    vendorType: 'store',
    unit: '100g',
    stock: 80,
    isFeatured: false,
    isPopular: true
  },
  {
    name: 'Chocolate Cookies',
    price: 85,
    imageUrl: 'https://images.unsplash.com/photo-1499636136210-6f4ee915583e?w=400',
    category: 'Snacks',
    rating: 4.6,
    reviews: 34,
    isAvailable: true,
    dailyEssential: false,
    vendorType: 'store',
    unit: '200g',
    stock: 45,
    isFeatured: true,
    isNewArrival: true
  },
  // Household
  {
    name: 'Dish Soap 500ml',
    price: 95,
    imageUrl: 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=400',
    category: 'Household',
    rating: 4.4,
    reviews: 18,
    isAvailable: true,
    dailyEssential: false,
    vendorType: 'store',
    unit: '500ml',
    stock: 30,
    isFeatured: false
  },
  {
    name: 'Paper Towels (6 rolls)',
    price: 150,
    imageUrl: 'https://images.unsplash.com/photo-1582735689369-4fe89db7114c?w=400',
    category: 'Household',
    rating: 4.1,
    reviews: 12,
    isAvailable: true,
    dailyEssential: false,
    vendorType: 'store',
    unit: '6 rolls',
    stock: 25,
    isFeatured: false
  }
];

// Sample banners
const banners = [
  {
    title: 'Fresh Groceries',
    subtitle: 'Get fresh groceries delivered in 30 minutes',
    imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800',
    bannerType: 'mart',
    isActive: true,
    startDate: new Date(),
    endDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // 30 days from now
    sortOrder: 1,
    priority: 1
  },
  {
    title: 'Daily Essentials',
    subtitle: 'All your daily needs in one place',
    imageUrl: 'https://images.unsplash.com/photo-1563013544-824ae1b704d3?w=800',
    bannerType: 'mart',
    isActive: true,
    startDate: new Date(),
    endDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
    sortOrder: 2,
    priority: 2
  }
];

async function seedMart() {
  try {
    await connectDB();
    console.log('✅ Connected to MongoDB');

    // Clear existing data
    await User.deleteMany({ role: 'vendor', vendorType: 'store' });
    await Product.deleteMany({ vendorType: 'store' });
    await Category.deleteMany({});
    await Banner.deleteMany({ bannerType: 'mart' });
    console.log('✅ Cleared existing mart data');

    // Create categories
    const createdCategories = await Category.insertMany(categories);
    console.log(`✅ Created ${createdCategories.length} categories`);

    // Create store vendors
    const createdVendors = await User.insertMany(storeVendors);
    console.log(`✅ Created ${createdVendors.length} store vendors`);

    // Create products with vendor IDs
    const productsWithVendors = products.map((product, index) => ({
      ...product,
      vendorId: createdVendors[index % createdVendors.length]._id
    }));

    const createdProducts = await Product.insertMany(productsWithVendors);
    console.log(`✅ Created ${createdProducts.length} products`);

    // Create banners
    const createdBanners = await Banner.insertMany(banners);
    console.log(`✅ Created ${createdBanners.length} banners`);

    console.log('🎉 Mart seeding completed successfully!');
    console.log(`📊 Summary:`);
    console.log(`   - Categories: ${createdCategories.length}`);
    console.log(`   - Store Vendors: ${createdVendors.length}`);
    console.log(`   - Products: ${createdProducts.length}`);
    console.log(`   - Banners: ${createdBanners.length}`);

    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding mart data:', error);
    process.exit(1);
  }
}

// Run the seed function
seedMart();
