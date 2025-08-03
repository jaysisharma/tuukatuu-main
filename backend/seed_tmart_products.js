const mongoose = require('mongoose');
const TMartProduct = require('./src/models/TMartProduct');
const TMartCategory = require('./src/models/TMartCategory');
const User = require('./src/models/User');

// Connect to MongoDB
mongoose.connect('mongodb://localhost:27017/first_db', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

const seedTMartProducts = async () => {
  try {
    console.log('🌱 Starting T-Mart products seeding...');

    // First, ensure categories exist
    await TMartCategory.seedTMartCategories();
    console.log('✅ Categories seeded');

    // Get some vendor IDs (assuming you have vendors in the database)
    const vendors = await User.find({ role: 'vendor' }).limit(5);
    if (vendors.length === 0) {
      console.log('⚠️ No vendors found. Creating a test vendor...');
      const testVendor = new User({
        name: 'Test T-Mart Vendor',
        email: 'tmart@test.com',
        password: 'password123',
        role: 'vendor',
        storeName: 'T-Mart Store',
        storeDescription: 'Premium grocery store',
        storeAddress: '123 Main St, City',
      });
      await testVendor.save();
      vendors.push(testVendor);
    }

    // Clear existing products
    await TMartProduct.deleteMany({});
    console.log('🗑️ Cleared existing products');

    // Get categories for reference
    const categories = await TMartCategory.find({ isActive: true });

    const products = [
      // Dairy & Eggs
      {
        name: 'Fresh Whole Milk',
        price: 45.0,
        originalPrice: 55.0,
        imageUrl: 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400&h=400&fit=crop',
        category: 'Dairy & Eggs',
        subCategory: 'Milk',
        brand: 'Farm Fresh',
        unit: '1L',
        weight: 1000,
        rating: 4.5,
        reviews: 120,
        isAvailable: true,
        stock: 50,
        isVegetarian: true,
        isOrganic: false,
        description: 'Fresh whole milk from local farms',
        ingredients: ['Milk'],
        nutritionalInfo: {
          calories: 42,
          protein: 3.4,
          carbs: 5.0,
          fat: 1.0,
          fiber: 0,
        },
        images: [
          'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400&h=400&fit=crop'
        ],
        discount: 18,
        isFeatured: true,
        isBestSeller: true,
        tags: ['milk', 'dairy', 'fresh', 'organic'],
        vendorId: vendors[0]._id,
      },
      {
        name: 'Farm Fresh Eggs',
        price: 60.0,
        originalPrice: 75.0,
        imageUrl: 'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=400&h=400&fit=crop',
        category: 'Dairy & Eggs',
        subCategory: 'Eggs',
        brand: 'Farm Fresh',
        unit: '12 pcs',
        weight: 600,
        rating: 4.7,
        reviews: 89,
        isAvailable: true,
        stock: 30,
        isVegetarian: true,
        isOrganic: true,
        description: 'Fresh farm eggs from free-range chickens',
        ingredients: ['Eggs'],
        nutritionalInfo: {
          calories: 155,
          protein: 12.6,
          carbs: 1.1,
          fat: 10.6,
          fiber: 0,
        },
        images: [
          'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=400&h=400&fit=crop'
        ],
        discount: 20,
        isFeatured: true,
        isBestSeller: true,
        tags: ['eggs', 'farm fresh', 'organic', 'free range'],
        vendorId: vendors[0]._id,
      },
      {
        name: 'Cheddar Cheese',
        price: 200.0,
        originalPrice: 250.0,
        imageUrl: 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400&h=400&fit=crop',
        category: 'Dairy & Eggs',
        subCategory: 'Cheese',
        brand: 'Dairy Delight',
        unit: '200g',
        weight: 200,
        rating: 4.4,
        reviews: 67,
        isAvailable: true,
        stock: 25,
        isVegetarian: true,
        isOrganic: false,
        description: 'Aged cheddar cheese with rich flavor',
        ingredients: ['Milk', 'Salt', 'Enzymes'],
        nutritionalInfo: {
          calories: 402,
          protein: 25.0,
          carbs: 1.3,
          fat: 33.0,
          fiber: 0,
        },
        images: [
          'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400&h=400&fit=crop'
        ],
        discount: 20,
        isFeatured: false,
        isBestSeller: true,
        tags: ['cheese', 'cheddar', 'dairy', 'aged'],
        vendorId: vendors[0]._id,
      },

      // Fruits & Vegetables
      {
        name: 'Fresh Bananas',
        price: 40.0,
        originalPrice: 50.0,
        imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=400&fit=crop',
        category: 'Fruits & Vegetables',
        subCategory: 'Fruits',
        brand: 'Nature Fresh',
        unit: '1kg',
        weight: 1000,
        rating: 4.5,
        reviews: 156,
        isAvailable: true,
        stock: 40,
        isVegetarian: true,
        isVegan: true,
        isOrganic: true,
        description: 'Sweet and ripe bananas',
        ingredients: ['Bananas'],
        nutritionalInfo: {
          calories: 89,
          protein: 1.1,
          carbs: 23.0,
          fat: 0.3,
          fiber: 2.6,
        },
        images: [
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=400&fit=crop'
        ],
        discount: 20,
        isFeatured: true,
        isBestSeller: true,
        tags: ['bananas', 'fruits', 'organic', 'fresh'],
        vendorId: vendors[0]._id,
      },
      {
        name: 'Fresh Tomatoes',
        price: 30.0,
        originalPrice: 40.0,
        imageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400&h=400&fit=crop',
        category: 'Fruits & Vegetables',
        subCategory: 'Vegetables',
        brand: 'Garden Fresh',
        unit: '1kg',
        weight: 1000,
        rating: 4.2,
        reviews: 98,
        isAvailable: true,
        stock: 35,
        isVegetarian: true,
        isVegan: true,
        isOrganic: false,
        description: 'Fresh red tomatoes',
        ingredients: ['Tomatoes'],
        nutritionalInfo: {
          calories: 18,
          protein: 0.9,
          carbs: 3.9,
          fat: 0.2,
          fiber: 1.2,
        },
        images: [
          'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400&h=400&fit=crop'
        ],
        discount: 25,
        isFeatured: true,
        isBestSeller: false,
        tags: ['tomatoes', 'vegetables', 'fresh', 'red'],
        vendorId: vendors[0]._id,
      },

      // Bakery
      {
        name: 'Whole Wheat Bread',
        price: 35.0,
        originalPrice: 45.0,
        imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&h=400&fit=crop',
        category: 'Bakery',
        subCategory: 'Bread',
        brand: 'Bakery Fresh',
        unit: '400g',
        weight: 400,
        rating: 4.3,
        reviews: 78,
        isAvailable: true,
        stock: 20,
        isVegetarian: true,
        isVegan: false,
        isOrganic: false,
        description: 'Fresh whole wheat bread',
        ingredients: ['Whole Wheat Flour', 'Water', 'Yeast', 'Salt'],
        nutritionalInfo: {
          calories: 247,
          protein: 13.0,
          carbs: 41.0,
          fat: 4.0,
          fiber: 7.0,
        },
        images: [
          'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&h=400&fit=crop'
        ],
        discount: 22,
        isFeatured: true,
        isBestSeller: true,
        tags: ['bread', 'whole wheat', 'bakery', 'fresh'],
        vendorId: vendors[0]._id,
      },

      // Meat & Fish
      {
        name: 'Atlantic Salmon',
        price: 800.0,
        originalPrice: 1000.0,
        imageUrl: 'https://images.unsplash.com/photo-1516594798947-e65505dbb29d?w=400&h=400&fit=crop',
        category: 'Meat & Fish',
        subCategory: 'Fish',
        brand: 'Ocean Fresh',
        unit: '500g',
        weight: 500,
        rating: 4.5,
        reviews: 45,
        isAvailable: true,
        stock: 15,
        isVegetarian: false,
        isVegan: false,
        isOrganic: false,
        description: 'Fresh Atlantic salmon fillet',
        ingredients: ['Salmon'],
        nutritionalInfo: {
          calories: 208,
          protein: 25.0,
          carbs: 0,
          fat: 12.0,
          fiber: 0,
        },
        images: [
          'https://images.unsplash.com/photo-1516594798947-e65505dbb29d?w=400&h=400&fit=crop'
        ],
        discount: 20,
        isFeatured: true,
        isBestSeller: false,
        tags: ['salmon', 'fish', 'seafood', 'fresh'],
        vendorId: vendors[0]._id,
      },

      // Snacks
      {
        name: 'Mixed Nuts',
        price: 150.0,
        originalPrice: 180.0,
        imageUrl: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&h=400&fit=crop',
        category: 'Snacks',
        subCategory: 'Nuts',
        brand: 'Nutty Delights',
        unit: '200g',
        weight: 200,
        rating: 4.6,
        reviews: 112,
        isAvailable: true,
        stock: 30,
        isVegetarian: true,
        isVegan: true,
        isOrganic: true,
        description: 'Premium mixed nuts selection',
        ingredients: ['Almonds', 'Cashews', 'Walnuts', 'Pistachios'],
        nutritionalInfo: {
          calories: 607,
          protein: 20.0,
          carbs: 22.0,
          fat: 54.0,
          fiber: 7.0,
        },
        images: [
          'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&h=400&fit=crop'
        ],
        discount: 17,
        isFeatured: true,
        isBestSeller: true,
        tags: ['nuts', 'mixed nuts', 'snacks', 'organic'],
        vendorId: vendors[0]._id,
      },

      // Beverages
      {
        name: 'Orange Juice',
        price: 120.0,
        originalPrice: 150.0,
        imageUrl: 'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=400&h=400&fit=crop',
        category: 'Beverages',
        subCategory: 'Juices',
        brand: 'Fresh Squeezed',
        unit: '1L',
        weight: 1000,
        rating: 4.3,
        reviews: 89,
        isAvailable: true,
        stock: 25,
        isVegetarian: true,
        isVegan: true,
        isOrganic: false,
        description: '100% pure orange juice',
        ingredients: ['Orange Juice'],
        nutritionalInfo: {
          calories: 45,
          protein: 0.7,
          carbs: 10.4,
          fat: 0.2,
          fiber: 0.2,
        },
        images: [
          'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=400&h=400&fit=crop'
        ],
        discount: 20,
        isFeatured: true,
        isBestSeller: true,
        tags: ['orange juice', 'beverages', 'fresh', 'natural'],
        vendorId: vendors[0]._id,
      },

      // Household
      {
        name: 'Laundry Detergent',
        price: 180.0,
        originalPrice: 220.0,
        imageUrl: 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=400&fit=crop',
        category: 'Household',
        subCategory: 'Cleaning',
        brand: 'Clean Pro',
        unit: '2L',
        weight: 2000,
        rating: 4.1,
        reviews: 67,
        isAvailable: true,
        stock: 20,
        isVegetarian: false,
        isVegan: false,
        isOrganic: false,
        description: 'Powerful laundry detergent for all fabrics',
        ingredients: ['Surfactants', 'Enzymes', 'Fragrance'],
        nutritionalInfo: null,
        images: [
          'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=400&fit=crop'
        ],
        discount: 18,
        isFeatured: false,
        isBestSeller: false,
        tags: ['detergent', 'laundry', 'cleaning', 'household'],
        vendorId: vendors[0]._id,
      },

      // Personal Care
      {
        name: 'Organic Soap',
        price: 85.0,
        originalPrice: 100.0,
        imageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400&h=400&fit=crop',
        category: 'Personal Care',
        subCategory: 'Hygiene',
        brand: 'Nature Care',
        unit: '100g',
        weight: 100,
        rating: 4.4,
        reviews: 78,
        isAvailable: true,
        stock: 30,
        isVegetarian: true,
        isVegan: true,
        isOrganic: true,
        description: 'Natural organic soap bar',
        ingredients: ['Coconut Oil', 'Olive Oil', 'Essential Oils'],
        nutritionalInfo: null,
        images: [
          'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400&h=400&fit=crop'
        ],
        discount: 15,
        isFeatured: false,
        isBestSeller: true,
        tags: ['soap', 'organic', 'natural', 'hygiene'],
        vendorId: vendors[0]._id,
      },
    ];

    // Insert products
    await TMartProduct.insertMany(products);
    console.log(`✅ Seeded ${products.length} T-Mart products`);

    // Update category product counts
    for (const category of categories) {
      const count = await TMartProduct.countDocuments({ category: category.displayName });
      await TMartCategory.updateOne(
        { _id: category._id },
        { productCount: count }
      );
    }
    console.log('✅ Updated category product counts');

    console.log('🎉 T-Mart products seeding completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding T-Mart products:', error);
    process.exit(1);
  }
};

seedTMartProducts(); 