const mongoose = require('mongoose');
require('dotenv').config();

// Import models
const User = require('../src/models/User');
const Product = require('../src/models/Product');

mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/first_db', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

const createKathmanduProducts = async () => {
  try {
    console.log('🛍️ Creating enhanced products for Kathmandu vendors...');

    // Get vendors by type
    const restaurants = await User.find({ role: 'vendor', vendorType: 'restaurant' });
    const stores = await User.find({ role: 'vendor', vendorType: 'store' });

    console.log(`Found ${restaurants.length} restaurants and ${stores.length} stores`);

    // Only clear products from Kathmandu vendors to preserve other products
    const kathmanduVendorIds = [...restaurants.map(r => r._id), ...stores.map(s => s._id)];
    await Product.deleteMany({ vendorId: { $in: kathmanduVendorIds } });
    console.log('🗑️  Cleared existing products from Kathmandu vendors only');

    const products = [];

    // Restaurant Products
    console.log('\n🍽️  Creating enhanced restaurant products...');

    // Himalayan Kitchen Products (Nepali Cuisine)
    const himalayanKitchen = restaurants.find(r => r.storeName === 'Himalayan Kitchen');
    if (himalayanKitchen) {
      const himalayanProducts = [
        {
          name: 'Dal Bhat Set',
          price: 350,
          imageUrl: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=400&h=400&fit=crop',
          category: 'Nepali',
          description: 'Traditional Nepali meal with rice, lentils, vegetables, and pickles. Served with fresh vegetables, chutney, and papad. The heart of Nepali cuisine.',
          unit: '1 plate',
          deliveryTime: '25 mins',
          isAvailable: true,
          deliveryFee: 30,
          stock: 50,
          vendorId: himalayanKitchen._id,
          vendorType: 'restaurant',
          vendorSubType: 'nepali',
          isVegetarian: true,
          rating: 4.8,
          reviews: 89,
          isPopular: true,
          isFeatured: true,
          isBestSeller: true,
          tags: ['Traditional', 'Nepali', 'Vegetarian', 'Dal Bhat', 'Rice', 'Lentils']
        },
        {
          name: 'Momo Platter',
          price: 280,
          imageUrl: 'https://images.unsplash.com/photo-1551504734-5ee1c4a1479b?w=400&h=400&fit=crop',
          category: 'Nepali',
          description: 'Steamed dumplings with chicken or vegetable filling, served with spicy sauce. 12 pieces of perfectly crafted momos with authentic Nepali spices.',
          unit: '12 pieces',
          deliveryTime: '20 mins',
          isAvailable: true,
          deliveryFee: 30,
          stock: 40,
          vendorId: himalayanKitchen._id,
          vendorType: 'restaurant',
          vendorSubType: 'nepali',
          isVegetarian: false,
          rating: 4.6,
          reviews: 156,
          isPopular: true,
          isFeatured: true,
          tags: ['Momo', 'Dumplings', 'Spicy', 'Popular', 'Steamed', 'Authentic']
        },
        {
          name: 'Chicken Curry',
          price: 420,
          imageUrl: 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=400&h=400&fit=crop',
          category: 'Nepali',
          description: 'Spicy chicken curry with traditional Nepali spices and herbs. Tender chicken cooked in aromatic spices with rich gravy. Served with rice.',
          unit: '1 serving',
          deliveryTime: '25 mins',
          isAvailable: true,
          deliveryFee: 30,
          stock: 35,
          vendorId: himalayanKitchen._id,
          vendorType: 'restaurant',
          vendorSubType: 'nepali',
          isVegetarian: false,
          rating: 4.5,
          reviews: 78,
          isPopular: true,
          tags: ['Chicken', 'Curry', 'Spicy', 'Traditional', 'Rich Gravy', 'Aromatic']
        },
        {
          name: 'Gundruk Soup',
          price: 180,
          imageUrl: 'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=400&h=400&fit=crop',
          category: 'Nepali',
          description: 'Traditional fermented leafy green soup. Rich in probiotics and traditional Nepali flavors. Healthy and authentic taste.',
          unit: '1 bowl',
          deliveryTime: '15 mins',
          isAvailable: true,
          deliveryFee: 30,
          stock: 25,
          vendorId: himalayanKitchen._id,
          vendorType: 'restaurant',
          vendorSubType: 'nepali',
          isVegetarian: true,
          rating: 4.3,
          reviews: 45,
          tags: ['Gundruk', 'Soup', 'Fermented', 'Healthy', 'Traditional', 'Probiotics']
        },
        {
          name: 'Nepali Thali',
          price: 450,
          imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=400&h=400&fit=crop',
          category: 'Nepali',
          description: 'Complete Nepali meal with rice, dal, vegetables, meat curry, pickles, and yogurt. Traditional way of serving Nepali food.',
          unit: '1 thali',
          deliveryTime: '30 mins',
          isAvailable: true,
          deliveryFee: 30,
          stock: 30,
          vendorId: himalayanKitchen._id,
          vendorType: 'restaurant',
          vendorSubType: 'nepali',
          isVegetarian: false,
          rating: 4.7,
          reviews: 112,
          isFeatured: true,
          tags: ['Thali', 'Complete Meal', 'Traditional', 'Rice', 'Curry', 'Pickles']
        }
      ];
      products.push(...himalayanProducts);
    }

    // Thamel House Restaurant Products (International Cuisine)
    const thamelHouse = restaurants.find(r => r.storeName === 'Thamel House Restaurant');
    if (thamelHouse) {
      const thamelProducts = [
        {
          name: 'Beef Burger',
          price: 380,
          imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&h=400&fit=crop',
          category: 'International',
          description: 'Juicy beef burger with fresh lettuce, tomato, cheese, and special sauce. Served with crispy fries and coleslaw.',
          unit: '1 burger + fries',
          deliveryTime: '25 mins',
          isAvailable: true,
          deliveryFee: 35,
          stock: 40,
          vendorId: thamelHouse._id,
          vendorType: 'restaurant',
          vendorSubType: 'international',
          isVegetarian: false,
          rating: 4.4,
          reviews: 67,
          isPopular: true,
          tags: ['Beef', 'Burger', 'International', 'Fries', 'Juicy', 'Fresh']
        },
        {
          name: 'Caesar Salad',
          price: 280,
          imageUrl: 'https://images.unsplash.com/photo-1546793665-c74683f339c1?w=400&h=400&fit=crop',
          category: 'International',
          description: 'Fresh romaine lettuce with Caesar dressing, parmesan cheese, croutons, and anchovies. Healthy and delicious choice.',
          unit: '1 large bowl',
          deliveryTime: '20 mins',
          isAvailable: true,
          deliveryFee: 35,
          stock: 30,
          vendorId: thamelHouse._id,
          vendorType: 'restaurant',
          vendorSubType: 'international',
          isVegetarian: false,
          rating: 4.2,
          reviews: 45,
          tags: ['Caesar', 'Salad', 'Healthy', 'Fresh', 'Parmesan', 'Croutons']
        },
        {
          name: 'Pasta Carbonara',
          price: 320,
          imageUrl: 'https://images.unsplash.com/photo-1621996346565-e3dbc353d2e5?w=400&h=400&fit=crop',
          category: 'International',
          description: 'Classic Italian pasta with creamy carbonara sauce, bacon, parmesan cheese, and black pepper. Authentic Italian taste.',
          unit: '1 plate',
          deliveryTime: '30 mins',
          isAvailable: true,
          deliveryFee: 35,
          stock: 35,
          vendorId: thamelHouse._id,
          vendorType: 'restaurant',
          vendorSubType: 'international',
          isVegetarian: false,
          rating: 4.5,
          reviews: 78,
          tags: ['Pasta', 'Carbonara', 'Italian', 'Creamy', 'Bacon', 'Parmesan']
        },
        {
          name: 'Chicken Tikka Masala',
          price: 350,
          imageUrl: 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=400&h=400&fit=crop',
          category: 'Indian',
          description: 'Tender chicken in rich and creamy tomato-based curry. Served with basmati rice and naan bread. Popular Indian dish.',
          unit: '1 serving + rice + naan',
          deliveryTime: '25 mins',
          isAvailable: true,
          deliveryFee: 35,
          stock: 40,
          vendorId: thamelHouse._id,
          vendorType: 'restaurant',
          vendorSubType: 'international',
          isVegetarian: false,
          rating: 4.6,
          reviews: 89,
          isPopular: true,
          tags: ['Chicken', 'Tikka Masala', 'Indian', 'Creamy', 'Rice', 'Naan']
        }
      ];
      products.push(...thamelProducts);
    }

    // Newa Restaurant Products (Newari Cuisine)
    const newaRestaurant = restaurants.find(r => r.storeName === 'Newa Restaurant');
    if (newaRestaurant) {
      const newaProducts = [
        {
          name: 'Newari Khaja Set',
          price: 450,
          imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=400&h=400&fit=crop',
          category: 'Newari',
          description: 'Traditional Newari feast with choila, bara, chatamari, and other Newari delicacies. Cultural dining experience.',
          unit: '1 set',
          deliveryTime: '35 mins',
          isAvailable: true,
          deliveryFee: 40,
          stock: 25,
          vendorId: newaRestaurant._id,
          vendorType: 'restaurant',
          vendorSubType: 'newari',
          isVegetarian: false,
          rating: 4.8,
          reviews: 134,
          isFeatured: true,
          isBestSeller: true,
          tags: ['Newari', 'Khaja', 'Traditional', 'Cultural', 'Feast', 'Delicacies']
        },
        {
          name: 'Choila',
          price: 280,
          imageUrl: 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=400&h=400&fit=crop',
          category: 'Newari',
          description: 'Spicy grilled meat (buffalo/chicken) with traditional Newari spices. Served with beaten rice and pickles.',
          unit: '1 plate',
          deliveryTime: '25 mins',
          isAvailable: true,
          deliveryFee: 40,
          stock: 30,
          vendorId: newaRestaurant._id,
          vendorType: 'restaurant',
          vendorSubType: 'newari',
          isVegetarian: false,
          rating: 4.7,
          reviews: 98,
          isPopular: true,
          tags: ['Choila', 'Newari', 'Spicy', 'Grilled', 'Traditional', 'Beaten Rice']
        },
        {
          name: 'Bara',
          price: 180,
          imageUrl: 'https://images.unsplash.com/photo-1551504734-5ee1c4a1479b?w=400&h=400&fit=crop',
          category: 'Newari',
          description: 'Traditional Newari lentil pancake. Made from black lentils with herbs and spices. Served with chutney.',
          unit: '2 pieces',
          deliveryTime: '20 mins',
          isAvailable: true,
          deliveryFee: 40,
          stock: 35,
          vendorId: newaRestaurant._id,
          vendorType: 'restaurant',
          vendorSubType: 'newari',
          isVegetarian: true,
          rating: 4.5,
          reviews: 67,
          tags: ['Bara', 'Newari', 'Lentil', 'Pancake', 'Vegetarian', 'Traditional']
        }
      ];
      products.push(...newaProducts);
    }

    // Store Products
    console.log('\n🛒 Creating enhanced store products...');

    // Kathmandu Grocery Hub Products
    const groceryHub = stores.find(s => s.storeName === 'Kathmandu Grocery Hub');
    if (groceryHub) {
      const groceryProducts = [
        {
          name: 'Fresh Tomatoes',
          price: 120,
          imageUrl: 'https://images.unsplash.com/photo-1546094096-0df4bcaaa337?w=400&h=400&fit=crop',
          category: 'Vegetables',
          description: 'Fresh, ripe tomatoes from local farms. Perfect for cooking, salads, and sauces. Organic and pesticide-free.',
          unit: '1 kg',
          deliveryTime: '15 mins',
          isAvailable: true,
          deliveryFee: 20,
          stock: 100,
          vendorId: groceryHub._id,
          vendorType: 'store',
          vendorSubType: 'grocery',
          isVegetarian: true,
          rating: 4.6,
          reviews: 89,
          isPopular: true,
          dailyEssential: true,
          isFeaturedDailyEssential: true,
          tags: ['Tomatoes', 'Fresh', 'Organic', 'Local', 'Vegetables', 'Cooking']
        },
        {
          name: 'Basmati Rice',
          price: 180,
          imageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400&h=400&fit=crop',
          category: 'Grocery',
          description: 'Premium long-grain Basmati rice. Aromatic and fluffy when cooked. Perfect for biryani and pulao.',
          unit: '1 kg',
          deliveryTime: '15 mins',
          isAvailable: true,
          deliveryFee: 20,
          stock: 200,
          vendorId: groceryHub._id,
          vendorType: 'store',
          vendorSubType: 'grocery',
          isVegetarian: true,
          rating: 4.7,
          reviews: 156,
          isPopular: true,
          dailyEssential: true,
          isFeaturedDailyEssential: true,
          tags: ['Basmati', 'Rice', 'Premium', 'Aromatic', 'Long Grain', 'Cooking']
        },
        {
          name: 'Onions',
          price: 80,
          imageUrl: 'https://images.unsplash.com/photo-1518977676601-c53f82aba83c?w=400&h=400&fit=crop',
          category: 'Vegetables',
          description: 'Fresh red onions from local farms. Essential ingredient for cooking. Good quality and long shelf life.',
          unit: '1 kg',
          deliveryTime: '15 mins',
          isAvailable: true,
          deliveryFee: 20,
          stock: 150,
          vendorId: groceryHub._id,
          vendorType: 'store',
          vendorSubType: 'grocery',
          isVegetarian: true,
          rating: 4.4,
          reviews: 78,
          dailyEssential: true,
          isFeaturedDailyEssential: true,
          tags: ['Onions', 'Fresh', 'Local', 'Vegetables', 'Essential', 'Cooking']
        },
        // START: 10 New Grocery Products
        {
            name: 'Local Milk Pouch',
            price: 50,
            imageUrl: 'https://images.unsplash.com/photo-1559598467-f8b76c8155d0?w=400&h=400&fit=crop',
            category: 'Dairy',
            description: 'Fresh pasteurized milk from local dairy farms. Essential for your daily tea, coffee, and breakfast.',
            unit: '500 ml',
            deliveryTime: '10 mins',
            isAvailable: true,
            deliveryFee: 15,
            stock: 300,
            vendorId: groceryHub._id,
            vendorType: 'store',
            vendorSubType: 'grocery',
            rating: 4.8,
            reviews: 210,
            dailyEssential: true,
            isFeaturedDailyEssential: true,
            tags: ['Milk', 'Dairy', 'Fresh', 'Local', 'Essential']
        },
        {
            name: 'Plain Yogurt (Dahi)',
            price: 80,
            imageUrl: 'https://images.unsplash.com/photo-1562119428-562c5c938054?w=400&h=400&fit=crop',
            category: 'Dairy',
            description: 'Thick and creamy plain yogurt, locally known as Dahi. Perfect for meals, lassi, or as a side.',
            unit: '500g tub',
            deliveryTime: '10 mins',
            isAvailable: true,
            deliveryFee: 15,
            stock: 120,
            vendorId: groceryHub._id,
            vendorType: 'store',
            vendorSubType: 'grocery',
            rating: 4.7,
            reviews: 95,
            dailyEssential: true,
            tags: ['Yogurt', 'Dahi', 'Dairy', 'Probiotic', 'Fresh']
        },
        {
            name: 'Red Lentils (Masoor Dal)',
            price: 150,
            imageUrl: 'https://images.unsplash.com/photo-1583224964988-379a51197a1c?w=400&h=400&fit=crop',
            category: 'Grocery',
            description: 'High-quality red lentils, a staple in every Nepali kitchen for making dal.',
            unit: '1 kg',
            deliveryTime: '15 mins',
            isAvailable: true,
            deliveryFee: 20,
            stock: 180,
            vendorId: groceryHub._id,
            vendorType: 'store',
            vendorSubType: 'grocery',
            rating: 4.6,
            reviews: 115,
            dailyEssential: true,
            tags: ['Lentils', 'Dal', 'Masoor', 'Staple', 'Protein']
        },
        {
            name: 'Wai Wai Instant Noodles',
            price: 25,
            imageUrl: 'https://images.unsplash.com/photo-1621863110531-c5d6939591a2?w=400&h=400&fit=crop',
            category: 'Snacks',
            description: 'The iconic Nepali instant noodles. Can be eaten straight from the pack or cooked as a soup.',
            unit: '1 pack',
            deliveryTime: '10 mins',
            isAvailable: true,
            deliveryFee: 15,
            stock: 500,
            vendorId: groceryHub._id,
            vendorType: 'store',
            vendorSubType: 'grocery',
            rating: 4.9,
            reviews: 350,
            isPopular: true,
            tags: ['Wai Wai', 'Noodles', 'Instant', 'Snack', 'Nepali']
        },
        {
            name: 'Nepali Tea Leaves',
            price: 250,
            imageUrl: 'https://images.unsplash.com/photo-1576092762791-d02d23570949?w=400&h=400&fit=crop',
            category: 'Beverages',
            description: 'Aromatic black tea leaves sourced from the hills of Ilam. Perfect for a morning cup of Chiya.',
            unit: '250g pack',
            deliveryTime: '15 mins',
            isAvailable: true,
            deliveryFee: 20,
            stock: 80,
            vendorId: groceryHub._id,
            vendorType: 'store',
            vendorSubType: 'grocery',
            rating: 4.8,
            reviews: 130,
            tags: ['Tea', 'Chiya', 'Ilam Tea', 'Beverage', 'Aromatic']
        },
        {
            name: 'Potatoes',
            price: 60,
            imageUrl: 'https://images.unsplash.com/photo-1518977676601-134c5f3b3dae?w=400&h=400&fit=crop',
            category: 'Vegetables',
            description: 'Freshly harvested local potatoes. Versatile for curries, fries, and other dishes.',
            unit: '1 kg',
            deliveryTime: '15 mins',
            isAvailable: true,
            deliveryFee: 20,
            stock: 250,
            vendorId: groceryHub._id,
            vendorType: 'store',
            vendorSubType: 'grocery',
            rating: 4.5,
            reviews: 140,
            dailyEssential: true,
            tags: ['Potatoes', 'Vegetables', 'Local', 'Fresh', 'Aalu']
        },
        {
            name: 'Ginger',
            price: 40,
            imageUrl: 'https://images.unsplash.com/photo-1599940822984-a41e41208155?w=400&h=400&fit=crop',
            category: 'Vegetables',
            description: 'Fragrant and spicy ginger, an essential ingredient for Nepali cooking and herbal teas.',
            unit: '250 g',
            deliveryTime: '15 mins',
            isAvailable: true,
            deliveryFee: 20,
            stock: 150,
            vendorId: groceryHub._id,
            vendorType: 'store',
            vendorSubType: 'grocery',
            rating: 4.6,
            reviews: 88,
            dailyEssential: true,
            tags: ['Ginger', 'Spice', 'Fresh', 'Aduwa', 'Cooking']
        },
        {
            name: 'Garlic',
            price: 50,
            imageUrl: 'https://images.unsplash.com/photo-1587598282333-75f0a3a73c4f?w=400&h=400&fit=crop',
            category: 'Vegetables',
            description: 'Fresh cloves of garlic, indispensable for adding flavor to almost any savory dish.',
            unit: '250 g',
            deliveryTime: '15 mins',
            isAvailable: true,
            deliveryFee: 20,
            stock: 200,
            vendorId: groceryHub._id,
            vendorType: 'store',
            vendorSubType: 'grocery',
            rating: 4.7,
            reviews: 92,
            dailyEssential: true,
            tags: ['Garlic', 'Spice', 'Fresh', 'Lasun', 'Flavor']
        },
        {
            name: 'Sunflower Oil',
            price: 280,
            imageUrl: 'https://images.unsplash.com/photo-1626084087593-0187e05a81a1?w=400&h=400&fit=crop',
            category: 'Grocery',
            description: 'Refined sunflower oil for daily cooking. Light and healthy for all types of dishes.',
            unit: '1 litre pouch',
            deliveryTime: '15 mins',
            isAvailable: true,
            deliveryFee: 20,
            stock: 100,
            vendorId: groceryHub._id,
            vendorType: 'store',
            vendorSubType: 'grocery',
            rating: 4.5,
            reviews: 105,
            dailyEssential: true,
            tags: ['Oil', 'Cooking Oil', 'Sunflower', 'Grocery', 'Essential']
        },
        {
            name: 'Iodized Salt',
            price: 25,
            imageUrl: 'https://images.unsplash.com/photo-1599599810606-2c8365261895?w=400&h=400&fit=crop',
            category: 'Grocery',
            description: 'Fine iodized table salt. A fundamental seasoning for every meal.',
            unit: '1 kg pack',
            deliveryTime: '10 mins',
            isAvailable: true,
            deliveryFee: 15,
            stock: 400,
            vendorId: groceryHub._id,
            vendorType: 'store',
            vendorSubType: 'grocery',
            rating: 4.8,
            reviews: 180,
            dailyEssential: true,
            tags: ['Salt', 'Iodized Salt', 'Seasoning', 'Grocery', 'Noon']
        }
        // END: 10 New Grocery Products
      ];
      products.push(...groceryProducts);
    }

    // Thamel Electronics Products
    const thamelElectronics = stores.find(s => s.storeName === 'Thamel Electronics');
    if (thamelElectronics) {
      const electronicsProducts = [
        {
          name: 'iPhone Charging Cable',
          price: 450,
          imageUrl: 'https://images.unsplash.com/photo-1586953208448-b95a79798f07?w=400&h=400&fit=crop',
          category: 'Electronics',
          description: 'High-quality iPhone charging cable. Fast charging compatible. Durable and long-lasting. Original quality.',
          unit: '1 piece',
          deliveryTime: '20 mins',
          isAvailable: true,
          deliveryFee: 25,
          stock: 50,
          vendorId: thamelElectronics._id,
          vendorType: 'store',
          vendorSubType: 'electronics',
          rating: 4.3,
          reviews: 67,
          tags: ['iPhone', 'Charging Cable', 'Fast Charging', 'Durable', 'Original Quality']
        },
        {
          name: 'Bluetooth Headphones',
          price: 1200,
          imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400&h=400&fit=crop',
          category: 'Electronics',
          description: 'Wireless Bluetooth headphones with noise cancellation. High-quality sound and comfortable fit. Long battery life.',
          unit: '1 pair',
          deliveryTime: '20 mins',
          isAvailable: true,
          deliveryFee: 25,
          stock: 30,
          vendorId: thamelElectronics._id,
          vendorType: 'store',
          vendorSubType: 'electronics',
          rating: 4.5,
          reviews: 89,
          isPopular: true,
          tags: ['Bluetooth', 'Headphones', 'Wireless', 'Noise Cancellation', 'High Quality']
        },
        {
          name: 'Power Bank 10000mAh',
          price: 800,
          imageUrl: 'https://images.unsplash.com/photo-1609592806598-ef25c92f1a0c?w=400&h=400&fit=crop',
          category: 'Electronics',
          description: 'Portable power bank with 10000mAh capacity. Fast charging for mobile devices. Compact and lightweight.',
          unit: '1 piece',
          deliveryTime: '20 mins',
          isAvailable: true,
          deliveryFee: 25,
          stock: 40,
          vendorId: thamelElectronics._id,
          vendorType: 'store',
          vendorSubType: 'electronics',
          rating: 4.4,
          reviews: 56,
          tags: ['Power Bank', '10000mAh', 'Portable', 'Fast Charging', 'Compact']
        },
        // START: 5 New Electronics Products
        {
            name: 'Universal Travel Adapter',
            price: 600,
            imageUrl: 'https://images.unsplash.com/photo-1588114498826-1141c2535493?w=400&h=400&fit=crop',
            category: 'Accessories',
            description: 'All-in-one universal travel adapter, compatible with sockets in over 150 countries. A must-have for travelers.',
            unit: '1 piece',
            deliveryTime: '30 mins',
            isAvailable: true,
            deliveryFee: 25,
            stock: 60,
            vendorId: thamelElectronics._id,
            vendorType: 'store',
            vendorSubType: 'electronics',
            rating: 4.6,
            reviews: 75,
            tags: ['Adapter', 'Travel', 'Universal', 'Electronics']
        },
        {
            name: 'SanDisk 64GB MicroSD Card',
            price: 950,
            imageUrl: 'https://images.unsplash.com/photo-1585519289233-3558c386a34e?w=400&h=400&fit=crop',
            category: 'Storage',
            description: 'Class 10 SanDisk Ultra 64GB MicroSD card for phones and cameras. High-speed data transfer.',
            unit: '1 piece',
            deliveryTime: '20 mins',
            isAvailable: true,
            deliveryFee: 25,
            stock: 70,
            vendorId: thamelElectronics._id,
            vendorType: 'store',
            vendorSubType: 'electronics',
            rating: 4.7,
            reviews: 110,
            isPopular: true,
            tags: ['MicroSD', 'SanDisk', 'Storage', '64GB', 'Memory Card']
        },
        {
            name: 'Portable Bluetooth Speaker',
            price: 1500,
            imageUrl: 'https://images.unsplash.com/photo-1589256463836-4a4ec7355936?w=400&h=400&fit=crop',
            category: 'Audio',
            description: 'Compact and powerful portable speaker with deep bass. Waterproof and perfect for outdoor use.',
            unit: '1 piece',
            deliveryTime: '30 mins',
            isAvailable: true,
            deliveryFee: 25,
            stock: 25,
            vendorId: thamelElectronics._id,
            vendorType: 'store',
            vendorSubType: 'electronics',
            rating: 4.4,
            reviews: 62,
            tags: ['Speaker', 'Bluetooth', 'Portable', 'Waterproof', 'Audio']
        },
        {
            name: 'Smartphone Screen Protector',
            price: 300,
            imageUrl: 'https://images.unsplash.com/photo-1598327105553-761765c5f49b?w=400&h=400&fit=crop',
            category: 'Accessories',
            description: 'Tempered glass screen protector for various smartphone models. 9H hardness and scratch resistant.',
            unit: '1 piece',
            deliveryTime: '20 mins',
            isAvailable: true,
            deliveryFee: 25,
            stock: 150,
            vendorId: thamelElectronics._id,
            vendorType: 'store',
            vendorSubType: 'electronics',
            rating: 4.3,
            reviews: 98,
            tags: ['Screen Protector', 'Tempered Glass', 'Smartphone', 'Accessory']
        },
        {
            name: 'Basic Phone Case',
            price: 250,
            imageUrl: 'https://images.unsplash.com/photo-1618384887929-16ec33fab9ef?w=400&h=400&fit=crop',
            category: 'Accessories',
            description: 'Simple and durable transparent TPU phone case. Protects your phone from minor drops and scratches.',
            unit: '1 piece',
            deliveryTime: '20 mins',
            isAvailable: true,
            deliveryFee: 25,
            stock: 200,
            vendorId: thamelElectronics._id,
            vendorType: 'store',
            vendorSubType: 'electronics',
            rating: 4.2,
            reviews: 81,
            tags: ['Phone Case', 'TPU', 'Transparent', 'Smartphone', 'Accessory']
        }
        // END: 5 New Electronics Products
      ];
      products.push(...electronicsProducts);
    }

    // Boudha Pharmacy Products
    const boudhaPharmacy = stores.find(s => s.storeName === 'Boudha Pharmacy');
    if (boudhaPharmacy) {
      const pharmacyProducts = [
        {
          name: 'Paracetamol 500mg',
          price: 30,
          imageUrl: 'https://images.unsplash.com/photo-1588776814546-ec7e8c1b5b6b?w=400&h=400&fit=crop',
          category: 'Pharmacy',
          description: 'Pain relief tablets for fever and mild pain. Safe and effective. Available without prescription.',
          unit: '10 tablets',
          deliveryTime: '25 mins',
          isAvailable: true,
          deliveryFee: 15,
          stock: 200,
          vendorId: boudhaPharmacy._id,
          vendorType: 'store',
          vendorSubType: 'pharmacy',
          rating: 4.2,
          reviews: 45,
          tags: ['Paracetamol', 'Pain Relief', 'Fever', 'Safe', 'Effective']
        },
        {
          name: 'Vitamin C 1000mg',
          price: 150,
          imageUrl: 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=400&h=400&fit=crop',
          category: 'Pharmacy',
          description: 'High-dose Vitamin C supplements. Boosts immunity and overall health. Natural and safe.',
          unit: '30 tablets',
          deliveryTime: '25 mins',
          isAvailable: true,
          deliveryFee: 15,
          stock: 100,
          vendorId: boudhaPharmacy._id,
          vendorType: 'store',
          vendorSubType: 'pharmacy',
          rating: 4.5,
          reviews: 78,
          tags: ['Vitamin C', 'Immunity', 'Health', 'Natural', 'Safe', 'Supplements']
        },
        // START: 5 New Pharmacy Products
        {
            name: 'Hand Sanitizer (100ml)',
            price: 100,
            imageUrl: 'https://images.unsplash.com/photo-1584821499599-317737c3a033?w=400&h=400&fit=crop',
            category: 'Health',
            description: 'Alcohol-based hand sanitizer that kills 99.9% of germs. Travel-friendly size.',
            unit: '1 bottle',
            deliveryTime: '25 mins',
            isAvailable: true,
            deliveryFee: 15,
            stock: 300,
            vendorId: boudhaPharmacy._id,
            vendorType: 'store',
            vendorSubType: 'pharmacy',
            rating: 4.6,
            reviews: 150,
            tags: ['Sanitizer', 'Health', 'Hygiene', 'Germs']
        },
        {
            name: 'Surgical Face Masks',
            price: 100,
            imageUrl: 'https://images.unsplash.com/photo-1584481629539-a8c283574d32?w=400&h=400&fit=crop',
            category: 'Health',
            description: '3-ply surgical face masks for protection against dust, pollutants, and germs.',
            unit: 'Pack of 10',
            deliveryTime: '25 mins',
            isAvailable: true,
            deliveryFee: 15,
            stock: 500,
            vendorId: boudhaPharmacy._id,
            vendorType: 'store',
            vendorSubType: 'pharmacy',
            rating: 4.4,
            reviews: 180,
            tags: ['Face Mask', 'Surgical Mask', 'Protection', 'Health']
        },
        {
            name: 'Adhesive Bandages (Band-Aid)',
            price: 50,
            imageUrl: 'https://images.unsplash.com/photo-1600958932537-3323136c057b?w=400&h=400&fit=crop',
            category: 'First Aid',
            description: 'Waterproof adhesive bandages for minor cuts and scrapes. Assorted sizes.',
            unit: 'Box of 20',
            deliveryTime: '25 mins',
            isAvailable: true,
            deliveryFee: 15,
            stock: 250,
            vendorId: boudhaPharmacy._id,
            vendorType: 'store',
            vendorSubType: 'pharmacy',
            rating: 4.5,
            reviews: 65,
            tags: ['Bandage', 'First Aid', 'Cuts', 'Wound Care']
        },
        {
            name: 'Antiseptic Liquid',
            price: 80,
            imageUrl: 'https://images.unsplash.com/photo-1629783516585-35a11aa750d4?w=400&h=400&fit=crop',
            category: 'First Aid',
            description: 'Effective antiseptic disinfectant liquid for first aid, medical, and personal hygiene uses.',
            unit: '100ml bottle',
            deliveryTime: '25 mins',
            isAvailable: true,
            deliveryFee: 15,
            stock: 120,
            vendorId: boudhaPharmacy._id,
            vendorType: 'store',
            vendorSubType: 'pharmacy',
            rating: 4.7,
            reviews: 90,
            tags: ['Antiseptic', 'First Aid', 'Disinfectant', 'Hygiene']
        },
        {
            name: 'Cold Relief Balm',
            price: 60,
            imageUrl: 'https://images.unsplash.com/photo-1615056382173-982c75b78e14?w=400&h=400&fit=crop',
            category: 'Wellness',
            description: 'Soothing balm for relief from cold, cough, and headache. Vicks VapoRub alternative.',
            unit: '25g jar',
            deliveryTime: '25 mins',
            isAvailable: true,
            deliveryFee: 15,
            stock: 180,
            vendorId: boudhaPharmacy._id,
            vendorType: 'store',
            vendorSubType: 'pharmacy',
            rating: 4.6,
            reviews: 112,
            tags: ['Cold Relief', 'Balm', 'Headache', 'Wellness']
        }
        // END: 5 New Pharmacy Products
      ];
      products.push(...pharmacyProducts);
    }
    
    // START: Patan Handicrafts Products (NEW STORE)
    const patanHandicrafts = stores.find(s => s.storeName === 'Patan Handicrafts');
    if (patanHandicrafts) {
      const patanHandicraftsProducts = [
        {
          name: 'Tibetan Singing Bowl',
          price: 2500,
          imageUrl: 'https://images.unsplash.com/photo-1542823683-5b71a4697148?w=400&h=400&fit=crop',
          category: 'Handicrafts',
          description: 'Hand-hammered 7-metal singing bowl for meditation and healing. Comes with a mallet and cushion.',
          unit: '1 set',
          deliveryTime: '45 mins',
          isAvailable: true,
          deliveryFee: 50,
          stock: 20,
          vendorId: patanHandicrafts._id,
          vendorType: 'store',
          vendorSubType: 'handicrafts',
          rating: 4.9,
          reviews: 85,
          isFeatured: true,
          tags: ['Singing Bowl', 'Handmade', 'Meditation', 'Healing', 'Handicraft']
        },
        {
          name: 'Pashmina Shawl',
          price: 4500,
          imageUrl: 'https://images.unsplash.com/photo-1588665512351-229c3270932c?w=400&h=400&fit=crop',
          category: 'Apparel',
          description: 'Genuine, hand-woven pashmina shawl from the Himalayas. Incredibly soft, light, and warm.',
          unit: '1 piece',
          deliveryTime: '45 mins',
          isAvailable: true,
          deliveryFee: 50,
          stock: 30,
          vendorId: patanHandicrafts._id,
          vendorType: 'store',
          vendorSubType: 'handicrafts',
          rating: 4.8,
          reviews: 120,
          isPopular: true,
          tags: ['Pashmina', 'Shawl', 'Handmade', 'Luxury', 'Wool']
        },
        {
          name: 'Buddhist Prayer Flags',
          price: 300,
          imageUrl: 'https://images.unsplash.com/photo-1541854581428-2a9b5f54313f?w=400&h=400&fit=crop',
          category: 'Decor',
          description: 'Set of traditional Tibetan prayer flags (Lung Ta). Promotes peace, compassion, and wisdom.',
          unit: '1 roll (10 flags)',
          deliveryTime: '30 mins',
          isAvailable: true,
          deliveryFee: 40,
          stock: 100,
          vendorId: patanHandicrafts._id,
          vendorType: 'store',
          vendorSubType: 'handicrafts',
          rating: 4.7,
          reviews: 150,
          tags: ['Prayer Flags', 'Tibetan', 'Spiritual', 'Decor', 'Peace']
        },
        {
          name: 'Thangka Painting',
          price: 8000,
          imageUrl: 'https://images.unsplash.com/photo-1615529182903-31b645511e40?w=400&h=400&fit=crop',
          category: 'Art',
          description: 'Intricate, hand-painted Thangka depicting Buddhist deities. A beautiful piece of spiritual art.',
          unit: '1 painting',
          deliveryTime: '60 mins',
          isAvailable: true,
          deliveryFee: 80,
          stock: 10,
          vendorId: patanHandicrafts._id,
          vendorType: 'store',
          vendorSubType: 'handicrafts',
          rating: 4.9,
          reviews: 45,
          isFeatured: true,
          tags: ['Thangka', 'Art', 'Buddhist', 'Hand-painted', 'Spiritual']
        },
        {
          name: 'Wooden Mask of Bhairav',
          price: 1800,
          imageUrl: 'https://images.unsplash.com/photo-1519799634282-e3e1bcb4351b?w=400&h=400&fit=crop',
          category: 'Decor',
          description: 'Hand-carved wooden mask of the fierce deity Bhairav. A powerful cultural artifact for wall decor.',
          unit: '1 piece',
          deliveryTime: '45 mins',
          isAvailable: true,
          deliveryFee: 50,
          stock: 25,
          vendorId: patanHandicrafts._id,
          vendorType: 'store',
          vendorSubType: 'handicrafts',
          rating: 4.6,
          reviews: 55,
          tags: ['Mask', 'Wooden', 'Hand-carved', 'Bhairav', 'Cultural']
        },
        {
          name: 'Lokta Paper Journal',
          price: 400,
          imageUrl: 'https://images.unsplash.com/photo-1516410529-223657114227?w=400&h=400&fit=crop',
          category: 'Stationery',
          description: 'Eco-friendly journal made from traditional, handmade Lokta paper. Durable and unique.',
          unit: '1 journal',
          deliveryTime: '30 mins',
          isAvailable: true,
          deliveryFee: 40,
          stock: 80,
          vendorId: patanHandicrafts._id,
          vendorType: 'store',
          vendorSubType: 'handicrafts',
          rating: 4.5,
          reviews: 95,
          tags: ['Lokta', 'Journal', 'Handmade', 'Eco-friendly', 'Stationery']
        },
        {
            name: 'Gorkha Khukuri (Small)',
            price: 2200,
            imageUrl: 'https://images.unsplash.com/photo-1629438031579-98a8c48737c3?w=400&h=400&fit=crop',
            category: 'Souvenir',
            description: 'A small, decorative version of the famous Gorkha Khukuri knife. A symbol of bravery.',
            unit: '1 piece with scabbard',
            deliveryTime: '45 mins',
            isAvailable: true,
            deliveryFee: 50,
            stock: 15,
            vendorId: patanHandicrafts._id,
            vendorType: 'store',
            vendorSubType: 'handicrafts',
            rating: 4.8,
            reviews: 60,
            tags: ['Khukuri', 'Gorkha', 'Knife', 'Souvenir', 'Nepalese']
        },
        {
            name: 'Bronze Buddha Statue',
            price: 3500,
            imageUrl: 'https://images.unsplash.com/photo-1602732389437-0092e071676f?w=400&h=400&fit=crop',
            category: 'Decor',
            description: 'Finely cast bronze statue of the Buddha in a meditative pose. Perfect for home or office altar.',
            unit: '1 statue (6 inch)',
            deliveryTime: '60 mins',
            isAvailable: true,
            deliveryFee: 60,
            stock: 18,
            vendorId: patanHandicrafts._id,
            vendorType: 'store',
            vendorSubType: 'handicrafts',
            rating: 4.9,
            reviews: 35,
            tags: ['Buddha', 'Statue', 'Bronze', 'Spiritual', 'Decor']
        },
        {
            name: 'Hemp Side Bag',
            price: 900,
            imageUrl: 'https://images.unsplash.com/photo-1618928373322-a1b69d82a155?w=400&h=400&fit=crop',
            category: 'Bags',
            description: 'Durable and stylish side bag made from natural Himalayan hemp fiber. Eco-friendly and practical.',
            unit: '1 bag',
            deliveryTime: '30 mins',
            isAvailable: true,
            deliveryFee: 40,
            stock: 50,
            vendorId: patanHandicrafts._id,
            vendorType: 'store',
            vendorSubType: 'handicrafts',
            rating: 4.6,
            reviews: 110,
            isPopular: true,
            tags: ['Hemp', 'Bag', 'Eco-friendly', 'Natural', 'Fashion']
        },
        {
            name: 'Felt Wool Dryer Balls',
            price: 500,
            imageUrl: 'https://images.unsplash.com/photo-1629822432671-b0cd3f53833b?w=400&h=400&fit=crop',
            category: 'Household',
            description: 'Set of colorful, handmade felt wool balls. A natural, reusable alternative to dryer sheets.',
            unit: 'Set of 4',
            deliveryTime: '30 mins',
            isAvailable: true,
            deliveryFee: 40,
            stock: 60,
            vendorId: patanHandicrafts._id,
            vendorType: 'store',
            vendorSubType: 'handicrafts',
            rating: 4.7,
            reviews: 70,
            tags: ['Felt', 'Wool', 'Handmade', 'Eco-friendly', 'Household']
        }
      ];
      products.push(...patanHandicraftsProducts);
    }
    // END: Patan Handicrafts Products
    
    // START: Asan Bazaar Spices Products (NEW STORE)
    const asanSpices = stores.find(s => s.storeName === 'Asan Bazaar Spices');
    if (asanSpices) {
      const asanSpicesProducts = [
        {
          name: 'Timur (Sichuan Pepper)',
          price: 150,
          imageUrl: 'https://images.unsplash.com/photo-1509358175988-92923b49e1a7?w=400&h=400&fit=crop',
          category: 'Spices',
          description: 'Authentic Nepali Timur with a unique citrusy and numbing flavor. Perfect for pickles and choila.',
          unit: '50g pack',
          deliveryTime: '20 mins',
          isAvailable: true,
          deliveryFee: 25,
          stock: 100,
          vendorId: asanSpices._id,
          vendorType: 'store',
          vendorSubType: 'spices',
          rating: 4.9,
          reviews: 90,
          isPopular: true,
          tags: ['Timur', 'Sichuan Pepper', 'Spice', 'Nepali', 'Authentic']
        },
        {
          name: 'Turmeric Powder',
          price: 80,
          imageUrl: 'https://images.unsplash.com/photo-1596700247169-2a4c1071d5b8?w=400&h=400&fit=crop',
          category: 'Spices',
          description: 'Vibrant and earthy turmeric powder (Besar). A fundamental spice in Nepali cooking with health benefits.',
          unit: '200g pack',
          deliveryTime: '20 mins',
          isAvailable: true,
          deliveryFee: 25,
          stock: 200,
          vendorId: asanSpices._id,
          vendorType: 'store',
          vendorSubType: 'spices',
          rating: 4.7,
          reviews: 120,
          tags: ['Turmeric', 'Besar', 'Spice', 'Cooking', 'Healthy']
        },
        {
          name: 'Cumin Powder',
          price: 90,
          imageUrl: 'https://images.unsplash.com/photo-1600742416889-9a74202a8296?w=400&h=400&fit=crop',
          category: 'Spices',
          description: 'Ground cumin (Jeera). Aromatic and essential for tempering dals and flavoring vegetable curries.',
          unit: '200g pack',
          deliveryTime: '20 mins',
          isAvailable: true,
          deliveryFee: 25,
          stock: 180,
          vendorId: asanSpices._id,
          vendorType: 'store',
          vendorSubType: 'spices',
          rating: 4.6,
          reviews: 115,
          tags: ['Cumin', 'Jeera', 'Spice', 'Aromatic', 'Cooking']
        },
        {
          name: 'Coriander Powder',
          price: 85,
          imageUrl: 'https://images.unsplash.com/photo-1590318997203-87588803c46a?w=400&h=400&fit=crop',
          category: 'Spices',
          description: 'Mild and fragrant ground coriander (Dhaniya). A base spice for most Nepali and Indian curries.',
          unit: '200g pack',
          deliveryTime: '20 mins',
          isAvailable: true,
          deliveryFee: 25,
          stock: 190,
          vendorId: asanSpices._id,
          vendorType: 'store',
          vendorSubType: 'spices',
          rating: 4.6,
          reviews: 105,
          tags: ['Coriander', 'Dhaniya', 'Spice', 'Fragrant', 'Curry']
        },
        {
          name: 'Garam Masala Mix',
          price: 180,
          imageUrl: 'https://images.unsplash.com/photo-1599599810606-2c8365261895?w=400&h=400&fit=crop',
          category: 'Spice Blends',
          description: 'A traditional blend of aromatic warming spices. Adds a final touch of flavor to dishes.',
          unit: '100g pack',
          deliveryTime: '20 mins',
          isAvailable: true,
          deliveryFee: 25,
          stock: 90,
          vendorId: asanSpices._id,
          vendorType: 'store',
          vendorSubType: 'spices',
          rating: 4.8,
          reviews: 80,
          tags: ['Garam Masala', 'Spice Blend', 'Aromatic', 'Cooking']
        },
        {
          name: 'Cinnamon Sticks',
          price: 120,
          imageUrl: 'https://images.unsplash.com/photo-1555982364-aab4ac2853c0?w=400&h=400&fit=crop',
          category: 'Spices',
          description: 'Whole cinnamon bark (Dalchini). Used in savory dishes like pulao and sweet dishes like kheer.',
          unit: '50g pack',
          deliveryTime: '20 mins',
          isAvailable: true,
          deliveryFee: 25,
          stock: 110,
          vendorId: asanSpices._id,
          vendorType: 'store',
          vendorSubType: 'spices',
          rating: 4.7,
          reviews: 65,
          tags: ['Cinnamon', 'Dalchini', 'Spice', 'Whole Spice', 'Aromatic']
        },
        {
            name: 'Green Cardamom',
            price: 250,
            imageUrl: 'https://images.unsplash.com/photo-1556999238-d93a4a69151c?w=400&h=400&fit=crop',
            category: 'Spices',
            description: 'Whole green cardamom pods (Sukumel). Highly aromatic, used in teas, sweets, and biryanis.',
            unit: '50g pack',
            deliveryTime: '20 mins',
            isAvailable: true,
            deliveryFee: 25,
            stock: 80,
            vendorId: asanSpices._id,
            vendorType: 'store',
            vendorSubType: 'spices',
            rating: 4.9,
            reviews: 75,
            tags: ['Cardamom', 'Sukumel', 'Spice', 'Aromatic', 'Whole Spice']
        },
        {
            name: 'Cloves',
            price: 130,
            imageUrl: 'https://images.unsplash.com/photo-1508623091924-34c2a3b04a18?w=400&h=400&fit=crop',
            category: 'Spices',
            description: 'Dried flower buds of clove (Lwang). Strong, sweet, and pungent, used in many spice blends.',
            unit: '50g pack',
            deliveryTime: '20 mins',
            isAvailable: true,
            deliveryFee: 25,
            stock: 120,
            vendorId: asanSpices._id,
            vendorType: 'store',
            vendorSubType: 'spices',
            rating: 4.7,
            reviews: 50,
            tags: ['Cloves', 'Lwang', 'Spice', 'Aromatic', 'Whole Spice']
        },
        {
            name: 'Dry Red Chilies',
            price: 100,
            imageUrl: 'https://images.unsplash.com/photo-1582106225885-c5432d6994cb?w=400&h=400&fit=crop',
            category: 'Spices',
            description: 'Whole dried red chilies. Adds heat and color to dishes. Can be used whole or ground.',
            unit: '100g pack',
            deliveryTime: '20 mins',
            isAvailable: true,
            deliveryFee: 25,
            stock: 150,
            vendorId: asanSpices._id,
            vendorType: 'store',
            vendorSubType: 'spices',
            rating: 4.5,
            reviews: 85,
            tags: ['Chili', 'Red Chili', 'Spice', 'Hot', 'Dry']
        },
        {
            name: 'Asafoetida (Hing)',
            price: 90,
            imageUrl: 'https://images.unsplash.com/photo-1615281318210-6a165d491a13?w=400&h=400&fit=crop',
            category: 'Spices',
            description: 'A pungent resinous gum used in small quantities to add a unique, savory flavor to lentil dishes.',
            unit: '10g box',
            deliveryTime: '20 mins',
            isAvailable: true,
            deliveryFee: 25,
            stock: 100,
            vendorId: asanSpices._id,
            vendorType: 'store',
            vendorSubType: 'spices',
            rating: 4.4,
            reviews: 40,
            tags: ['Asafoetida', 'Hing', 'Spice', 'Pungent', 'Savory']
        }
      ];
      products.push(...asanSpicesProducts);
    }
    // END: Asan Bazaar Spices Products
    
    // START: Thamel Book World Products (NEW STORE)
    const thamelBooks = stores.find(s => s.storeName === 'Thamel Book World');
    if (thamelBooks) {
      const thamelBookProducts = [
        {
          name: 'Into Thin Air by Jon Krakauer',
          price: 800,
          imageUrl: 'https://images.unsplash.com/photo-1589998059171-988d887df646?w=400&h=400&fit=crop',
          category: 'Books',
          description: 'A personal account of the 1996 Mount Everest disaster. A gripping non-fiction bestseller.',
          unit: '1 paperback',
          deliveryTime: '40 mins',
          isAvailable: true,
          deliveryFee: 30,
          stock: 40,
          vendorId: thamelBooks._id,
          vendorType: 'store',
          vendorSubType: 'books',
          rating: 4.9,
          reviews: 150,
          isPopular: true,
          tags: ['Book', 'Everest', 'Non-fiction', 'Adventure', 'Bestseller']
        },
        {
          name: 'Kathmandu Valley Travel Guide',
          price: 650,
          imageUrl: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&h=400&fit=crop',
          category: 'Books',
          description: 'A comprehensive travel guide covering the heritage sites, temples, and culture of Kathmandu Valley.',
          unit: '1 paperback',
          deliveryTime: '40 mins',
          isAvailable: true,
          deliveryFee: 30,
          stock: 60,
          vendorId: thamelBooks._id,
          vendorType: 'store',
          vendorSubType: 'books',
          rating: 4.7,
          reviews: 80,
          tags: ['Book', 'Travel Guide', 'Kathmandu', 'Nepal', 'Tourism']
        },
        {
          name: 'Palpasa Cafe by Narayan Wagle',
          price: 500,
          imageUrl: 'https://images.unsplash.com/photo-1532012197267-da84d127e765?w=400&h=400&fit=crop',
          category: 'Books',
          description: 'An acclaimed Nepali novel set during the Maoist insurgency. A modern classic of Nepali literature.',
          unit: '1 paperback (English)',
          deliveryTime: '40 mins',
          isAvailable: true,
          deliveryFee: 30,
          stock: 50,
          vendorId: thamelBooks._id,
          vendorType: 'store',
          vendorSubType: 'books',
          rating: 4.8,
          reviews: 110,
          tags: ['Book', 'Nepali Literature', 'Novel', 'Fiction', 'Classic']
        },
        {
            name: 'Annapurna by Maurice Herzog',
            price: 750,
            imageUrl: 'https://images.unsplash.com/photo-1454496522488-7a8e488e8606?w=400&h=400&fit=crop',
            category: 'Books',
            description: 'The legendary first-hand account of the first-ever ascent of an 8,000-meter peak in 1950.',
            unit: '1 paperback',
            deliveryTime: '40 mins',
            isAvailable: true,
            deliveryFee: 30,
            stock: 35,
            vendorId: thamelBooks._id,
            vendorType: 'store',
            vendorSubType: 'books',
            rating: 4.8,
            reviews: 95,
            tags: ['Book', 'Annapurna', 'Mountaineering', 'Classic', 'Adventure']
        },
        {
            name: 'Basic Nepali Language Guide',
            price: 400,
            imageUrl: 'https://images.unsplash.com/photo-1521587760476-6c12a4b040da?w=400&h=400&fit=crop',
            category: 'Books',
            description: 'An easy-to-use phrasebook and dictionary for tourists and learners. Covers essential phrases and vocabulary.',
            unit: '1 paperback',
            deliveryTime: '40 mins',
            isAvailable: true,
            deliveryFee: 30,
            stock: 70,
            vendorId: thamelBooks._id,
            vendorType: 'store',
            vendorSubType: 'books',
            rating: 4.5,
            reviews: 65,
            tags: ['Book', 'Language', 'Nepali', 'Phrasebook', 'Learning']
        }
      ];
      products.push(...thamelBookProducts);
    }
    // END: Thamel Book World Products
    
    // START: Swayambhu Organics Products (NEW STORE)
    const swayambhuOrganics = stores.find(s => s.storeName === 'Swayambhu Organics');
    if (swayambhuOrganics) {
      const swayambhuOrganicsProducts = [
        {
          name: 'Wild Forest Honey',
          price: 700,
          imageUrl: 'https://images.unsplash.com/photo-1558642452-9d2a7deb7f62?w=400&h=400&fit=crop',
          category: 'Organic Foods',
          description: 'Raw, unprocessed honey collected from the wild forests of Nepal. Rich in antioxidants and flavor.',
          unit: '500g jar',
          deliveryTime: '35 mins',
          isAvailable: true,
          deliveryFee: 35,
          stock: 40,
          vendorId: swayambhuOrganics._id,
          vendorType: 'store',
          vendorSubType: 'organics',
          rating: 4.9,
          reviews: 130,
          isPopular: true,
          tags: ['Honey', 'Organic', 'Raw', 'Natural', 'Healthy']
        },
        {
          name: 'Organic Herbal Tea Blend',
          price: 450,
          imageUrl: 'https://images.unsplash.com/photo-1591543623299-961a7a043c7b?w=400&h=400&fit=crop',
          category: 'Beverages',
          description: 'A soothing blend of organic herbs like chamomile, mint, and lemongrass from the Nepali hills.',
          unit: '100g loose leaf',
          deliveryTime: '35 mins',
          isAvailable: true,
          deliveryFee: 35,
          stock: 60,
          vendorId: swayambhuOrganics._id,
          vendorType: 'store',
          vendorSubType: 'organics',
          rating: 4.8,
          reviews: 88,
          tags: ['Herbal Tea', 'Organic', 'Wellness', 'Beverage', 'Natural']
        },
        {
          name: 'Jumla Brown Rice',
          price: 250,
          imageUrl: 'https://images.unsplash.com/photo-1560781290-7dc58695ae07?w=400&h=400&fit=crop',
          category: 'Grains',
          description: 'Nutritious and fiber-rich brown rice grown in the high-altitude region of Jumla, Nepal.',
          unit: '1 kg pack',
          deliveryTime: '35 mins',
          isAvailable: true,
          deliveryFee: 35,
          stock: 70,
          vendorId: swayambhuOrganics._id,
          vendorType: 'store',
          vendorSubType: 'organics',
          rating: 4.7,
          reviews: 75,
          tags: ['Brown Rice', 'Organic', 'Jumla', 'Healthy', 'Grains']
        },
        {
          name: 'Organic Chia Seeds',
          price: 350,
          imageUrl: 'https://images.unsplash.com/photo-1485962398741-25582c03510e?w=400&h=400&fit=crop',
          category: 'Superfoods',
          description: 'Packed with omega-3, fiber, and protein. Add to smoothies, yogurt, or make chia pudding.',
          unit: '200g pack',
          deliveryTime: '35 mins',
          isAvailable: true,
          deliveryFee: 35,
          stock: 50,
          vendorId: swayambhuOrganics._id,
          vendorType: 'store',
          vendorSubType: 'organics',
          rating: 4.8,
          reviews: 92,
          tags: ['Chia Seeds', 'Organic', 'Superfood', 'Healthy', 'Vegan']
        },
        {
          name: 'Cold-Pressed Mustard Oil',
          price: 400,
          imageUrl: 'https://images.unsplash.com/photo-1596205244514-94e8c186b976?w=400&h=400&fit=crop',
          category: 'Oils',
          description: 'Traditional Nepali mustard oil, cold-pressed to retain its natural pungency, flavor, and nutrients.',
          unit: '500ml bottle',
          deliveryTime: '35 mins',
          isAvailable: true,
          deliveryFee: 35,
          stock: 45,
          vendorId: swayambhuOrganics._id,
          vendorType: 'store',
          vendorSubType: 'organics',
          rating: 4.6,
          reviews: 68,
          tags: ['Mustard Oil', 'Cold-Pressed', 'Organic', 'Cooking Oil', 'Traditional']
        }
      ];
      products.push(...swayambhuOrganicsProducts);
    }
    // END: Swayambhu Organics Products

    // Create all products
    console.log(`\n📦 Creating ${products.length} products...`);
    for (const productData of products) {
      const product = new Product(productData);
      await product.save();
      console.log(`✅ Created: ${product.name} (${product.category})`);
    }

    console.log('\n🎉 Enhanced Kathmandu products creation completed!');
    console.log(`Total products created: ${products.length}`);
    
    // Show category distribution
    const categories = [...new Set(products.map(p => p.category))];
    console.log('\n📊 Categories created:');
    categories.sort().forEach(category => {
      const count = products.filter(p => p.category === category).length;
      console.log(`- ${category}: ${count} products`);
    });

    process.exit(0);
  } catch (error) {
    console.error('❌ Error creating products:', error);
    process.exit(1);
  }
};

createKathmanduProducts();