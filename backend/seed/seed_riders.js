const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const axios = require('axios');
require('dotenv').config();

// Import models
const User = require('../src/models/User');
const Product = require('../src/models/Product');

// --- YOUR PEXELS API KEY ---
const PEXELS_API_KEY = 'BIar0nsHgTUJXsg5xbZWUWX04X60kKXukCK5Q1Mt33rh9zYMvpHyXdsp';

// --- Connect to the SAME DATABASE as your vendor script ---
const MONGODB_URI = 'mongodb+srv://testbuddy1221:jaysi123@cluster0.1bjhspl.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0';
mongoose.connect(MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

// --- Function to fetch a relevant image from Pexels ---
const fetchPexelsImage = async (query, size = 'large') => {
  if (!PEXELS_API_KEY) {
    console.warn("Pexels API key not set correctly. Using placeholder image.");
    return `https://placehold.co/600x400?text=${query}`;
  }

  try {
    const response = await axios.get('https://api.pexels.com/v1/search', {
      params: {
        query: query,
        per_page: 1,
        orientation: 'landscape',
      },
      headers: {
        Authorization: PEXELS_API_KEY,
      },
    });

    if (response.data && response.data.photos && response.data.photos.length > 0) {
      const photo = response.data.photos[0];
      return photo.src[size];
    } else {
      console.warn(`⚠️ No image found for query: ${query}. Using placeholder.`);
      return `https://placehold.co/600x400?text=${query}`;
    }
  } catch (error) {
    console.error(`❌ Error fetching image for '${query}':`, error.message);
    return `https://placehold.co/600x400?text=Image+Error`;
  }
};

const generateRandomPhoneNumber = () => {
  const prefix = '98';
  const min = 10000000;
  const max = 99999999;
  const uniqueNumber = Math.floor(Math.random() * (max - min + 1)) + min;
  return `${prefix}${uniqueNumber}`;
};

const vendorsData = [
  // Grocery Vendors
  {
    name: 'Fresh Harvest Grocers',
    email: 'freshharvest@grocery.com',
    storeName: 'Fresh Harvest Grocers',
    storeDescription: 'Locally sourced organic produce and high-quality gourmet goods.',
    vendorType: 'store',
    vendorSubType: 'grocery',
  },
  {
    name: 'Daily Essentials Supermarket',
    email: 'dailyessentials@grocery.com',
    storeName: 'Daily Essentials Supermarket',
    storeDescription: 'Your one-stop shop for fresh food and household necessities.',
    vendorType: 'store',
    vendorSubType: 'supermarket',
  },
  {
    name: 'Green Earth Organic Market',
    email: 'greenearth@organic.com',
    storeName: 'Green Earth Organic Market',
    storeDescription: 'Supporting local farmers with the best in organic and natural products.',
    vendorType: 'store',
    vendorSubType: 'organic_market',
  },
  {
    name: 'QuickBuy Mart',
    email: 'quickbuymart@grocery.com',
    storeName: 'QuickBuy Mart',
    storeDescription: 'Fast and convenient grocery delivery right to your door.',
    vendorType: 'store',
    vendorSubType: 'grocery',
  },

  // Wine Vendors
  {
    name: 'The Wine Cellar',
    email: 'winecellar@wine.com',
    storeName: 'The Wine Cellar',
    storeDescription: 'A curated selection of fine wines from around the world.',
    vendorType: 'store',
    vendorSubType: 'wine',
  },
  {
    name: 'Vintage Vintners',
    email: 'vintagevintners@wine.com',
    storeName: 'Vintage Vintners',
    storeDescription: 'Hand-picked vintage wines for every special occasion.',
    vendorType: 'store',
    vendorSubType: 'wine',
  },
  {
    name: 'Grapevine Liquor Store',
    email: 'grapevine@wine.com',
    storeName: 'Grapevine Liquor Store',
    storeDescription: 'Affordable and quality wines, beers, and spirits.',
    vendorType: 'store',
    vendorSubType: 'wine',
  },
  {
    name: 'Cork & Bottle',
    email: 'corkandbottle@wine.com',
    storeName: 'Cork & Bottle',
    storeDescription: 'Your neighborhood destination for unique and craft spirits.',
    vendorType: 'store',
    vendorSubType: 'wine',
  },

  // Bakery Vendors
  {
    name: 'Sweet Dreams Bakery',
    email: 'sweetdreams@bakery.com',
    storeName: 'Sweet Dreams Bakery',
    storeDescription: 'Artisanal breads, pastries, and cakes made with love and fresh ingredients.',
    vendorType: 'store',
    vendorSubType: 'bakery',
  },
  {
    name: 'Golden Crust Bakery',
    email: 'goldencrust@bakery.com',
    storeName: 'Golden Crust Bakery',
    storeDescription: 'Traditional and modern baked goods for every occasion.',
    vendorType: 'store',
    vendorSubType: 'bakery',
  },
  {
    name: 'Fresh Bites Bakery',
    email: 'freshbites@bakery.com',
    storeName: 'Fresh Bites Bakery',
    storeDescription: 'Freshly baked breads and pastries delivered to your doorstep.',
    vendorType: 'store',
    vendorSubType: 'bakery',
  },
  {
    name: 'Cake & Bake Studio',
    email: 'cakeandbake@bakery.com',
    storeName: 'Cake & Bake Studio',
    storeDescription: 'Custom cakes, cupcakes, and specialty desserts for celebrations.',
    vendorType: 'store',
    vendorSubType: 'bakery',
  },
];

const productsData = {
  grocery: [
    { name: 'Organic Apples', category: 'Grocery', unit: '1 kg' },
    { name: 'Whole Wheat Bread', category: 'Grocery', unit: '1 loaf' },
    { name: 'Free-Range Eggs', category: 'Grocery', unit: '1 dozen' },
    { name: 'Fresh Tomatoes', category: 'Grocery', unit: '1 kg' },
    { name: 'Cooking Oil', category: 'Grocery', unit: '1 liter' },
    { name: 'Basmati Rice', category: 'Grocery', unit: '5 kg' },
    { name: 'Bottled Water', category: 'Grocery', unit: '1 liter' },
    { name: 'Milk Carton', category: 'Grocery', unit: '1 liter' },
    { name: 'Chicken Breast', category: 'Grocery', unit: '500g' },
    { name: 'Lentils', category: 'Grocery', unit: '500g' },
  ],
  wine: [
    { name: 'Cabernet Sauvignon', category: 'wine', unit: '1 bottle' },
    { name: 'Sauvignon Blanc', category: 'wine', unit: '1 bottle' },
    { name: 'Merlot', category: 'wine', unit: '1 bottle' },
    { name: 'Chardonnay', category: 'wine', unit: '1 bottle' },
    { name: 'Pinot Noir', category: 'wine', unit: '1 bottle' },
    { name: 'Prosecco', category: 'wine', unit: '1 bottle' },
    { name: 'Local Craft Beer', category: 'wine', unit: '1 six-pack' },
    { name: 'Tequila', category: 'wine', unit: '1 bottle' },
    { name: 'Vodka', category: 'wine', unit: '1 bottle' },
    { name: 'Gin', category: 'wine', unit: '1 bottle' },
  ],
  bakery: [
    { name: 'Sourdough Bread', category: 'Bakery', unit: '1 loaf' },
    { name: 'Croissants', category: 'Bakery', unit: '6 pieces' },
    { name: 'Chocolate Cake', category: 'Bakery', unit: '1 cake' },
    { name: 'Blueberry Muffins', category: 'Bakery', unit: '6 pieces' },
    { name: 'Whole Wheat Bread', category: 'Bakery', unit: '1 loaf' },
    { name: 'Chocolate Chip Cookies', category: 'Bakery', unit: '12 pieces' },
    { name: 'Cinnamon Rolls', category: 'Bakery', unit: '6 pieces' },
    { name: 'Birthday Cake', category: 'Bakery', unit: '1 cake' },
    { name: 'French Baguette', category: 'Bakery', unit: '1 piece' },
    { name: 'Donuts', category: 'Bakery', unit: '6 pieces' },
  ],
};

async function seedGroceryAndWine() {
  try {
    console.log('🧹 Clearing existing grocery, wine, and bakery data...');
    // Clear old data to prevent duplicates
    const vendorSubtypesToDelete = ['grocery', 'supermarket', 'organic_market', 'wine', 'bakery'];
    await User.deleteMany({ role: 'vendor', vendorSubType: { $in: vendorSubtypesToDelete } });
    await Product.deleteMany({ vendorSubType: { $in: vendorSubtypesToDelete } });
    console.log('✅ Old data cleared.');

    console.log('---');
    console.log('🏪 Seeding new vendors...');

    const createdVendors = [];
    for (const vendorData of vendorsData) {
      const vendorPayload = {
        ...vendorData,
        phone: generateRandomPhoneNumber(),
        password: await bcrypt.hash('password123', 10),
        role: 'vendor',
        storeImage: await fetchPexelsImage(`${vendorData.storeName} storefront`),
        storeBanner: await fetchPexelsImage(`${vendorData.storeName} interior`),
        storeTags: vendorData.vendorType === 'store' ? ['shop', 'local', vendorData.vendorSubType] : [],
        storeCategories: vendorData.vendorType === 'store' ? [vendorData.vendorSubType] : [],
        storeRating: (Math.random() * (5.0 - 4.0) + 4.0).toFixed(1),
        storeReviews: Math.floor(Math.random() * 500) + 50,
        isFeatured: Math.random() > 0.5,
        storeCoordinates: {
          latitude: 27.7 + (Math.random() * 0.5),
          longitude: 85.3 + (Math.random() * 0.5)
        },
        storeAddress: ['Thamel, Kathmandu', 'Baneshwor, Kathmandu', 'Patan, Lalitpur'][Math.floor(Math.random() * 3)],
      };

      const existingVendor = await User.findOne({ email: vendorPayload.email });

      if (!existingVendor) {
        const vendor = new User(vendorPayload);
        await vendor.save();
        createdVendors.push(vendor);
        console.log(`✅ Created vendor: ${vendor.storeName}`);
      } else {
        console.log(`⚠️ Vendor already exists: ${existingVendor.storeName}`);
        createdVendors.push(existingVendor);
      }
    }

    console.log('---');
    console.log('🛍️ Seeding products for new vendors...');

    for (const vendor of createdVendors) {
      let productList = [];
      if (vendor.vendorSubType === 'wine') {
        productList = productsData.wine;
      } else if (vendor.vendorSubType === 'bakery') {
        productList = productsData.bakery;
      } else {
        productList = productsData.grocery;
      }

      for (const productInfo of productList) {
        const productData = {
          name: productInfo.name,
          price: Math.floor(Math.random() * (1000 - 50) + 50),
          imageUrl: await fetchPexelsImage(productInfo.name),
          category: productInfo.category,
          description: `${productInfo.name} available at ${vendor.storeName}.`,
          unit: productInfo.unit,
          deliveryTime: '20 mins',
          isAvailable: true,
          deliveryFee: 20,
          stock: Math.floor(Math.random() * 100) + 20,
          vendorId: vendor._id,
          vendorType: vendor.vendorType,
          vendorSubType: vendor.vendorSubType,
          rating: (Math.random() * (5.0 - 4.0) + 4.0).toFixed(1),
          reviews: Math.floor(Math.random() * 100) + 10,
          isPopular: Math.random() > 0.5,
          isFeatured: Math.random() > 0.7,
          tags: [productInfo.category, vendor.vendorSubType],
        };

        const existingProduct = await Product.findOne({
          name: productData.name,
          vendorId: vendor._id
        });

        if (!existingProduct) {
          const product = new Product(productData);
          await product.save();
          console.log(`✅ Created product: ${product.name} for ${vendor.storeName}`);
        } else {
          console.log(`⚠️ Product already exists: ${existingProduct.name}`);
        }
      }
    }

    console.log('---');
    const finalVendorsCount = await User.countDocuments({ vendorSubType: { $in: vendorSubtypesToDelete } });
    const finalProductsCount = await Product.countDocuments({ vendorSubType: { $in: vendorSubtypesToDelete } });
    console.log('\n🎉 Grocery and Wine seeding completed!');
    console.log('\nSummary:');
    console.log(`- Vendors Created: ${finalVendorsCount}`);
    console.log(`- Products Created: ${finalProductsCount}`);

    process.exit(0);

  } catch (error) {
    console.error('❌ Error during seeding process:', error);
    process.exit(1);
  }
}

seedGroceryAndWine();