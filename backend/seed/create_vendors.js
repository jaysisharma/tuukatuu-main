const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const axios = require('axios');
require('dotenv').config();

const User = require('../src/models/User');

const UNSPLASH_ACCESS_KEY = '5gPGJb38uilRKlIyI1DsZ2-UIwDDN2JwcmB3JMrzEeo';

const MONGODB_URI = 'mongodb://localhost:27017/first_db211';

mongoose.connect(MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

const fetchUnsplashImage = async (query) => {
  if (!UNSPLASH_ACCESS_KEY) {
    console.warn("Unsplash API key not set. Using placeholder image.");
    return 'https://placehold.co/600x400?text=Image+Not+Available';
  }

  try {
    const response = await axios.get('https://api.unsplash.com/photos/random', {
      params: {
        query: query,
        orientation: 'landscape',
        content_filter: 'high',
      },
      headers: {
        Authorization: `Client-ID ${UNSPLASH_ACCESS_KEY}`,
      },
    });

    const imageUrl = response.data.urls.regular;
    console.log(`Fetched image for '${query}': ${imageUrl}`);
    return imageUrl;
  } catch (error) {
    console.error(`Error fetching image for query '${query}':`, error.message);
    return 'https://placehold.co/600x400?text=Image+Unavailable';
  }
};

const generateDescription = (type, subType) => {
  const descriptions = {
    'restaurant': {
      'chinese': "Authentic Chinese cuisine with flavorful dishes and traditional cooking methods.",
      'italian': "Experience the taste of Italy with our delicious pasta, pizza, and more.",
      'nepali': "Savor the rich flavors of Nepal with traditional dishes like momos and dal bhat.",
      'indian': "Aromatic spices and vibrant flavors define our authentic Indian menu.",
      'fast_food': "Quick, convenient, and satisfying meals for busy lifestyles.",
      'thai': "Spicy, sour, and sweet - enjoy the bold flavors of Thailand."
    },
    'store': {
      'pharmacy': "Your trusted source for medications, health products, and wellness advice.",
      'grocery': "Fresh produce, quality goods, and everything you need under one roof.",
      'supermarket': "Your one-stop shop for groceries, household items, and everyday essentials.",
      'organic_market': "Fresh, organic produce and natural products for a healthy lifestyle.",
      'drugstore': "Essential medicines, health products, and daily necessities.",
      'wellness_shop': "Products for health, beauty, and overall well-being.",
    },
    'cafe': {
      'bakery': "Freshly baked breads, pastries, and sweets made with love every day.",
      'coffee': "Premium coffee beans expertly roasted and brewed for the perfect cup.",
      'tea': "A cozy spot for a wide selection of teas and light refreshments.",
      'pastry': "Delicious pastries, cakes, and sweet treats baked fresh daily.",
    },
    'service': {
      'cleaning': "Professional cleaning services to keep your home or office spotless.",
      'home_repair': "Reliable and skilled professionals for all your home maintenance needs.",
      'laundry': "Convenient laundry and dry cleaning services.",
      'photography': "Capturing life's precious moments with creativity and skill.",
      'plumbing': "Expert plumbing services for repairs, installations, and maintenance.",
      'electrical': "Licensed electricians for safe and efficient electrical work.",
      'carpentry': "Custom carpentry and woodworking solutions for your home.",
      'pest_control': "Effective pest control services to protect your property.",
    }
  };

  if (descriptions[type] && descriptions[type][subType]) {
    return descriptions[type][subType];
  }
  const genericDescriptions = {
    'restaurant': 'Serving delicious and authentic cuisine with a focus on fresh ingredients and customer satisfaction.',
    'store': 'Your local store offering a variety of essential goods and services.',
    'cafe': 'A welcoming cafe perfect for relaxing, meeting friends, or enjoying great coffee and treats.',
    'service': 'Providing reliable and professional services tailored to your needs.',
  };
  return genericDescriptions[type] || 'A great place to visit!';
};

const generateRandomData = async (type, subType, index) => {
  const names = {
    'restaurant': ['Spice Hub', 'The Italian Spoon', 'Golden Wok', 'Burger Palace', 'Taste of India', 'Mexican Fiesta', 'Mediterranean Grill', 'Sushi House', 'Vegan Delight', 'Seafood Shack', 'Pizzaiolo', 'Grill Masters', 'Noodle Bar', 'The Goulash House', 'Curry Kingdom'],
    'store': ['Fresh Finds', 'Daily Essentials', 'Quick Mart', 'Tech Universe', 'Home Goods', 'Fashion Avenue', 'Book Nook', 'Pet Paradise', 'Artisan Crafts', 'Wellness Pharmacy', 'Flower Power', 'Sports Zone', 'Toy Kingdom', 'Stationery Stop', 'Garden Supply Co'],
    'cafe': ['The Daily Grind', 'Brew & Bloom', 'Corner Cafe', 'The Coffee Bean', 'Mellow Mug', 'Sunrise Sips', 'Sweet Spot', 'The Tea Leaf', 'Urban Grind', 'Pastry Paradise', 'The Crumbly Corner', 'Flour Power Bakery', 'Sweet Sensations'],
    'service': ['Quick Fix Handyman', 'Pro-Clean Services', 'Mobile Mechanic', 'Pet Grooming Express', 'Home Laundry', 'Tech Support Pros', 'Gardening Gurus', 'Event Planners', 'Photography Studio', 'Fitness First', 'Sparky Electric', 'Pipe Masters', 'Wood Works', 'Critter Control']
  };

  let imageQuery = `${subType} ${type}`;
  if (type === 'store' && (subType === 'grocery' || subType === 'supermarket' || subType === 'organic_market')) {
    imageQuery = 'grocery store';
  } else if (type === 'store' && (subType === 'pharmacy' || subType === 'drugstore' || subType === 'wellness_shop')) {
    imageQuery = 'pharmacy store front';
  } else if (type === 'cafe' && subType === 'bakery') {
    imageQuery = 'bakery shop';
  } else if (type === 'cafe' && subType === 'pastry') {
    imageQuery = 'pastry cafe';
  } else if (type === 'service' && subType === 'plumbing') {
    imageQuery = 'plumber at work';
  } else if (type === 'service' && subType === 'electrical') {
    imageQuery = 'electrician working';
  } else if (type === 'service' && subType === 'carpentry') {
    imageQuery = 'carpenter workshop';
  } else if (type === 'service' && subType === 'pest_control') {
    imageQuery = 'pest control service';
  }

  const [storeImage, storeBanner] = await Promise.all([
    fetchUnsplashImage(imageQuery),
    fetchUnsplashImage(`${imageQuery} interior`)
  ]);

  const storeName = names[type][index % names[type].length];
  const storeDescription = generateDescription(type, subType);

  return {
    name: storeName,
    email: `${storeName.toLowerCase().replace(/[^a-z0-9]/g, '')}${index}@${type}.com`,
    phone: `9800000${(100 + index).toString().padStart(3, '0')}`,
    role: 'vendor',
    vendorType: type,
    vendorSubType: subType,
    storeName: storeName,
    storeDescription: storeDescription,
    storeImage: storeImage,
    storeBanner: storeBanner,
    storeTags: [subType, type, 'quality', 'local'],
    storeCategories: [type, subType],
    storeRating: (Math.random() * (5.0 - 4.0) + 4.0).toFixed(1),
    storeReviews: Math.floor(Math.random() * 1000) + 100,
    isFeatured: Math.random() > 0.7,
    storeCoordinates: {
      type: 'Point',
      coordinates: [
        85.3 + (Math.random() * 0.5), // longitude
        27.7 + (Math.random() * 0.5)  // latitude
      ]
    },
    storeAddress: ['Thamel, Kathmandu', 'Baneshwor, Kathmandu', 'Patan, Lalitpur', 'Boudha, Kathmandu', 'Bhaktapur'][Math.floor(Math.random() * 5)],
  };
};

const createVendors = async () => {
  try {
    console.log('🏪 Creating 100 vendors with different types...');
    const vendorDataArray = [];
    // 20 Restaurants
    const restaurantSubtypes = ['chinese', 'italian', 'nepali', 'indian', 'fast_food', 'thai'];
    for (let i = 0; i < 20; i++) {
      const subType = restaurantSubtypes[i % restaurantSubtypes.length];
      vendorDataArray.push(await generateRandomData('restaurant', subType, i));
    }
    // 20 Stores
    const storeSubtypes = ['grocery', 'supermarket', 'organic_market'];
    for (let i = 0; i < 20; i++) {
      const subType = storeSubtypes[i % storeSubtypes.length];
      vendorDataArray.push(await generateRandomData('store', subType, i + 20));
    }
    // 20 Pharmacies
    const pharmacySubtypes = ['pharmacy', 'drugstore', 'wellness_shop'];
    for (let i = 0; i < 20; i++) {
      const subType = pharmacySubtypes[i % pharmacySubtypes.length];
      vendorDataArray.push(await generateRandomData('store', subType, i + 40));
    }
    // 20 Cafes
    const cafeSubtypes = ['coffee', 'tea', 'bakery', 'pastry'];
    for (let i = 0; i < 20; i++) {
      const subType = cafeSubtypes[i % cafeSubtypes.length];
      vendorDataArray.push(await generateRandomData('cafe', subType, i + 60));
    }
    // 20 Service Providers
    const serviceSubtypes = ['home_repair', 'cleaning', 'laundry', 'photography', 'plumbing', 'electrical', 'carpentry', 'pest_control'];
    for (let i = 0; i < 20; i++) {
      const subType = serviceSubtypes[i % serviceSubtypes.length];
      vendorDataArray.push(await generateRandomData('service', subType, i + 80));
    }

    // Create or update vendors
    for (const vendorData of vendorDataArray) {
      const existingVendor = await User.findOne({
        $or: [
          { email: vendorData.email },
          { phone: vendorData.phone }
        ]
      });
      const hashedPassword = await bcrypt.hash('password123', 10);
      vendorData.password = hashedPassword;
      if (existingVendor) {
        await User.findByIdAndUpdate(existingVendor._id, vendorData);
        console.log(`✅ Updated vendor: ${vendorData.storeName}`);
      } else {
        const vendor = new User(vendorData);
        await vendor.save();
        console.log(`✅ Created new vendor: ${vendorData.storeName}`);
      }
    }

    // Display summary
    const allVendors = await User.find({ role: 'vendor' });
    const restaurants = allVendors.filter(v => v.vendorType === 'restaurant');
    const stores = allVendors.filter(v => v.vendorType === 'store');
    const cafes = allVendors.filter(v => v.vendorType === 'cafe');
    const services = allVendors.filter(v => v.vendorType === 'service');
    const groceryStores = allVendors.filter(v => v.vendorSubType === 'grocery' || v.vendorSubType === 'supermarket' || v.vendorSubType === 'organic_market');
    const pharmacies = allVendors.filter(v => v.vendorSubType === 'pharmacy' || v.vendorSubType === 'drugstore' || v.vendorSubType === 'wellness_shop');
    const bakeries = allVendors.filter(v => v.vendorSubType === 'bakery');
    console.log('\n🎉 100 Vendors created/updated successfully!');
    console.log('\nSummary:');
    console.log(`- Total vendors: ${allVendors.length}`);
    console.log(`- Restaurants: ${restaurants.length}`);
    console.log(`- Grocery Stores: ${groceryStores.length}`);
    console.log(`- Pharmacies: ${pharmacies.length}`);
    console.log(`- Other Stores: ${stores.length - groceryStores.length - pharmacies.length}`);
    console.log(`- Cafes: ${cafes.length - bakeries.length}`);
    console.log(`- Bakeries: ${bakeries.length}`);
    console.log(`- Service Providers: ${services.length}`);
    console.log('\n📧 Vendor login credentials:');
    vendorDataArray.forEach((vendor, index) => {
      console.log(`${index + 1}. ${vendor.storeName}: ${vendor.email} / password123`);
    });
    process.exit(0);
  } catch (error) {
    console.error('❌ Error creating vendors:', error);
    process.exit(1);
  }
};

createVendors();
