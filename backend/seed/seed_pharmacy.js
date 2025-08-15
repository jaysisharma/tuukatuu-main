const mongoose = require('mongoose');
require('dotenv').config();

// Import models
const User = require('../src/models/User');
const Product = require('../src/models/Product');

async function seedPharmacy() {
  try {
    // Connect to MongoDB
    await mongoose.connect('mongodb+srv://testbuddy1221:jaysi123@cluster0.1bjhspl.mongodb.net/');
    console.log('Connected to MongoDB');

    console.log('Starting pharmacy seeding...');

    // 1. Seed pharmacy vendors
    console.log('1. Seeding pharmacy vendors...');
    const pharmacyVendors = [
      {
        name: 'MedPlus Pharmacy',
        email: 'medplus@pharmacy.com',
        phone: '9800000101',
        password: await require('bcryptjs').hash('password123', 10),
        role: 'vendor',
        storeName: 'MedPlus Pharmacy',
        storeDescription: 'Your trusted healthcare partner with genuine medicines and healthcare products',
        storeImage: 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88',
        storeBanner: 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88',
        storeTags: ['Pharmacy', 'Healthcare', 'Medicines'],
        storeCategories: ['Pharmacy', 'Healthcare'],
        vendorType: 'store',
        vendorSubType: 'pharmacy',
        storeRating: 4.8,
        storeReviews: 1250,
        isFeatured: true,
        storeCoordinates: {
          latitude: 27.7172,
          longitude: 85.3240
        },
        storeAddress: 'Thamel, Kathmandu',
      },
      {
        name: 'HealthCare Pharmacy',
        email: 'healthcare@pharmacy.com',
        phone: '9800000102',
        password: await require('bcryptjs').hash('password123', 10),
        role: 'vendor',
        storeName: 'HealthCare Pharmacy',
        storeDescription: 'Complete healthcare solutions with certified pharmacists',
        storeImage: 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56',
        storeBanner: 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56',
        storeTags: ['Pharmacy', 'Healthcare', 'Certified'],
        storeCategories: ['Pharmacy', 'Healthcare'],
        vendorType: 'store',
        vendorSubType: 'pharmacy',
        storeRating: 4.9,
        storeReviews: 980,
        isFeatured: true,
        storeCoordinates: {
          latitude: 27.7089,
          longitude: 85.3300
        },
        storeAddress: 'Durbarmarg, Kathmandu',
      },
      {
        name: 'CityMed Pharmacy',
        email: 'citymed@pharmacy.com',
        phone: '9800000103',
        password: await require('bcryptjs').hash('password123', 10),
        role: 'vendor',
        storeName: 'CityMed Pharmacy',
        storeDescription: '24/7 pharmacy services with emergency medicines',
        storeImage: 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1f',
        storeBanner: 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1f',
        storeTags: ['Pharmacy', '24/7', 'Emergency'],
        storeCategories: ['Pharmacy', 'Healthcare'],
        vendorType: 'store',
        vendorSubType: 'pharmacy',
        storeRating: 4.7,
        storeReviews: 750,
        isFeatured: false,
        storeCoordinates: {
          latitude: 27.7250,
          longitude: 85.3400
        },
        storeAddress: 'Baneshwor, Kathmandu',
      },
      {
        name: 'Wellness Pharmacy',
        email: 'wellness@pharmacy.com',
        phone: '9800000104',
        password: await require('bcryptjs').hash('password123', 10),
        role: 'vendor',
        storeName: 'Wellness Pharmacy',
        storeDescription: 'Natural and organic healthcare products',
        storeImage: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae',
        storeBanner: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae',
        storeTags: ['Pharmacy', 'Natural', 'Organic'],
        storeCategories: ['Pharmacy', 'Healthcare'],
        vendorType: 'store',
        vendorSubType: 'pharmacy',
        storeRating: 4.6,
        storeReviews: 620,
        isFeatured: false,
        storeCoordinates: {
          latitude: 27.7150,
          longitude: 85.3150
        },
        storeAddress: 'New Road, Kathmandu',
      },
      {
        name: 'QuickMed Pharmacy',
        email: 'quickmed@pharmacy.com',
        phone: '9800000105',
        password: await require('bcryptjs').hash('password123', 10),
        role: 'vendor',
        storeName: 'QuickMed Pharmacy',
        storeDescription: 'Fast delivery of medicines and healthcare essentials',
        storeImage: 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88',
        storeBanner: 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88',
        storeTags: ['Pharmacy', 'Fast Delivery', 'Essentials'],
        storeCategories: ['Pharmacy', 'Healthcare'],
        vendorType: 'store',
        vendorSubType: 'pharmacy',
        storeRating: 4.5,
        storeReviews: 890,
        isFeatured: false,
        storeCoordinates: {
          latitude: 27.7200,
          longitude: 85.3250
        },
        storeAddress: 'Asan, Kathmandu',
      }
    ];

    // Create vendors
    const createdVendors = [];
    for (const vendorData of pharmacyVendors) {
      const existingVendor = await User.findOne({ email: vendorData.email });
      if (!existingVendor) {
        const vendor = new User(vendorData);
        await vendor.save();
        createdVendors.push(vendor);
        console.log(`✅ Created vendor: ${vendor.storeName}`);
      } else {
        createdVendors.push(existingVendor);
        console.log(`⚠️  Vendor already exists: ${existingVendor.storeName}`);
      }
    }

    console.log(`✅ Pharmacy vendors seeded: ${createdVendors.length}`);

    // 2. Seed pharmacy products
    console.log('2. Seeding pharmacy products...');
    
    const pharmacyProducts = [
      // Pain Relief & Fever
      {
        name: 'Paracetamol 500mg',
        price: 25,
        imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae',
        category: 'Pain Relief',
        description: 'Effective pain relief and fever reducer',
        unit: '10 tablets',
        deliveryTime: '30 mins',
        isAvailable: true,
        deliveryFee: 30,
        images: ['https://images.unsplash.com/photo-1584308666744-24d5c474f2ae'],
        vendorType: 'store',
        vendorSubType: 'pharmacy',
        brand: 'Generic',
        tags: ['Pain Relief', 'Fever', 'Headache'],
        isFeatured: true,
        isPopular: true,
      },
      {
        name: 'Ibuprofen 400mg',
        price: 35,
        imageUrl: 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56',
        category: 'Pain Relief',
        description: 'Anti-inflammatory pain reliever',
        unit: '10 tablets',
        deliveryTime: '30 mins',
        isAvailable: true,
        deliveryFee: 30,
        images: ['https://images.unsplash.com/photo-1559757148-5c350d0d3c56'],
        vendorType: 'store',
        vendorSubType: 'pharmacy',
        brand: 'Generic',
        tags: ['Pain Relief', 'Inflammation', 'Muscle Pain'],
        isFeatured: false,
        isPopular: true,
      },
      {
        name: 'Aspirin 100mg',
        price: 20,
        imageUrl: 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1f',
        category: 'Pain Relief',
        description: 'Blood thinner and pain reliever',
        unit: '10 tablets',
        deliveryTime: '30 mins',
        isAvailable: true,
        deliveryFee: 30,
        images: ['https://images.unsplash.com/photo-1576091160399-112ba8d25d1f'],
        vendorType: 'store',
        vendorSubType: 'pharmacy',
        brand: 'Generic',
        tags: ['Pain Relief', 'Blood Thinner', 'Heart Health'],
        isFeatured: false,
        isPopular: false,
      },

      // Cold & Cough
      {
        name: 'Cetirizine 10mg',
        price: 40,
        imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae',
        category: 'Cold & Cough',
        description: 'Antihistamine for allergies and cold symptoms',
        unit: '10 tablets',
        deliveryTime: '30 mins',
        isAvailable: true,
        deliveryFee: 30,
        images: ['https://images.unsplash.com/photo-1584308666744-24d5c474f2ae'],
        vendorType: 'store',
        vendorSubType: 'pharmacy',
        brand: 'Generic',
        tags: ['Allergies', 'Cold', 'Antihistamine'],
        isFeatured: true,
        isPopular: true,
      },
      {
        name: 'Cough Syrup',
        price: 150,
        imageUrl: 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56',
        category: 'Cold & Cough',
        description: 'Effective cough relief syrup',
        unit: '100ml bottle',
        deliveryTime: '30 mins',
        isAvailable: true,
        deliveryFee: 30,
        images: ['https://images.unsplash.com/photo-1559757148-5c350d0d3c56'],
        vendorType: 'store',
        vendorSubType: 'pharmacy',
        brand: 'Generic',
        tags: ['Cough', 'Cold', 'Syrup'],
        isFeatured: false,
        isPopular: true,
      },
      {
        name: 'Vitamin C 500mg',
        price: 120,
        imageUrl: 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1f',
        category: 'Vitamins & Supplements',
        description: 'Immune system booster',
        unit: '30 tablets',
        deliveryTime: '30 mins',
        isAvailable: true,
        deliveryFee: 30,
        images: ['https://images.unsplash.com/photo-1576091160399-112ba8d25d1f'],
        vendorType: 'store',
        vendorSubType: 'pharmacy',
        brand: 'Generic',
        tags: ['Vitamin C', 'Immunity', 'Supplements'],
        isFeatured: true,
        isPopular: true,
      },

      // Digestive Health
      {
        name: 'Omeprazole 20mg',
        price: 80,
        imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae',
        category: 'Digestive Health',
        description: 'Acid reflux and stomach ulcer treatment',
        unit: '10 capsules',
        deliveryTime: '30 mins',
        isAvailable: true,
        deliveryFee: 30,
        images: ['https://images.unsplash.com/photo-1584308666744-24d5c474f2ae'],
        vendorType: 'store',
        vendorSubType: 'pharmacy',
        brand: 'Generic',
        tags: ['Acid Reflux', 'Stomach', 'Digestive'],
        isFeatured: false,
        isPopular: true,
      },
      {
        name: 'Lactobacillus Probiotic',
        price: 200,
        imageUrl: 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56',
        category: 'Digestive Health',
        description: 'Gut health probiotic supplement',
        unit: '30 capsules',
        deliveryTime: '30 mins',
        isAvailable: true,
        deliveryFee: 30,
        images: ['https://images.unsplash.com/photo-1559757148-5c350d0d3c56'],
        vendorType: 'store',
        vendorSubType: 'pharmacy',
        brand: 'Generic',
        tags: ['Probiotic', 'Gut Health', 'Digestive'],
        isFeatured: true,
        isPopular: false,
      },

      // First Aid
      {
        name: 'Band-Aid Strips',
        price: 50,
        imageUrl: 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1f',
        category: 'First Aid',
        description: 'Adhesive bandages for minor cuts',
        unit: '20 strips',
        deliveryTime: '30 mins',
        isAvailable: true,
        deliveryFee: 30,
        images: ['https://images.unsplash.com/photo-1576091160399-112ba8d25d1f'],
        vendorType: 'store',
        vendorSubType: 'pharmacy',
        brand: 'Generic',
        tags: ['First Aid', 'Bandages', 'Cuts'],
        isFeatured: false,
        isPopular: true,
      },
      {
        name: 'Antiseptic Solution',
        price: 80,
        imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae',
        category: 'First Aid',
        description: 'Wound cleaning antiseptic solution',
        unit: '100ml bottle',
        deliveryTime: '30 mins',
        isAvailable: true,
        deliveryFee: 30,
        images: ['https://images.unsplash.com/photo-1584308666744-24d5c474f2ae'],
        vendorType: 'store',
        vendorSubType: 'pharmacy',
        brand: 'Generic',
        tags: ['First Aid', 'Antiseptic', 'Wound Care'],
        isFeatured: false,
        isPopular: false,
      },

      // Personal Care
      {
        name: 'Toothpaste',
        price: 120,
        imageUrl: 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56',
        category: 'Personal Care',
        description: 'Fresh mint toothpaste for oral hygiene',
        unit: '100g tube',
        deliveryTime: '30 mins',
        isAvailable: true,
        deliveryFee: 30,
        images: ['https://images.unsplash.com/photo-1559757148-5c350d0d3c56'],
        vendorType: 'store',
        vendorSubType: 'pharmacy',
        brand: 'Generic',
        tags: ['Oral Care', 'Toothpaste', 'Hygiene'],
        isFeatured: false,
        isPopular: true,
      },
      {
        name: 'Shampoo',
        price: 180,
        imageUrl: 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1f',
        category: 'Personal Care',
        description: 'Gentle hair care shampoo',
        unit: '200ml bottle',
        deliveryTime: '30 mins',
        isAvailable: true,
        deliveryFee: 30,
        images: ['https://images.unsplash.com/photo-1576091160399-112ba8d25d1f'],
        vendorType: 'store',
        vendorSubType: 'pharmacy',
        brand: 'Generic',
        tags: ['Hair Care', 'Shampoo', 'Personal Care'],
        isFeatured: false,
        isPopular: true,
      },

      // Baby Care
      {
        name: 'Baby Diapers',
        price: 450,
        imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae',
        category: 'Baby Care',
        description: 'Comfortable baby diapers size M',
        unit: '20 pieces',
        deliveryTime: '30 mins',
        isAvailable: true,
        deliveryFee: 30,
        images: ['https://images.unsplash.com/photo-1584308666744-24d5c474f2ae'],
        vendorType: 'store',
        vendorSubType: 'pharmacy',
        brand: 'Generic',
        tags: ['Baby Care', 'Diapers', 'Infant'],
        isFeatured: true,
        isPopular: true,
      },
      {
        name: 'Baby Wipes',
        price: 120,
        imageUrl: 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56',
        category: 'Baby Care',
        description: 'Gentle baby wipes for sensitive skin',
        unit: '80 wipes',
        deliveryTime: '30 mins',
        isAvailable: true,
        deliveryFee: 30,
        images: ['https://images.unsplash.com/photo-1559757148-5c350d0d3c56'],
        vendorType: 'store',
        vendorSubType: 'pharmacy',
        brand: 'Generic',
        tags: ['Baby Care', 'Wipes', 'Sensitive Skin'],
        isFeatured: false,
        isPopular: true,
      },

      // Health Monitors
      {
        name: 'Digital Thermometer',
        price: 350,
        imageUrl: 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1f',
        category: 'Health Monitors',
        description: 'Accurate digital body temperature thermometer',
        unit: '1 piece',
        deliveryTime: '30 mins',
        isAvailable: true,
        deliveryFee: 30,
        images: ['https://images.unsplash.com/photo-1576091160399-112ba8d25d1f'],
        vendorType: 'store',
        vendorSubType: 'pharmacy',
        brand: 'Generic',
        tags: ['Thermometer', 'Health Monitor', 'Digital'],
        isFeatured: true,
        isPopular: true,
      },
      {
        name: 'Blood Pressure Monitor',
        price: 2500,
        imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae',
        category: 'Health Monitors',
        description: 'Digital blood pressure monitor for home use',
        unit: '1 piece',
        deliveryTime: '30 mins',
        isAvailable: true,
        deliveryFee: 30,
        images: ['https://images.unsplash.com/photo-1584308666744-24d5c474f2ae'],
        vendorType: 'store',
        vendorSubType: 'pharmacy',
        brand: 'Generic',
        tags: ['Blood Pressure', 'Health Monitor', 'Digital'],
        isFeatured: false,
        isPopular: false,
      },

      // Women's Health
      {
        name: 'Pregnancy Test Kit',
        price: 150,
        imageUrl: 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56',
        category: 'Women\'s Health',
        description: 'Accurate pregnancy test kit',
        unit: '1 kit',
        deliveryTime: '30 mins',
        isAvailable: true,
        deliveryFee: 30,
        images: ['https://images.unsplash.com/photo-1559757148-5c350d0d3c56'],
        vendorType: 'store',
        vendorSubType: 'pharmacy',
        brand: 'Generic',
        tags: ['Pregnancy Test', 'Women\'s Health', 'Test Kit'],
        isFeatured: false,
        isPopular: true,
      },
      {
        name: 'Iron Supplements',
        price: 180,
        imageUrl: 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1f',
        category: 'Women\'s Health',
        description: 'Iron supplements for women',
        unit: '30 tablets',
        deliveryTime: '30 mins',
        isAvailable: true,
        deliveryFee: 30,
        images: ['https://images.unsplash.com/photo-1576091160399-112ba8d25d1f'],
        vendorType: 'store',
        vendorSubType: 'pharmacy',
        brand: 'Generic',
        tags: ['Iron', 'Supplements', 'Women\'s Health'],
        isFeatured: false,
        isPopular: false,
      },

      // Men's Health
      {
        name: 'Multivitamin for Men',
        price: 250,
        imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae',
        category: 'Men\'s Health',
        description: 'Complete multivitamin supplement for men',
        unit: '30 tablets',
        deliveryTime: '30 mins',
        isAvailable: true,
        deliveryFee: 30,
        images: ['https://images.unsplash.com/photo-1584308666744-24d5c474f2ae'],
        vendorType: 'store',
        vendorSubType: 'pharmacy',
        brand: 'Generic',
        tags: ['Multivitamin', 'Men\'s Health', 'Supplements'],
        isFeatured: true,
        isPopular: false,
      },

      // Elderly Care
      {
        name: 'Calcium Supplements',
        price: 220,
        imageUrl: 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56',
        category: 'Elderly Care',
        description: 'Calcium supplements for bone health',
        unit: '30 tablets',
        deliveryTime: '30 mins',
        isAvailable: true,
        deliveryFee: 30,
        images: ['https://images.unsplash.com/photo-1559757148-5c350d0d3c56'],
        vendorType: 'store',
        vendorSubType: 'pharmacy',
        brand: 'Generic',
        tags: ['Calcium', 'Bone Health', 'Elderly Care'],
        isFeatured: false,
        isPopular: true,
      },
      {
        name: 'Joint Health Supplements',
        price: 300,
        imageUrl: 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1f',
        category: 'Elderly Care',
        description: 'Glucosamine supplements for joint health',
        unit: '30 tablets',
        deliveryTime: '30 mins',
        isAvailable: true,
        deliveryFee: 30,
        images: ['https://images.unsplash.com/photo-1576091160399-112ba8d25d1f'],
        vendorType: 'store',
        vendorSubType: 'pharmacy',
        brand: 'Generic',
        tags: ['Joint Health', 'Glucosamine', 'Elderly Care'],
        isFeatured: false,
        isPopular: false,
      }
    ];

    // Create products and assign to vendors
    const createdProducts = [];
    for (let i = 0; i < pharmacyProducts.length; i++) {
      const productData = pharmacyProducts[i];
      const vendorIndex = i % createdVendors.length; // Distribute products among vendors
      const vendor = createdVendors[vendorIndex];
      
      const existingProduct = await Product.findOne({ 
        name: productData.name, 
        vendorId: vendor._id 
      });
      
      if (!existingProduct) {
        const product = new Product({
          ...productData,
          vendorId: vendor._id,
          vendorType: vendor.vendorType,
          vendorSubType: vendor.vendorSubType,
        });
        await product.save();
        createdProducts.push(product);
        console.log(`✅ Created product: ${product.name} for ${vendor.storeName}`);
      } else {
        createdProducts.push(existingProduct);
        console.log(`⚠️  Product already exists: ${existingProduct.name}`);
      }
    }

    console.log(`✅ Pharmacy products seeded: ${createdProducts.length}`);

    console.log('\n🎉 Pharmacy seeding completed!');
    console.log('\nSummary:');
    console.log(`- Pharmacy Vendors: ${createdVendors.length}`);
    console.log(`- Pharmacy Products: ${createdProducts.length}`);

    console.log('\nPharmacy vendor details:');
    createdVendors.forEach((vendor, index) => {
      console.log(`${index + 1}. ${vendor.storeName} - ${vendor.storeAddress}`);
      console.log(`   Rating: ${vendor.storeRating} (${vendor.storeReviews} reviews)`);
      console.log(`   Categories: ${vendor.storeCategories.join(', ')}`);
    });

    console.log('\nProduct categories:');
    const categories = [...new Set(createdProducts.map(p => p.category))];
    categories.forEach(category => {
      const count = createdProducts.filter(p => p.category === category).length;
      console.log(`- ${category}: ${count} products`);
    });

    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding pharmacy data:', error);
    console.error('Stack trace:', error.stack);
    process.exit(1);
  }
}

seedPharmacy(); 