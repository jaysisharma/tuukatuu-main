const mongoose = require('mongoose');
require('dotenv').config();

const Product = require('./src/models/Product');

mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/first_db2', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

async function addTmartProducts() {
  try {
    console.log('🔄 Adding T-Mart products for fast delivery...');

    const tmartProducts = [
      {
        name: 'Fresh Bananas',
        description: 'Sweet organic bananas',
        price: 40,
        originalPrice: 50,
        imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=400&fit=crop',
        category: 'Fruits & Vegetables',
        vendorType: 'store',
        vendorSubType: 'tmart',
        isAvailable: true,
        deliveryTime: '10-20 mins',
        deliveryFee: 20,
        stock: 200,
        rating: 4.5,
        isVegetarian: true,
        isFeatured: true,
        isFeaturedDailyEssential: true,
        unit: '1kg',
        vendorId: null,
        vendorName: 'T-Mart Express'
      },
      {
        name: 'Fresh Milk',
        description: 'Pure whole milk',
        price: 45,
        originalPrice: 55,
        imageUrl: 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400&h=400&fit=crop',
        category: 'Dairy & Eggs',
        vendorType: 'store',
        vendorSubType: 'tmart',
        isAvailable: true,
        deliveryTime: '10-20 mins',
        deliveryFee: 20,
        stock: 150,
        rating: 4.3,
        isVegetarian: true,
        isFeatured: true,
        isFeaturedDailyEssential: true,
        unit: '1L',
        vendorId: null,
        vendorName: 'T-Mart Express'
      },
      {
        name: 'Whole Wheat Bread',
        description: 'Fresh whole wheat bread',
        price: 35,
        originalPrice: 40,
        imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&h=400&fit=crop',
        category: 'Bakery',
        vendorType: 'store',
        vendorSubType: 'tmart',
        isAvailable: true,
        deliveryTime: '10-20 mins',
        deliveryFee: 20,
        stock: 100,
        rating: 4.2,
        isVegetarian: true,
        isFeatured: true,
        isFeaturedDailyEssential: true,
        unit: '400g',
        vendorId: null,
        vendorName: 'T-Mart Express'
      },
      {
        name: 'Farm Eggs',
        description: 'Fresh farm eggs',
        price: 60,
        originalPrice: 70,
        imageUrl: 'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=400&h=400&fit=crop',
        category: 'Dairy & Eggs',
        vendorType: 'store',
        vendorSubType: 'tmart',
        isAvailable: true,
        deliveryTime: '10-20 mins',
        deliveryFee: 20,
        stock: 120,
        rating: 4.4,
        isVegetarian: true,
        isFeatured: true,
        isFeaturedDailyEssential: true,
        unit: '12 pcs',
        vendorId: null,
        vendorName: 'T-Mart Express'
      },
      {
        name: 'Fresh Tomatoes',
        description: 'Red ripe tomatoes',
        price: 30,
        originalPrice: 40,
        imageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400&h=400&fit=crop',
        category: 'Fruits & Vegetables',
        vendorType: 'tmart',
        vendorSubType: 'grocery',
        isAvailable: true,
        deliveryTime: '10-20 mins',
        deliveryFee: 20,
        stock: 180,
        rating: 4.1,
        isVegetarian: true,
        isFeatured: true,
        isFeaturedDailyEssential: true,
        unit: '1kg',
        vendorId: 'tmart',
        vendorName: 'T-Mart Express'
      },
      {
        name: 'Red Onions',
        description: 'Fresh red onions',
        price: 25,
        originalPrice: 35,
        imageUrl: 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=400&h=400&fit=crop',
        category: 'Fruits & Vegetables',
        vendorType: 'tmart',
        vendorSubType: 'grocery',
        isAvailable: true,
        deliveryTime: '10-20 mins',
        deliveryFee: 20,
        stock: 160,
        rating: 4.0,
        isVegetarian: true,
        isFeatured: true,
        isFeaturedDailyEssential: true,
        unit: '1kg',
        vendorId: 'tmart',
        vendorName: 'T-Mart Express'
      },
      {
        name: 'Orange Juice',
        description: 'Fresh orange juice',
        price: 120,
        originalPrice: 150,
        imageUrl: 'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=400&h=400&fit=crop',
        category: 'Beverages',
        vendorType: 'tmart',
        vendorSubType: 'grocery',
        isAvailable: true,
        deliveryTime: '10-20 mins',
        deliveryFee: 20,
        stock: 80,
        rating: 4.3,
        isVegetarian: true,
        isFeatured: true,
        unit: '1L',
        vendorId: 'tmart',
        vendorName: 'T-Mart Express'
      },
      {
        name: 'Italian Pasta',
        description: 'Premium Italian pasta',
        price: 85,
        originalPrice: 100,
        imageUrl: 'https://images.unsplash.com/photo-1544384951-6db2a7bec5d6?w=400&h=400&fit=crop',
        category: 'Pantry',
        vendorType: 'tmart',
        vendorSubType: 'grocery',
        isAvailable: true,
        deliveryTime: '10-20 mins',
        deliveryFee: 20,
        stock: 90,
        rating: 4.7,
        isVegetarian: true,
        isFeatured: true,
        unit: '500g',
        vendorId: 'tmart',
        vendorName: 'T-Mart Express'
      }
    ];

    // Clear existing T-Mart products
    await Product.deleteMany({ vendorType: 'tmart' });
    console.log('🗑️ Cleared existing T-Mart products');

    // Add new T-Mart products
    for (const productData of tmartProducts) {
      const product = new Product(productData);
      await product.save();
      console.log(`✅ Added: ${productData.name}`);
    }

    console.log('✅ T-Mart products added successfully!');

    // Show some products
    const products = await Product.find({ vendorType: 'tmart' }).limit(5);
    console.log('\n📦 Sample T-Mart products:');
    products.forEach(p => {
      console.log(`- ${p.name}: Rs ${p.price} (${p.deliveryTime})`);
    });

    process.exit(0);
  } catch (error) {
    console.error('❌ Error adding T-Mart products:', error);
    process.exit(1);
  }
}

addTmartProducts(); 