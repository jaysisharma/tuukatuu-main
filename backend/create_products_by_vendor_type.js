const mongoose = require('mongoose');
require('dotenv').config();

// Import models
const User = require('./src/models/User');
const Product = require('./src/models/Product');

mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/first_db2', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

const createProductsByVendorType = async () => {
  try {
    console.log('🛍️ Creating products for different vendor types...');

    // Get vendors by type
    const restaurants = await User.find({ role: 'vendor', vendorType: 'restaurant' });
    const stores = await User.find({ role: 'vendor', vendorType: 'store' });

    console.log(`Found ${restaurants.length} restaurants and ${stores.length} stores`);

    // Restaurant products data
    const restaurantProductsData = [
      // Chinese Restaurant Products
      {
        name: 'Kung Pao Chicken',
        price: 450,
        imageUrl: 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400&h=400&fit=crop',
        category: 'Chinese',
        description: 'Spicy diced chicken with peanuts and vegetables',
        unit: '1 serving',
        deliveryTime: '25 mins',
        isAvailable: true,
        deliveryFee: 30,
        stock: 100,
        vendorType: 'restaurant',
        vendorSubType: 'chinese',
        isVegetarian: false,
        rating: 4.6,
        reviews: 120,
        isPopular: true,
        tags: ['Spicy', 'Chicken', 'Chinese']
      },
      {
        name: 'Sweet and Sour Pork',
        price: 380,
        imageUrl: 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400&h=400&fit=crop',
        category: 'Chinese',
        description: 'Crispy pork in tangy sweet and sour sauce',
        unit: '1 serving',
        deliveryTime: '25 mins',
        isAvailable: true,
        deliveryFee: 30,
        stock: 80,
        vendorType: 'restaurant',
        vendorSubType: 'chinese',
        isVegetarian: false,
        rating: 4.4,
        reviews: 95,
        isPopular: true,
        tags: ['Pork', 'Sweet', 'Chinese']
      },
      {
        name: 'Vegetable Fried Rice',
        price: 280,
        imageUrl: 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=400&h=400&fit=crop',
        category: 'Chinese',
        description: 'Fresh vegetables with fragrant fried rice',
        unit: '1 serving',
        deliveryTime: '20 mins',
        isAvailable: true,
        deliveryFee: 30,
        stock: 120,
        vendorType: 'restaurant',
        vendorSubType: 'chinese',
        isVegetarian: true,
        rating: 4.3,
        reviews: 85,
        tags: ['Vegetarian', 'Rice', 'Chinese']
      },

      // Italian Restaurant Products
      {
        name: 'Margherita Pizza',
        price: 550,
        imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=400&h=400&fit=crop',
        category: 'Italian',
        description: 'Classic pizza with tomato sauce, mozzarella, and basil',
        unit: '1 pizza (12 inch)',
        deliveryTime: '30 mins',
        isAvailable: true,
        deliveryFee: 35,
        stock: 50,
        vendorType: 'restaurant',
        vendorSubType: 'italian',
        isVegetarian: true,
        rating: 4.7,
        reviews: 150,
        isPopular: true,
        isFeatured: true,
        tags: ['Pizza', 'Vegetarian', 'Italian']
      },
      {
        name: 'Spaghetti Carbonara',
        price: 420,
        imageUrl: 'https://images.unsplash.com/photo-1621996346565-e3dbc353d2e5?w=400&h=400&fit=crop',
        category: 'Italian',
        description: 'Creamy pasta with eggs, cheese, and pancetta',
        unit: '1 serving',
        deliveryTime: '25 mins',
        isAvailable: true,
        deliveryFee: 35,
        stock: 30,
        vendorType: 'restaurant',
        vendorSubType: 'italian',
        isVegetarian: false,
        rating: 4.5,
        reviews: 110,
        isPopular: true,
        tags: ['Pasta', 'Creamy', 'Italian']
      },
      {
        name: 'Tiramisu',
        price: 180,
        imageUrl: 'https://images.unsplash.com/photo-1571877227200-a0d98ea60720?w=400&h=400&fit=crop',
        category: 'Desserts',
        description: 'Classic Italian dessert with coffee and mascarpone',
        unit: '1 piece',
        deliveryTime: '30 mins',
        isAvailable: true,
        deliveryFee: 35,
        stock: 20,
        vendorType: 'restaurant',
        vendorSubType: 'italian',
        isVegetarian: true,
        rating: 4.8,
        reviews: 75,
        tags: ['Dessert', 'Coffee', 'Italian']
      },

      // Fast Food Products
      {
        name: 'Classic Burger',
        price: 320,
        imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=400&h=400&fit=crop',
        category: 'Fast Food',
        description: 'Juicy beef patty with fresh vegetables and special sauce',
        unit: '1 burger',
        deliveryTime: '15 mins',
        isAvailable: true,
        deliveryFee: 25,
        stock: 100,
        vendorType: 'restaurant',
        vendorSubType: 'fast_food',
        isVegetarian: false,
        rating: 4.2,
        reviews: 200,
        isPopular: true,
        tags: ['Burger', 'Beef', 'Fast Food']
      },
      {
        name: 'Chicken Wings',
        price: 280,
        imageUrl: 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400&h=400&fit=crop',
        category: 'Fast Food',
        description: 'Crispy wings with your choice of sauce',
        unit: '6 pieces',
        deliveryTime: '15 mins',
        isAvailable: true,
        deliveryFee: 25,
        stock: 80,
        vendorType: 'restaurant',
        vendorSubType: 'fast_food',
        isVegetarian: false,
        rating: 4.4,
        reviews: 180,
        isPopular: true,
        tags: ['Chicken', 'Wings', 'Fast Food']
      }
    ];

    // Store products data
    const storeProductsData = [
      // Grocery Store Products
      {
        name: 'Fresh Bananas',
        price: 80,
        imageUrl: 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=400&h=400&fit=crop',
        category: 'Fruits',
        description: 'Fresh organic bananas from local farms',
        unit: '1 kg',
        deliveryTime: '20 mins',
        isAvailable: true,
        deliveryFee: 20,
        stock: 200,
        vendorType: 'store',
        vendorSubType: 'grocery',
        isVegetarian: true,
        isOrganic: true,
        rating: 4.6,
        reviews: 300,
        isPopular: true,
        isFeatured: true,
        tags: ['Fruits', 'Organic', 'Fresh']
      },
      {
        name: 'Fresh Milk',
        price: 120,
        imageUrl: 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400&h=400&fit=crop',
        category: 'Dairy',
        description: 'Pure cow milk from local dairy farms',
        unit: '1 liter',
        deliveryTime: '20 mins',
        isAvailable: true,
        deliveryFee: 20,
        stock: 150,
        vendorType: 'store',
        vendorSubType: 'grocery',
        isVegetarian: true,
        rating: 4.5,
        reviews: 250,
        isPopular: true,
        dailyEssential: true,
        tags: ['Dairy', 'Fresh', 'Essential']
      },
      {
        name: 'Whole Wheat Bread',
        price: 45,
        imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&h=400&fit=crop',
        category: 'Bakery',
        description: 'Fresh whole wheat bread baked daily',
        unit: '1 loaf',
        deliveryTime: '20 mins',
        isAvailable: true,
        deliveryFee: 20,
        stock: 20,
        vendorType: 'store',
        vendorSubType: 'grocery',
        isVegetarian: true,
        rating: 4.3,
        reviews: 180,
        dailyEssential: true,
        tags: ['Bakery', 'Bread', 'Healthy']
      },

      // Pharmacy Products
      {
        name: 'Paracetamol 500mg',
        price: 25,
        imageUrl: 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=400&h=400&fit=crop',
        category: 'Medicine',
        description: 'Pain relief tablets for fever and headache',
        unit: '10 tablets',
        deliveryTime: '25 mins',
        isAvailable: true,
        deliveryFee: 25,
        stock: 20,
        vendorType: 'store',
        vendorSubType: 'pharmacy',
        rating: 4.4,
        reviews: 120,
        isPopular: true,
        tags: ['Medicine', 'Pain Relief', 'Fever']
      },
      {
        name: 'Vitamin C 1000mg',
        price: 180,
        imageUrl: 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=400&h=400&fit=crop',
        category: 'Supplements',
        description: 'Immune system support with high-dose vitamin C',
        unit: '30 tablets',
        deliveryTime: '25 mins',
        isAvailable: true,
        deliveryFee: 25,
        stock: 20,
        vendorType: 'store',
        vendorSubType: 'pharmacy',
        rating: 4.6,
        reviews: 95,
        isPopular: true,
        tags: ['Vitamins', 'Immunity', 'Health']
      },
      {
        name: 'Toothpaste',
        price: 85,
        imageUrl: 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=400&h=400&fit=crop',
        category: 'Personal Care',
        description: 'Fresh mint toothpaste for daily oral hygiene',
        unit: '100g',
        deliveryTime: '25 mins',
        isAvailable: true,
        deliveryFee: 25,
        stock: 20,
        vendorType: 'store',
        vendorSubType: 'pharmacy',
        rating: 4.2,
        reviews: 150,
        dailyEssential: true,
        tags: ['Personal Care', 'Oral Hygiene', 'Fresh']
      },

      // Electronics Store Products
      {
        name: 'USB-C Cable',
        price: 350,
        imageUrl: 'https://images.unsplash.com/photo-1468495244123-6c6c332eeece?w=400&h=400&fit=crop',
        category: 'Electronics',
        description: 'High-quality USB-C cable for fast charging',
        unit: '1 piece',
        deliveryTime: '30 mins',
        stock: 20,
        isAvailable: true,
        deliveryFee: 30,
        vendorType: 'store',
        vendorSubType: 'electronics',
        rating: 4.3,
        reviews: 85,
        isPopular: true,
        tags: ['Electronics', 'Cable', 'Charging']
      },
      {
        name: 'Wireless Earbuds',
        price: 2500,
        imageUrl: 'https://images.unsplash.com/photo-1468495244123-6c6c332eeece?w=400&h=400&fit=crop',
        category: 'Electronics',
        description: 'Bluetooth earbuds with noise cancellation',
        unit: '1 pair',
        deliveryTime: '30 mins',
        isAvailable: true,
        deliveryFee: 30,
        stock: 15,
        vendorType: 'store',
        vendorSubType: 'electronics',
        rating: 4.5,
        reviews: 65,
        isFeatured: true,
        tags: ['Electronics', 'Audio', 'Wireless']
      }
    ];

    // Assign products to vendors
    const allProducts = [...restaurantProductsData, ...storeProductsData];
    
    for (const productData of allProducts) {
      // Find appropriate vendor based on type and subtype
      let vendor;
      
      if (productData.vendorType === 'restaurant') {
        vendor = restaurants.find(r => r.vendorSubType === productData.vendorSubType);
      } else {
        vendor = stores.find(s => s.vendorSubType === productData.vendorSubType);
      }

      if (!vendor) {
        console.log(`⚠️ No vendor found for ${productData.vendorSubType}, skipping ${productData.name}`);
        continue;
      }

      // Check if product already exists
      const existingProduct = await Product.findOne({
        name: productData.name,
        vendorId: vendor._id
      });

      if (existingProduct) {
        console.log(`✅ Product already exists: ${productData.name}`);
        continue;
      }

      // Create new product
      const product = new Product({
        ...productData,
        vendorId: vendor._id
      });

      await product.save();
      console.log(`✅ Created product: ${productData.name} for ${vendor.storeName}`);
    }

    // Display summary
    const totalProducts = await Product.countDocuments();
    const restaurantProductsCount = await Product.countDocuments({ vendorType: 'restaurant' });
    const storeProductsCount = await Product.countDocuments({ vendorType: 'store' });

    console.log('\n🎉 Products created successfully!');
    console.log('\nSummary:');
    console.log(`- Total products: ${totalProducts}`);
    console.log(`- Restaurant products: ${restaurantProductsCount}`);
    console.log(`- Store products: ${storeProductsCount}`);

    // Show some popular products
    const popularProducts = await Product.find({ isPopular: true })
      .populate('vendorId', 'storeName vendorType vendorSubType')
      .limit(5);

    console.log('\n🏆 Popular products:');
    popularProducts.forEach((product, index) => {
      console.log(`${index + 1}. ${product.name} - ${product.vendorId.storeName} (${product.vendorId.vendorSubType})`);
    });

    process.exit(0);
  } catch (error) {
    console.error('❌ Error creating products:', error);
    process.exit(1);
  }
};

createProductsByVendorType(); 