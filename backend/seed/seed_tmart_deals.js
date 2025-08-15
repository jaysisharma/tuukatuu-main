const mongoose = require('mongoose');
const TMartDeal = require('../src/models/TMartDeal');

// Connect to MongoDB
mongoose.connect('mongodb://localhost:27017/first_db2', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

const tmartDeals = [
  {
    name: '50% Off on Fruits & Vegetables',
    description: 'Get fresh fruits and vegetables at half price',
    shortDescription: 'On selected fruits & vegetables',
    imageUrl: 'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=300&h=150&fit=crop',
    dealType: 'percentage',
    discountValue: 50,
    applicableCategories: ['Fruits & Vegetables'],
    isActive: true,
    startDate: new Date(),
    endDate: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 days from now
    isFeatured: true,
    usageLimit: 1000,
    userUsageLimit: 2,
    backgroundColor: '#4CAF50',
    textColor: '#FFFFFF',
    buttonText: 'Shop Fruits',
    tags: ['fruits', 'vegetables', 'discount', 'fresh']
  },
  {
    name: 'Buy 1 Get 1 Free on Dairy',
    description: 'Buy any dairy product and get one free',
    shortDescription: 'On dairy products',
    imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=300&h=150&fit=crop',
    dealType: 'buy_one_get_one',
    applicableCategories: ['Dairy & Eggs'],
    isActive: true,
    startDate: new Date(),
    endDate: new Date(Date.now() + 5 * 24 * 60 * 60 * 1000), // 5 days from now
    isFeatured: true,
    usageLimit: 500,
    userUsageLimit: 1,
    backgroundColor: '#FF9800',
    textColor: '#FFFFFF',
    buttonText: 'Shop Dairy',
    tags: ['dairy', 'bogo', 'fresh']
  },
  {
    name: '₹99 Store - Everything at ₹99',
    description: 'Everything at ₹99 - Limited time offer',
    shortDescription: 'Everything at ₹99',
    imageUrl: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=300&h=150&fit=crop',
    dealType: 'fixed',
    discountValue: 99,
    minimumOrderAmount: 200,
    isActive: true,
    startDate: new Date(),
    endDate: new Date(Date.now() + 3 * 24 * 60 * 60 * 1000), // 3 days from now
    isFeatured: true,
    usageLimit: 300,
    userUsageLimit: 1,
    backgroundColor: '#E91E63',
    textColor: '#FFFFFF',
    buttonText: 'Shop Now',
    tags: ['99', 'store', 'limited']
  },
  {
    name: '30% Off on Bakery Items',
    description: 'Get fresh bakery items at 30% off',
    shortDescription: 'On bakery items',
    imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=300&h=150&fit=crop',
    dealType: 'percentage',
    discountValue: 30,
    applicableCategories: ['Bakery'],
    isActive: true,
    startDate: new Date(),
    endDate: new Date(Date.now() + 4 * 24 * 60 * 60 * 1000), // 4 days from now
    isFeatured: true,
    usageLimit: 800,
    userUsageLimit: 2,
    backgroundColor: '#9C27B0',
    textColor: '#FFFFFF',
    buttonText: 'Shop Bakery',
    tags: ['bakery', 'discount', 'fresh']
  },
  {
    name: 'Free Delivery on Orders Above ₹200',
    description: 'Get free delivery on orders above ₹200',
    shortDescription: 'Free delivery above ₹200',
    imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=300&h=150&fit=crop',
    dealType: 'free_delivery',
    minimumOrderAmount: 200,
    isActive: true,
    startDate: new Date(),
    endDate: new Date(Date.now() + 10 * 24 * 60 * 60 * 1000), // 10 days from now
    isFeatured: true,
    usageLimit: 2000,
    userUsageLimit: 5,
    backgroundColor: '#2196F3',
    textColor: '#FFFFFF',
    buttonText: 'Shop Now',
    tags: ['delivery', 'free', 'offer']
  },
  {
    name: 'Combo Deal - Breakfast Pack',
    description: 'Get bread, milk, and eggs together at special price',
    shortDescription: 'Breakfast combo pack',
    imageUrl: 'https://images.unsplash.com/photo-1586444248902-2f64eddc13df?w=300&h=150&fit=crop',
    dealType: 'combo',
    discountValue: 25,
    applicableCategories: ['Dairy & Eggs', 'Bakery'],
    isActive: true,
    startDate: new Date(),
    endDate: new Date(Date.now() + 6 * 24 * 60 * 60 * 1000), // 6 days from now
    isFeatured: true,
    usageLimit: 400,
    userUsageLimit: 2,
    backgroundColor: '#FF5722',
    textColor: '#FFFFFF',
    buttonText: 'Get Combo',
    tags: ['combo', 'breakfast', 'pack']
  }
];

async function seedTMartDeals() {
  try {
    console.log('🌱 Seeding T-Mart deals...');

    // Clear existing deals
    await TMartDeal.deleteMany({});
    console.log('✅ Cleared existing deals');

    // Insert deals
    const deals = await TMartDeal.insertMany(tmartDeals);
    console.log(`✅ Inserted ${deals.length} T-Mart deals`);

    console.log('🎉 T-Mart deals seeding completed successfully!');
    
    // Display summary
    console.log('\n📊 Summary:');
    console.log(`- Deals: ${deals.length}`);
    console.log('\n🎯 Deal Types:');
    deals.forEach((deal, index) => {
      console.log(`${index + 1}. ${deal.name} (${deal.dealType})`);
    });

  } catch (error) {
    console.error('❌ Error seeding T-Mart deals:', error);
  } finally {
    mongoose.connection.close();
    console.log('🔌 Database connection closed');
  }
}

// Run the seeding
seedTMartDeals(); 