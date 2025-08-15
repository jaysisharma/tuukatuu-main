const mongoose = require('mongoose');
require('dotenv').config();

// Import models
const User = require('../src/models/User');
const Product = require('../src/models/Product');

async function seedFastFood() {
  try {
    // Connect to MongoDB
    await mongoose.connect('mongodb+srv://testbuddy1221:jaysi123@cluster0.1bjhspl.mongodb.net/');
    console.log('Connected to MongoDB');

    console.log('Starting fast food seeding...');

    // 1. Seed fast food vendors
    console.log('1. Seeding fast food vendors...');
    const fastFoodVendors = [
      {
        name: 'Burger King',
        email: 'burgerking@fastfood.com',
        phone: '9800000201',
        password: await require('bcryptjs').hash('password123', 10),
        role: 'vendor',
        storeName: 'Burger King',
        storeDescription: 'Home of the Whopper! Fresh flame-grilled burgers and crispy fries',
        storeImage: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b',
        storeBanner: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b',
        storeTags: ['Fast Food', 'Burgers', 'Fries', 'American'],
        storeCategories: ['Fast Food', 'Burgers'],
        vendorType: 'restaurant',
        vendorSubType: 'fast_food',
        storeRating: 4.5,
        storeReviews: 890,
        isFeatured: true,
        storeCoordinates: {
          latitude: 27.7172,
          longitude: 85.3240
        },
        storeAddress: 'Thamel, Kathmandu',
        deliveryTime: '20-30 min',
        deliveryFee: '₹30',
        storeImages: [
          'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b',
          'https://images.unsplash.com/photo-1586190848861-99aa4a171e90',
          'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b'
        ],
      },
      {
        name: 'Pizza Hut',
        email: 'pizzahut@fastfood.com',
        phone: '9800000202',
        password: await require('bcryptjs').hash('password123', 10),
        role: 'vendor',
        storeName: 'Pizza Hut',
        storeDescription: 'Delicious pizzas with fresh toppings and crispy crust',
        storeImage: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b',
        storeBanner: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b',
        storeTags: ['Fast Food', 'Pizza', 'Italian', 'Delivery'],
        storeCategories: ['Fast Food', 'Pizza'],
        vendorType: 'restaurant',
        vendorSubType: 'fast_food',
        storeRating: 4.7,
        storeReviews: 1200,
        isFeatured: true,
        storeCoordinates: {
          latitude: 27.7089,
          longitude: 85.3300
        },
        storeAddress: 'Durbarmarg, Kathmandu',
        deliveryTime: '25-35 min',
        deliveryFee: '₹40',
        storeImages: [
          'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b',
          'https://images.unsplash.com/photo-1586190848861-99aa4a171e90',
          'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b'
        ],
      },
      {
        name: 'KFC',
        email: 'kfc@fastfood.com',
        phone: '9800000203',
        password: await require('bcryptjs').hash('password123', 10),
        role: 'vendor',
        storeName: 'KFC',
        storeDescription: 'Finger Lickin\' Good! Crispy fried chicken and sides',
        storeImage: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b',
        storeBanner: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b',
        storeTags: ['Fast Food', 'Fried Chicken', 'American'],
        storeCategories: ['Fast Food', 'Chicken'],
        vendorType: 'restaurant',
        vendorSubType: 'fast_food',
        storeRating: 4.6,
        storeReviews: 950,
        isFeatured: true,
        storeCoordinates: {
          latitude: 27.7250,
          longitude: 85.3400
        },
        storeAddress: 'Baneshwor, Kathmandu',
        deliveryTime: '20-30 min',
        deliveryFee: '₹35',
        storeImages: [
          'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b',
          'https://images.unsplash.com/photo-1586190848861-99aa4a171e90',
          'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b'
        ],
      },
      {
        name: 'McDonald\'s',
        email: 'mcdonalds@fastfood.com',
        phone: '9800000204',
        password: await require('bcryptjs').hash('password123', 10),
        role: 'vendor',
        storeName: 'McDonald\'s',
        storeDescription: 'I\'m Lovin\' It! Classic burgers, fries, and shakes',
        storeImage: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b',
        storeBanner: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b',
        storeTags: ['Fast Food', 'Burgers', 'Fries', 'American'],
        storeCategories: ['Fast Food', 'Burgers'],
        vendorType: 'restaurant',
        vendorSubType: 'fast_food',
        storeRating: 4.4,
        storeReviews: 1100,
        isFeatured: false,
        storeCoordinates: {
          latitude: 27.7300,
          longitude: 85.3500
        },
        storeAddress: 'New Baneshwor, Kathmandu',
        deliveryTime: '15-25 min',
        deliveryFee: '₹25',
        storeImages: [
          'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b',
          'https://images.unsplash.com/photo-1586190848861-99aa4a171e90',
          'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b'
        ],
      },
      {
        name: 'Domino\'s Pizza',
        email: 'dominos@fastfood.com',
        phone: '9800000205',
        password: await require('bcryptjs').hash('password123', 10),
        role: 'vendor',
        storeName: 'Domino\'s Pizza',
        storeDescription: '30 minutes or free! Hot and fresh pizza delivery',
        storeImage: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b',
        storeBanner: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b',
        storeTags: ['Fast Food', 'Pizza', 'Delivery', 'Italian'],
        storeCategories: ['Fast Food', 'Pizza'],
        vendorType: 'restaurant',
        vendorSubType: 'fast_food',
        storeRating: 4.8,
        storeReviews: 1350,
        isFeatured: true,
        storeCoordinates: {
          latitude: 27.7200,
          longitude: 85.3200
        },
        storeAddress: 'Lazimpat, Kathmandu',
        deliveryTime: '20-30 min',
        deliveryFee: '₹30',
        storeImages: [
          'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b',
          'https://images.unsplash.com/photo-1586190848861-99aa4a171e90',
          'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b'
        ],
      },
      {
        name: 'Subway',
        email: 'subway@fastfood.com',
        phone: '9800000206',
        password: await require('bcryptjs').hash('password123', 10),
        role: 'vendor',
        storeName: 'Subway',
        storeDescription: 'Eat Fresh! Healthy sandwiches and salads',
        storeImage: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b',
        storeBanner: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b',
        storeTags: ['Fast Food', 'Sandwiches', 'Healthy', 'Salads'],
        storeCategories: ['Fast Food', 'Sandwiches'],
        vendorType: 'restaurant',
        vendorSubType: 'fast_food',
        storeRating: 4.3,
        storeReviews: 680,
        isFeatured: false,
        storeCoordinates: {
          latitude: 27.7150,
          longitude: 85.3250
        },
        storeAddress: 'Pulchowk, Lalitpur',
        deliveryTime: '25-35 min',
        deliveryFee: '₹20',
        storeImages: [
          'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b',
          'https://images.unsplash.com/photo-1586190848861-99aa4a171e90',
          'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b'
        ],
      }
    ];

    // Create vendors
    const createdVendors = [];
    for (const vendorData of fastFoodVendors) {
      const existingVendor = await User.findOne({ email: vendorData.email });
      if (existingVendor) {
        console.log(`Vendor ${vendorData.storeName} already exists, skipping...`);
        createdVendors.push(existingVendor);
        continue;
      }

      const vendor = new User(vendorData);
      await vendor.save();
      createdVendors.push(vendor);
      console.log(`Created vendor: ${vendor.storeName}`);
    }

    console.log(`Created ${createdVendors.length} fast food vendors`);

    // 2. Seed fast food products
    console.log('2. Seeding fast food products...');
    
    const fastFoodProducts = [
      // Burger King Products
      {
        name: 'Whopper',
        description: 'Flame-grilled beef patty with fresh lettuce, tomatoes, mayo, pickles, and onions on a sesame seed bun',
        price: 450,
        originalPrice: 500,
        category: 'Burgers',
        subCategory: 'Beef Burgers',
        vendorId: createdVendors[0]._id,
        imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b',
        images: ['https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b'],
        isAvailable: true,
        isFeatured: true,
        isPopular: true,
        stock: 50,
        tags: ['Beef', 'Flame-grilled', 'Fresh'],
        rating: 4.6,
        reviews: 120,
        preparationTime: '8-12 min',
        calories: 650,
        allergens: ['Gluten', 'Dairy'],
        customization: {
          size: ['Regular', 'Large'],
          extras: ['Cheese', 'Bacon', 'Extra Patty'],
          sides: ['Fries', 'Onion Rings', 'Soft Drink']
        }
      },
      {
        name: 'Chicken Royale',
        description: 'Crispy chicken fillet with lettuce and mayo on a sesame seed bun',
        price: 380,
        originalPrice: 420,
        category: 'Burgers',
        subCategory: 'Chicken Burgers',
        vendorId: createdVendors[0]._id,
        imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b',
        images: ['https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b'],
        isAvailable: true,
        isFeatured: false,
        isPopular: true,
        stock: 40,
        tags: ['Chicken', 'Crispy', 'Fresh'],
        rating: 4.4,
        reviews: 95,
        preparationTime: '6-10 min',
        calories: 520,
        allergens: ['Gluten', 'Dairy'],
        customization: {
          size: ['Regular', 'Large'],
          extras: ['Cheese', 'Bacon'],
          sides: ['Fries', 'Soft Drink']
        }
      },
      {
        name: 'French Fries',
        description: 'Golden crispy fries seasoned with salt',
        price: 120,
        originalPrice: 150,
        category: 'Sides',
        subCategory: 'Fries',
        vendorId: createdVendors[0]._id,
        imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b',
        images: ['https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b'],
        isAvailable: true,
        isFeatured: false,
        isPopular: true,
        stock: 100,
        tags: ['Crispy', 'Golden', 'Seasoned'],
        rating: 4.2,
        reviews: 200,
        preparationTime: '3-5 min',
        calories: 365,
        allergens: ['Gluten'],
        customization: {
          size: ['Small', 'Medium', 'Large'],
          seasoning: ['Salt', 'Cheese', 'Spicy']
        }
      },

      // Pizza Hut Products
      {
        name: 'Margherita Pizza',
        description: 'Classic pizza with tomato sauce, mozzarella cheese, and fresh basil',
        price: 650,
        originalPrice: 750,
        category: 'Pizza',
        subCategory: 'Classic Pizza',
        vendorId: createdVendors[1]._id,
        images: ['https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b'],
        isAvailable: true,
        isFeatured: true,
        isPopular: true,
        stock: 30,
        tags: ['Classic', 'Cheese', 'Fresh'],
        rating: 4.7,
        reviews: 180,
        preparationTime: '15-20 min',
        calories: 850,
        allergens: ['Gluten', 'Dairy'],
        customization: {
          size: ['Small', 'Medium', 'Large'],
          crust: ['Thin', 'Thick', 'Stuffed'],
          extras: ['Extra Cheese', 'Extra Toppings']
        }
      },
      {
        name: 'Pepperoni Pizza',
        description: 'Spicy pepperoni with melted cheese and tomato sauce',
        price: 750,
        originalPrice: 850,
        category: 'Pizza',
        subCategory: 'Meat Pizza',
        vendorId: createdVendors[1]._id,
        images: ['https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b'],
        isAvailable: true,
        isFeatured: false,
        isPopular: true,
        stock: 25,
        tags: ['Spicy', 'Pepperoni', 'Cheese'],
        rating: 4.8,
        reviews: 150,
        preparationTime: '15-20 min',
        calories: 950,
        allergens: ['Gluten', 'Dairy', 'Pork'],
        customization: {
          size: ['Small', 'Medium', 'Large'],
          crust: ['Thin', 'Thick', 'Stuffed'],
          extras: ['Extra Cheese', 'Extra Pepperoni']
        }
      },

      // KFC Products
      {
        name: 'Original Recipe Chicken',
        description: 'Crispy fried chicken with 11 herbs and spices',
        price: 550,
        originalPrice: 600,
        category: 'Chicken',
        subCategory: 'Fried Chicken',
        vendorId: createdVendors[2]._id,
        images: ['https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b'],
        isAvailable: true,
        isFeatured: true,
        isPopular: true,
        stock: 35,
        tags: ['Crispy', 'Spicy', 'Original'],
        rating: 4.9,
        reviews: 220,
        preparationTime: '10-15 min',
        calories: 750,
        allergens: ['Gluten', 'Dairy'],
        customization: {
          pieces: ['2 Pieces', '4 Pieces', '8 Pieces'],
          sides: ['Mashed Potatoes', 'Coleslaw', 'Biscuits']
        }
      },
      {
        name: 'Zinger Burger',
        description: 'Spicy chicken fillet with lettuce and mayo in a soft bun',
        price: 420,
        originalPrice: 480,
        category: 'Burgers',
        subCategory: 'Chicken Burgers',
        vendorId: createdVendors[2]._id,
        images: ['https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b'],
        isAvailable: true,
        isFeatured: false,
        isPopular: true,
        stock: 45,
        tags: ['Spicy', 'Chicken', 'Crispy'],
        rating: 4.6,
        reviews: 180,
        preparationTime: '8-12 min',
        calories: 580,
        allergens: ['Gluten', 'Dairy'],
        customization: {
          extras: ['Cheese', 'Bacon'],
          sides: ['Fries', 'Soft Drink']
        }
      },

      // McDonald's Products
      {
        name: 'Big Mac',
        description: 'Two 100% beef patties with special sauce, lettuce, cheese, pickles, onions on a sesame seed bun',
        price: 380,
        originalPrice: 420,
        category: 'Burgers',
        subCategory: 'Beef Burgers',
        vendorId: createdVendors[3]._id,
        images: ['https://hips.hearstapps.com/hmg-prod/images/big-mac-index-66574ee4103a5.jpg?crop=0.502xw:1.00xh;0.250xw,0&resize=1200:*'],
        isAvailable: true,
        isFeatured: true,
        isPopular: true,
        stock: 60,
        tags: ['Beef', 'Special Sauce', 'Classic'],
        rating: 4.5,
        reviews: 300,
        preparationTime: '5-8 min',
        calories: 550,
        allergens: ['Gluten', 'Dairy'],
        customization: {
          extras: ['Extra Cheese', 'Extra Patty'],
          sides: ['Fries', 'Soft Drink']
        }
      },
      {
        name: 'McChicken',
        description: 'Crispy chicken patty with shredded lettuce and creamy mayo sauce',
        price: 320,
        originalPrice: 360,
        category: 'Burgers',
        subCategory: 'Chicken Burgers',
        vendorId: createdVendors[3]._id,
        images: ['https://youplateit.com.au/wp-content/uploads/recipes/247/variant/8912/8c3e5f265b693776ac11907bbc2be2c6_feature.jpg'],
        isAvailable: true,
        isFeatured: false,
        isPopular: true,
        stock: 50,
        tags: ['Chicken', 'Crispy', 'Creamy'],
        rating: 4.3,
        reviews: 250,
        preparationTime: '5-8 min',
        calories: 420,
        allergens: ['Gluten', 'Dairy'],
        customization: {
          extras: ['Cheese', 'Bacon'],
          sides: ['Fries', 'Soft Drink']
        }
      },

      // Domino's Products
      {
        name: 'Pepperoni Pizza',
        description: 'Spicy pepperoni with melted mozzarella cheese and tomato sauce',
        price: 680,
        originalPrice: 780,
        category: 'Pizza',
        subCategory: 'Meat Pizza',
        vendorId: createdVendors[4]._id,
        images: ['https://youplateit.com.au/wp-content/uploads/recipes/247/variant/8912/8c3e5f265b693776ac11907bbc2be2c6_feature.jpg'],
        isAvailable: true,
        isFeatured: true,
        isPopular: true,
        stock: 20,
        tags: ['Spicy', 'Pepperoni', 'Fast Delivery'],
        rating: 4.8,
        reviews: 160,
        preparationTime: '15-20 min',
        calories: 920,
        allergens: ['Gluten', 'Dairy', 'Pork'],
        customization: {
          size: ['Small', 'Medium', 'Large'],
          crust: ['Hand Tossed', 'Thin Crust', 'Pan'],
          extras: ['Extra Cheese', 'Extra Pepperoni']
        }
      },
      {
        name: 'Chicken Tikka Pizza',
        description: 'Spicy chicken tikka with onions, capsicum, and cheese',
        price: 720,
        originalPrice: 820,
        category: 'Pizza',
        subCategory: 'Chicken Pizza',
        vendorId: createdVendors[4]._id,
        images: ['https://youplateit.com.au/wp-content/uploads/recipes/247/variant/8912/8c3e5f265b693776ac11907bbc2be2c6_feature.jpg'],
        isAvailable: true,
        isFeatured: false,
        isPopular: true,
        stock: 18,
        tags: ['Spicy', 'Chicken Tikka', 'Indian'],
        rating: 4.7,
        reviews: 140,
        preparationTime: '15-20 min',
        calories: 880,
        allergens: ['Gluten', 'Dairy'],
        customization: {
          size: ['Small', 'Medium', 'Large'],
          crust: ['Hand Tossed', 'Thin Crust', 'Pan'],
          extras: ['Extra Cheese', 'Extra Chicken']
        }
      },

      // Subway Products
      {
        name: 'Chicken Teriyaki Sub',
        description: 'Grilled chicken with teriyaki sauce, lettuce, tomatoes, and onions',
        price: 280,
        originalPrice: 320,
        category: 'Sandwiches',
        subCategory: 'Chicken Sandwiches',
        vendorId: createdVendors[5]._id,
        images: ['https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTLND-KVa99pdx40SGpof2NkRZzotsvbv2dAQ&s'],
        isAvailable: true,
        isFeatured: true,
        isPopular: true,
        stock: 40,
        tags: ['Healthy', 'Grilled', 'Teriyaki'],
        rating: 4.4,
        reviews: 120,
        preparationTime: '5-8 min',
        calories: 380,
        allergens: ['Gluten', 'Dairy'],
        customization: {
          bread: ['Italian', 'Wheat', 'Honey Oat'],
          vegetables: ['Lettuce', 'Tomatoes', 'Onions', 'Cucumbers'],
          sauces: ['Mayo', 'Mustard', 'Sweet Onion']
        }
      },
      {
        name: 'Veggie Delite Sub',
        description: 'Fresh vegetables with lettuce, tomatoes, cucumbers, and green peppers',
        price: 220,
        originalPrice: 260,
        category: 'Sandwiches',
        subCategory: 'Vegetarian Sandwiches',
        vendorId: createdVendors[5]._id,
        images: ['https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b'],
        isAvailable: true,
        isFeatured: false,
        isPopular: true,
        stock: 35,
        tags: ['Vegetarian', 'Fresh', 'Healthy'],
        rating: 4.2,
        reviews: 90,
        preparationTime: '5-8 min',
        calories: 280,
        allergens: ['Gluten'],
        customization: {
          bread: ['Italian', 'Wheat', 'Honey Oat'],
          vegetables: ['Lettuce', 'Tomatoes', 'Cucumbers', 'Green Peppers'],
          sauces: ['Mayo', 'Mustard', 'Sweet Onion']
        }
      }
    ];

    // Create products
    let createdProducts = 0;
    for (const productData of fastFoodProducts) {
      const existingProduct = await Product.findOne({ 
        name: productData.name, 
        vendorId: productData.vendorId 
      });
      
      if (existingProduct) {
        console.log(`Product ${productData.name} already exists for this vendor, skipping...`);
        continue;
      }

      const product = new Product(productData);
      await product.save();
      createdProducts++;
      console.log(`Created product: ${product.name} for ${productData.vendorId}`);
    }

    console.log(`Created ${createdProducts} fast food products`);

    console.log('✅ Fast food seeding completed successfully!');
    
  } catch (error) {
    console.error('❌ Error seeding fast food:', error);
  } finally {
    await mongoose.disconnect();
    console.log('Disconnected from MongoDB');
  }
}

// Run the seeding function
seedFastFood(); 