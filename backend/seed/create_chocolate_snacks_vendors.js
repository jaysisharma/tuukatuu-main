const mongoose = require('mongoose');
const User = require('../src/models/User');
const Product = require('../src/models/Product');
const Category = require('../src/models/Category');

// MongoDB connection
mongoose.connect('mongodb://localhost:27017/first_db', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

const db = mongoose.connection;

db.on('error', console.error.bind(console, 'MongoDB connection error:'));
db.once('open', async () => {
  console.log('Connected to MongoDB');
  
  try {
    // Only clear the specific vendors and products this script creates
    // Don't clear all vendors/products as it would remove Kathmandu data
    
    // Create or find existing categories
    const chocolateCategory = await Category.findOneAndUpdate(
      { name: 'Chocolate' },
      {
        name: 'Chocolate',
        description: 'Delicious chocolate products',
        image: 'assets/images/category/chocolate.png',
        isActive: true
      },
      { upsert: true, new: true }
    );
    
    const coldDrinksCategory = await Category.findOneAndUpdate(
      { name: 'Cold Drinks' },
      {
        name: 'Cold Drinks',
        description: 'Refreshing beverages',
        image: 'assets/images/category/cold_drinks.png',
        isActive: true
      },
      { upsert: true, new: true }
    );
    
    const snacksCategory = await Category.findOneAndUpdate(
      { name: 'Snacks' },
      {
        name: 'Snacks',
        description: 'Tasty snack products',
        image: 'assets/images/category/snacks.png',
        isActive: true
      },
      { upsert: true, new: true }
    );
    
    console.log('Categories ready');
    
    // Check if vendors already exist to avoid duplicates
    const existingVendors = await User.find({
      email: { $in: ['sweet@example.com', 'beverage@example.com', 'snack@example.com'] }
    });
    
    if (existingVendors.length > 0) {
      console.log('Vendors already exist, checking for products...');
      console.log('Existing vendors:', existingVendors.map(v => v.storeName));
      
      // Check if products exist for these vendors
      const existingProducts = await Product.find({
        vendorId: { $in: existingVendors.map(v => v._id) }
      });
      
      if (existingProducts.length > 0) {
        console.log(`Products already exist (${existingProducts.length}), skipping creation`);
      } else {
        console.log('No products found, creating products for existing vendors...');
        await createProductsForVendors(existingVendors);
      }
    } else {
      // Create vendors with coordinates
      const vendors = [
        {
          name: 'Sweet Treats Store',
          email: 'sweet@example.com',
          phone: '+1234567890',
          password: 'password123',
          role: 'vendor',
          storeName: 'Sweet Treats Store',
          storeAddress: '123 Chocolate Lane, Sweet City, Candy State, USA 12345',
          storeCoordinates: {
            type: 'Point',
            coordinates: [-73.935242, 40.730610] // New York coordinates
          },
          vendorType: 'store',
          isVerified: true,
          isActive: true
        },
        {
          name: 'Beverage Hub',
          email: 'beverage@example.com',
          phone: '+1234567891',
          password: 'password123',
          role: 'vendor',
          storeName: 'Beverage Hub',
          storeAddress: '456 Drink Street, Beverage City, Liquid State, USA 12346',
          storeCoordinates: {
            type: 'Point',
            coordinates: [-73.935242, 40.730610] // New York coordinates
          },
          vendorType: 'store',
          isVerified: true,
          isActive: true
        },
        {
          name: 'Snack Paradise',
          email: 'snack@example.com',
          phone: '+1234567892',
          password: 'password123',
          role: 'vendor',
          storeName: 'Snack Paradise',
          storeAddress: '789 Snack Avenue, Snack City, Crunchy State, USA 12347',
          storeCoordinates: {
            type: 'Point',
            coordinates: [-73.935242, 40.730610] // New York coordinates
          },
          vendorType: 'store',
          isVerified: true,
          isActive: true
        }
      ];
      
      const createdVendors = await User.create(vendors);
      console.log('Vendors created');
      await createProductsForVendors(createdVendors);
    }
    
    // Helper function to create products for vendors
    async function createProductsForVendors(vendors) {
      // Create products
      const products = [
        // Chocolate products
        {
          name: 'Dairy Milk Chocolate Bar',
          description: 'Smooth and creamy milk chocolate bar',
          price: 2.99,
          category: 'Chocolate',
          subcategory: 'Dairy Milk',
          brand: 'Cadbury',
          vendorId: vendors[0]._id,
          imageUrl: 'assets/images/products/dairy_milk.jpg',
          stock: 100,
          rating: 4.5,
          reviews: 25,
          isAvailable: true,
          vendorType: 'store',
          deliveryFee: 2.99,
          unit: '1 bar',
          isNewArrival: true,
          isFeaturedDailyEssential: true,
          dailyEssential: true
        },
        {
          name: 'KitKat Chocolate Wafer',
          description: 'Crispy wafer fingers covered in chocolate',
          price: 1.99,
          category: 'Chocolate',
          subcategory: 'KitKat',
          brand: 'Nestle',
          vendorId: vendors[0]._id,
          imageUrl: 'assets/images/products/kitkat.jpg',
          stock: 150,
          rating: 4.3,
          reviews: 30,
          isAvailable: true,
          vendorType: 'store',
          deliveryFee: 1.99,
          unit: '1 pack',
          isNewArrival: false,
          isFeaturedDailyEssential: true,
          dailyEssential: true
        },
        {
          name: '5 Star Chocolate Bar',
          description: 'Rich chocolate with caramel center',
          price: 1.49,
          category: 'Chocolate',
          subcategory: '5 Star',
          brand: 'Cadbury',
          vendorId: vendors[0]._id,
          imageUrl: 'assets/images/products/5star.jpg',
          stock: 80,
          rating: 4.2,
          reviews: 18,
          isAvailable: true,
          vendorType: 'store',
          deliveryFee: 1.49,
          unit: '1 bar',
          isNewArrival: false,
          isFeaturedDailyEssential: false,
          dailyEssential: true
        },
        {
          name: 'Snickers Chocolate Bar',
          description: 'Chocolate, nougat, caramel, and peanuts',
          price: 2.49,
          category: 'Chocolate',
          subcategory: 'Snickers',
          brand: 'Mars',
          vendorId: vendors[0]._id,
          imageUrl: 'assets/images/products/snickers.jpg',
          stock: 120,
          rating: 4.6,
          reviews: 35,
          isAvailable: true,
          vendorType: 'store',
          deliveryFee: 2.49,
          unit: '1 bar',
          isNewArrival: false,
          isFeaturedDailyEssential: true,
          dailyEssential: true
        },
        {
          name: 'Twix Chocolate Bar',
          description: 'Biscuit topped with caramel and chocolate',
          price: 2.29,
          category: 'Chocolate',
          subcategory: 'Twix',
          brand: 'Mars',
          vendorId: vendors[0]._id,
          imageUrl: 'assets/images/products/twix.jpg',
          stock: 90,
          rating: 4.4,
          reviews: 22,
          isAvailable: true,
          vendorType: 'store',
          deliveryFee: 2.29,
          unit: '1 bar',
          isNewArrival: true,
          isFeaturedDailyEssential: false,
          dailyEssential: true
        },
        
        // Cold Drinks products
        {
          name: 'Coca Cola Classic',
          description: 'Refreshing classic cola drink',
          price: 1.99,
          category: 'Cold Drinks',
          subcategory: 'Cola',
          brand: 'Coca Cola',
          vendorId: vendors[1]._id,
          imageUrl: 'assets/images/products/coca_cola.jpg',
          stock: 200,
          rating: 4.7,
          reviews: 50,
          isAvailable: true,
          vendorType: 'store',
          deliveryFee: 1.99,
          unit: '330ml can',
          isNewArrival: false,
          isFeaturedDailyEssential: true,
          dailyEssential: true
        },
        {
          name: 'Pepsi Max',
          description: 'Sugar-free cola with maximum taste',
          price: 2.19,
          category: 'Cold Drinks',
          subcategory: 'Cola',
          brand: 'Pepsi',
          vendorId: vendors[1]._id,
          imageUrl: 'assets/images/products/pepsi_max.jpg',
          stock: 180,
          rating: 4.3,
          reviews: 28,
          isAvailable: true,
          vendorType: 'store',
          deliveryFee: 2.19,
          unit: '330ml can',
          isNewArrival: true,
          isFeaturedDailyEssential: false,
          dailyEssential: true
        },
        {
          name: 'Sprite Lemon Lime',
          description: 'Clear, crisp lemon-lime soda',
          price: 1.89,
          category: 'Cold Drinks',
          subcategory: 'Lemon Lime',
          brand: 'Sprite',
          vendorId: vendors[1]._id,
          imageUrl: 'assets/images/products/sprite.jpg',
          stock: 160,
          rating: 4.1,
          reviews: 20,
          isAvailable: true,
          vendorType: 'store',
          deliveryFee: 1.89,
          unit: '330ml can',
          isNewArrival: false,
          isFeaturedDailyEssential: false,
          dailyEssential: true
        },
        {
          name: 'Fanta Orange',
          description: 'Bursting with orange flavor',
          price: 1.79,
          category: 'Cold Drinks',
          subcategory: 'Orange',
          brand: 'Fanta',
          vendorId: vendors[1]._id,
          imageUrl: 'assets/images/products/fanta.jpg',
          stock: 140,
          rating: 4.0,
          reviews: 15,
          isAvailable: true,
          vendorType: 'store',
          deliveryFee: 1.79,
          unit: '330ml can',
          isNewArrival: false,
          isFeaturedDailyEssential: false,
          dailyEssential: true
        },
        {
          name: 'Mountain Dew',
          description: 'Citrus-flavored carbonated soft drink',
          price: 2.09,
          category: 'Cold Drinks',
          subcategory: 'Citrus',
          brand: 'Mountain Dew',
          vendorId: vendors[1]._id,
          imageUrl: 'assets/images/products/mountain_dew.jpg',
          stock: 110,
          rating: 4.2,
          reviews: 25,
          isAvailable: true,
          vendorType: 'store',
          deliveryFee: 2.09,
          unit: '330ml can',
          isNewArrival: true,
          isFeaturedDailyEssential: false,
          dailyEssential: true
        },
        
        // Snacks products
        {
          name: 'Lay\'s Classic Potato Chips',
          description: 'Crispy potato chips with sea salt',
          price: 3.99,
          category: 'Snacks',
          subcategory: 'Potato Chips',
          brand: 'Lay\'s',
          vendorId: vendors[2]._id,
          imageUrl: 'assets/images/products/lays_classic.jpg',
          stock: 120,
          rating: 4.5,
          reviews: 40,
          isAvailable: true,
          vendorType: 'store',
          deliveryFee: 3.99,
          unit: '100g pack',
          isNewArrival: false,
          isFeaturedDailyEssential: true,
          dailyEssential: true
        },
        {
          name: 'Doritos Nacho Cheese',
          description: 'Tortilla chips with nacho cheese flavor',
          price: 4.49,
          category: 'Snacks',
          subcategory: 'Tortilla Chips',
          brand: 'Doritos',
          vendorId: vendors[2]._id,
          imageUrl: 'assets/images/products/doritos_nacho.jpg',
          stock: 100,
          rating: 4.6,
          reviews: 35,
          isAvailable: true,
          vendorType: 'store',
          deliveryFee: 4.49,
          unit: '100g pack',
          isNewArrival: false,
          isFeaturedDailyEssential: true,
          dailyEssential: true
        },
        {
          name: 'Cheetos Crunchy',
          description: 'Crunchy cheese-flavored snacks',
          price: 3.79,
          category: 'Snacks',
          subcategory: 'Cheese Snacks',
          brand: 'Cheetos',
          vendorId: vendors[2]._id,
          imageUrl: 'assets/images/products/cheetos_crunchy.jpg',
          stock: 90,
          rating: 4.3,
          reviews: 28,
          isAvailable: true,
          vendorType: 'store',
          deliveryFee: 3.79,
          unit: '100g pack',
          isNewArrival: true,
          isFeaturedDailyEssential: false,
          dailyEssential: true
        },
        {
          name: 'Snack Paradise Pringles Original',
          description: 'Stackable potato crisps with original flavor',
          price: 4.99,
          category: 'Snacks',
          subcategory: 'Potato Crisps',
          brand: 'Pringles',
          vendorId: vendors[2]._id,
          imageUrl: 'assets/images/products/pringles_original.jpg',
          stock: 80,
          rating: 4.4,
          reviews: 32,
          isAvailable: true,
          vendorType: 'store',
          deliveryFee: 4.99,
          unit: '100g pack',
          isNewArrival: false,
          isFeaturedDailyEssential: false,
          dailyEssential: true
        },
        {
          name: 'Snack Paradise Ritz Crackers',
          description: 'Buttery, flaky crackers',
          price: 3.29,
          category: 'Snacks',
          subcategory: 'Crackers',
          brand: 'Ritz',
          vendorId: vendors[2]._id,
          imageUrl: 'assets/images/products/ritz_crackers.jpg',
          stock: 110,
          rating: 4.1,
          reviews: 18,
          isAvailable: true,
          vendorType: 'store',
          deliveryFee: 3.29,
          unit: '100g pack',
          isNewArrival: false,
          isFeaturedDailyEssential: false,
          dailyEssential: true
        }
      ];
      
      const createdProducts = await Product.create(products);
      console.log('Products created');
    }
    
    console.log('\n=== SEED DATA SUMMARY ===');
    console.log(`Categories: ${await Category.countDocuments()}`);
    console.log(`Vendors: ${await User.countDocuments({ role: 'vendor' })}`);
    console.log(`Products: ${await Product.countDocuments()}`);
    
    // Get all vendors to show summary
    const allVendors = await User.find({ role: 'vendor' });
    console.log('\n=== ALL VENDORS ===');
    allVendors.forEach(vendor => {
      console.log(`- ${vendor.storeName} (${vendor.email}) - ${vendor.vendorType}`);
    });
    
    console.log('\n=== PRODUCTS BY CATEGORY ===');
    const categories = await Category.find();
    for (const category of categories) {
      const count = await Product.countDocuments({ category: category.name });
      if (count > 0) {
        console.log(`- ${category.name}: ${count} products`);
      }
    }
    
    console.log('\n=== DAILY ESSENTIALS ===');
    const dailyEssentials = await Product.countDocuments({ dailyEssential: true });
    const featuredDailyEssentials = await Product.countDocuments({ isFeaturedDailyEssential: true });
    console.log(`- Total Daily Essentials: ${dailyEssentials}`);
    console.log(`- Featured Daily Essentials: ${featuredDailyEssentials}`);
    
    console.log('\nSeed data created successfully!');
    console.log('Note: This script only adds new data, it does not delete existing Kathmandu vendors/products.');
    
  } catch (error) {
    console.error('Error creating seed data:', error);
  } finally {
    mongoose.connection.close();
  }
});
