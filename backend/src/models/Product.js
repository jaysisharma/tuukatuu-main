const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
  name: { type: String, required: true },
  price: { type: Number, required: true },
  imageUrl: { type: String, required: true },
  category: { type: String, required: true },
  rating: { type: Number, default: 0 },
  reviews: { type: Number, default: 0 },
  isAvailable: { type: Boolean, default: true },
  deliveryFee: { type: Number, default: 0 },
  description: { type: String },
  images: [{ type: String }],
  deliveryTime: { type: String, default: '10 mins' },
  unit: { type: String, default: '1 piece' },
  stock: { type: Number, default: 0 },
  dailyEssential: { type: Boolean, default: false },
  isFeaturedDailyEssential: { type: Boolean, default: false },
  isPopular: { type: Boolean, default: false },
  isFeatured: { type: Boolean, default: false },
  isBestSeller: { type: Boolean, default: false },
  isNewArrival: { type: Boolean, default: false },
  featuredOrder: { type: Number, default: 0 },
  vendorId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  dealTag: { type: String }, // e.g., 'Buy 1 Get 1', '₹99 Store'
  dealExpiresAt: { type: Date },
  // Dietary information
  isVegetarian: { type: Boolean, default: false },
  isOrganic: { type: Boolean, default: false },
  isVegan: { type: Boolean, default: false },
  isGlutenFree: { type: Boolean, default: false },
  // Pricing and discounts
  originalPrice: { type: Number },
  discount: { type: Number, default: 0 },
  // Additional product information
  brand: { type: String },
  tags: [{ type: String }],
}, { timestamps: true });

// Pre-save middleware to auto-create category
productSchema.pre('save', async function(next) {
  try {
    if (this.isNew && this.category) {
      const Category = require('./Category');
      
      // Check if category exists
      const existingCategory = await Category.findOne({
        name: { $regex: new RegExp(`^${this.category}$`, 'i') }
      });
      
      if (!existingCategory) {
        // Auto-create category
        const categoryData = {
          name: this.category,
          displayName: this.category,
          description: `Auto-generated category for ${this.category}`,
          isActive: true,
          isFeatured: false,
          createdBy: this.vendorId // Use vendor as creator for now
        };
        
        const newCategory = new Category(categoryData);
        await newCategory.save();
        
        console.log(`✅ Auto-created category: ${this.category}`);
      }
    }
    next();
  } catch (error) {
    console.error('❌ Error auto-creating category:', error);
    next(error);
  }
});

// Add a static method for seeding products
productSchema.statics.seedProducts = async function() {
  const products = [
    // T-Mart
    {
      name: 'T-Mart Apple',
      price: 120,
      imageUrl: 'https://images.unsplash.com/photo-1567306226416-28f0efdc88ce',
      category: 'T-Mart',
      description: 'Fresh apples from T-Mart',
      unit: '1 kg',
      deliveryTime: '15 mins',
      isAvailable: true,
      deliveryFee: 20,
      images: [],
    },
    // Wine & Beer
    {
      name: 'Red Wine',
      price: 1500,
      imageUrl: 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3',
      category: 'Wine & Beer',
      description: 'Premium red wine',
      unit: '750 ml',
      deliveryTime: '30 mins',
      isAvailable: true,
      deliveryFee: 50,
      images: [],
    },
    // Fast Food
    {
      name: 'Cheese Burger',
      price: 250,
      imageUrl: 'https://images.unsplash.com/photo-1550547660-d9450f859349',
      category: 'Fast Food',
      description: 'Juicy cheese burger',
      unit: '1 piece',
      deliveryTime: '20 mins',
      isAvailable: true,
      deliveryFee: 30,
      images: [],
    },
    // Pharmacy
    {
      name: 'Paracetamol',
      price: 30,
      imageUrl: 'https://images.unsplash.com/photo-1588776814546-ec7e8c1b5b6b',
      category: 'Pharmacy',
      description: 'Pain relief tablets',
      unit: '10 tablets',
      deliveryTime: '25 mins',
      isAvailable: true,
      deliveryFee: 15,
      images: [],
    },
    // Bakery
    {
      name: 'Chocolate Cake',
      price: 500,
      imageUrl: 'https://images.unsplash.com/photo-1517433670267-08bbd4be890f',
      category: 'Bakery',
      description: 'Delicious chocolate cake',
      unit: '1 piece',
      deliveryTime: '30 mins',
      isAvailable: true,
      deliveryFee: 25,
      images: [],
    },
    // Grocery
    {
      name: 'Basmati Rice',
      price: 200,
      imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836',
      category: 'Grocery',
      description: 'Premium basmati rice',
      unit: '5 kg',
      deliveryTime: '20 mins',
      isAvailable: true,
      deliveryFee: 20,
      images: [],
    },
  ];
  await this.deleteMany({});
  await this.insertMany(products);
};

productSchema.statics.seedVendorProducts = async function(vendors) {
  const products = [
    // T-Mart Express
    {
      name: 'Express Apple',
      price: 120,
      imageUrl: 'https://images.unsplash.com/photo-1567306226416-28f0efdc88ce',
      category: 'Grocery',
      description: 'Fresh apples from T-Mart Express',
      unit: '1 kg',
      deliveryTime: '15 mins',
      isAvailable: true,
      deliveryFee: 20,
      images: [],
      vendorId: vendors[0]._id,
    },
    {
      name: 'Express Milk',
      price: 80,
      imageUrl: 'https://images.unsplash.com/photo-1628088062854-d1870b4553da',
      category: 'Dairy',
      description: 'Fresh milk delivered fast',
      unit: '1 litre',
      deliveryTime: '15 mins',
      isAvailable: true,
      deliveryFee: 15,
      images: [],
      vendorId: vendors[0]._id,
    },
    {
      name: 'Express Bread',
      price: 50,
      imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff',
      category: 'Bakery',
      description: 'Soft bread loaf',
      unit: '1 piece',
      deliveryTime: '15 mins',
      isAvailable: true,
      deliveryFee: 10,
      images: [],
      vendorId: vendors[0]._id,
    },
    {
      name: 'Express Eggs',
      price: 120,
      imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff',
      category: 'Grocery',
      description: 'Farm fresh eggs',
      unit: '12 pieces',
      deliveryTime: '15 mins',
      isAvailable: true,
      deliveryFee: 10,
      images: [],
      vendorId: vendors[0]._id,
    },
    {
      name: 'Express Banana',
      price: 60,
      imageUrl: 'https://images.unsplash.com/photo-1610832958506-aa56368176cf',
      category: 'Fruits',
      description: 'Fresh bananas',
      unit: '1 dozen',
      deliveryTime: '15 mins',
      isAvailable: true,
      deliveryFee: 10,
      images: [],
      vendorId: vendors[0]._id,
    },
    // Wine Gallery
    {
      name: 'Red Wine',
      price: 1500,
      imageUrl: 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3',
      category: 'Wine & Beer',
      description: 'Premium red wine',
      unit: '750 ml',
      deliveryTime: '30 mins',
      isAvailable: true,
      deliveryFee: 50,
      images: [],
      vendorId: vendors[1]._id,
    },
    {
      name: 'White Wine',
      price: 1400,
      imageUrl: 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3',
      category: 'Wine & Beer',
      description: 'Premium white wine',
      unit: '750 ml',
      deliveryTime: '30 mins',
      isAvailable: true,
      deliveryFee: 50,
      images: [],
      vendorId: vendors[1]._id,
    },
    {
      name: 'Beer Pack',
      price: 800,
      imageUrl: 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3',
      category: 'Wine & Beer',
      description: '6-pack of premium beer',
      unit: '6 bottles',
      deliveryTime: '30 mins',
      isAvailable: true,
      deliveryFee: 40,
      images: [],
      vendorId: vendors[1]._id,
    },
    {
      name: 'Craft Beer',
      price: 350,
      imageUrl: 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3',
      category: 'Wine & Beer',
      description: 'Locally brewed craft beer',
      unit: '650 ml',
      deliveryTime: '30 mins',
      isAvailable: true,
      deliveryFee: 30,
      images: [],
      vendorId: vendors[1]._id,
    },
    {
      name: 'Whiskey',
      price: 2000,
      imageUrl: 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3',
      category: 'Wine & Beer',
      description: 'Premium whiskey',
      unit: '750 ml',
      deliveryTime: '30 mins',
      isAvailable: true,
      deliveryFee: 60,
      images: [],
      vendorId: vendors[1]._id,
    },
    {
      name: 'Champagne',
      price: 2500,
      imageUrl: 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3',
      category: 'Wine & Beer',
      description: 'Celebration champagne',
      unit: '750 ml',
      deliveryTime: '30 mins',
      isAvailable: true,
      deliveryFee: 70,
      images: [],
      vendorId: vendors[1]._id,
    },
    // Sweet Bakery
    {
      name: 'Chocolate Cake',
      price: 500,
      imageUrl: 'https://images.unsplash.com/photo-1517433670267-08bbd4be890f',
      category: 'Bakery',
      description: 'Delicious chocolate cake',
      unit: '1 piece',
      deliveryTime: '30 mins',
      isAvailable: true,
      deliveryFee: 25,
      images: [],
      vendorId: vendors[2]._id,
    },
    {
      name: 'Croissant',
      price: 80,
      imageUrl: 'https://images.unsplash.com/photo-1517433670267-08bbd4be890f',
      category: 'Bakery',
      description: 'Buttery croissant',
      unit: '1 piece',
      deliveryTime: '25 mins',
      isAvailable: true,
      deliveryFee: 20,
      images: [],
      vendorId: vendors[2]._id,
    },
    {
      name: 'Bread Loaf',
      price: 60,
      imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff',
      category: 'Bakery',
      description: 'Fresh bread loaf',
      unit: '1 piece',
      deliveryTime: '25 mins',
      isAvailable: true,
      deliveryFee: 15,
      images: [],
      vendorId: vendors[2]._id,
    },
    {
      name: 'Strawberry Tart',
      price: 180,
      imageUrl: 'https://images.unsplash.com/photo-1517433670267-08bbd4be890f',
      category: 'Bakery',
      description: 'Fresh strawberry tart',
      unit: '1 piece',
      deliveryTime: '30 mins',
      isAvailable: true,
      deliveryFee: 20,
      images: [],
      vendorId: vendors[2]._id,
    },
    {
      name: 'Blueberry Muffin',
      price: 100,
      imageUrl: 'https://images.unsplash.com/photo-1517433670267-08bbd4be890f',
      category: 'Bakery',
      description: 'Muffin with blueberries',
      unit: '1 piece',
      deliveryTime: '30 mins',
      isAvailable: true,
      deliveryFee: 10,
      images: [],
      vendorId: vendors[2]._id,
    },
    {
      name: 'Cheese Danish',
      price: 140,
      imageUrl: 'https://images.unsplash.com/photo-1517433670267-08bbd4be890f',
      category: 'Bakery',
      description: 'Danish pastry with cheese',
      unit: '1 piece',
      deliveryTime: '30 mins',
      isAvailable: true,
      deliveryFee: 15,
      images: [],
      vendorId: vendors[2]._id,
    },
    // City Pharmacy
    {
      name: 'Paracetamol',
      price: 30,
      imageUrl: 'https://images.unsplash.com/photo-1588776814546-ec7e8c1b5b6b',
      category: 'Pharmacy',
      description: 'Pain relief tablets',
      unit: '10 tablets',
      deliveryTime: '25 mins',
      isAvailable: true,
      deliveryFee: 15,
      images: [],
      vendorId: vendors[3]._id,
    },
    {
      name: 'Vitamin C',
      price: 150,
      imageUrl: 'https://images.unsplash.com/photo-1588776814546-ec7e8c1b5b6b',
      category: 'Pharmacy',
      description: 'Vitamin C supplements',
      unit: '30 tablets',
      deliveryTime: '25 mins',
      isAvailable: true,
      deliveryFee: 15,
      images: [],
      vendorId: vendors[3]._id,
    },
    {
      name: 'First Aid Kit',
      price: 500,
      imageUrl: 'https://images.unsplash.com/photo-1588776814546-ec7e8c1b5b6b',
      category: 'Pharmacy',
      description: 'Complete first aid kit',
      unit: '1 kit',
      deliveryTime: '25 mins',
      isAvailable: true,
      deliveryFee: 20,
      images: [],
      vendorId: vendors[3]._id,
    },
    {
      name: 'Cough Syrup',
      price: 80,
      imageUrl: 'https://images.unsplash.com/photo-1588776814546-ec7e8c1b5b6b',
      category: 'Pharmacy',
      description: 'Relief from cough',
      unit: '100 ml',
      deliveryTime: '25 mins',
      isAvailable: true,
      deliveryFee: 10,
      images: [],
      vendorId: vendors[3]._id,
    },
    {
      name: 'Hand Sanitizer',
      price: 60,
      imageUrl: 'https://images.unsplash.com/photo-1588776814546-ec7e8c1b5b6b',
      category: 'Pharmacy',
      description: 'Kills 99.9% germs',
      unit: '100 ml',
      deliveryTime: '25 mins',
      isAvailable: true,
      deliveryFee: 10,
      images: [],
      vendorId: vendors[3]._id,
    },
    {
      name: 'Face Mask',
      price: 20,
      imageUrl: 'https://images.unsplash.com/photo-1588776814546-ec7e8c1b5b6b',
      category: 'Pharmacy',
      description: 'Disposable face mask',
      unit: '1 piece',
      deliveryTime: '25 mins',
      isAvailable: true,
      deliveryFee: 5,
      images: [],
      vendorId: vendors[3]._id,
    },
    // Fresh Mart Grocery
    {
      name: 'Basmati Rice',
      price: 200,
      imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836',
      category: 'Grocery',
      description: 'Premium basmati rice',
      unit: '5 kg',
      deliveryTime: '20 mins',
      isAvailable: true,
      deliveryFee: 20,
      images: [],
      vendorId: vendors[4]._id,
    },
    {
      name: 'Fresh Tomatoes',
      price: 80,
      imageUrl: 'https://images.unsplash.com/photo-1597362925123-77861d3fbac7',
      category: 'Vegetables',
      description: 'Fresh red tomatoes',
      unit: '1 kg',
      deliveryTime: '20 mins',
      isAvailable: true,
      deliveryFee: 15,
      images: [],
      vendorId: vendors[4]._id,
    },
    {
      name: 'Fresh Onions',
      price: 60,
      imageUrl: 'https://images.unsplash.com/photo-1597362925123-77861d3fbac7',
      category: 'Vegetables',
      description: 'Fresh onions',
      unit: '1 kg',
      deliveryTime: '20 mins',
      isAvailable: true,
      deliveryFee: 15,
      images: [],
      vendorId: vendors[4]._id,
    },
    // Quick Bites Fast Food
    {
      name: 'Cheese Burger',
      price: 250,
      imageUrl: 'https://images.unsplash.com/photo-1550547660-d9450f859349',
      category: 'Fast Food',
      description: 'Juicy cheese burger',
      unit: '1 piece',
      deliveryTime: '20 mins',
      isAvailable: true,
      deliveryFee: 30,
      images: [],
      vendorId: vendors[5]._id,
    },
    {
      name: 'Chicken Pizza',
      price: 400,
      imageUrl: 'https://images.unsplash.com/photo-1550547660-d9450f859349',
      category: 'Fast Food',
      description: 'Delicious chicken pizza',
      unit: '1 piece',
      deliveryTime: '25 mins',
      isAvailable: true,
      deliveryFee: 35,
      images: [],
      vendorId: vendors[5]._id,
    },
    {
      name: 'French Fries',
      price: 120,
      imageUrl: 'https://images.unsplash.com/photo-1550547660-d9450f859349',
      category: 'Fast Food',
      description: 'Crispy french fries',
      unit: '1 portion',
      deliveryTime: '15 mins',
      isAvailable: true,
      deliveryFee: 20,
      images: [],
      vendorId: vendors[5]._id,
    },
    // Organic Valley
    {
      name: 'Organic Apples',
      price: 200,
      imageUrl: 'https://images.unsplash.com/photo-1610832958506-aa56368176cf',
      category: 'Fresh Fruits',
      description: 'Organic fresh apples',
      unit: '1 kg',
      deliveryTime: '30 mins',
      isAvailable: true,
      deliveryFee: 25,
      images: [],
      vendorId: vendors[6]._id,
    },
    {
      name: 'Organic Bananas',
      price: 120,
      imageUrl: 'https://images.unsplash.com/photo-1610832958506-aa56368176cf',
      category: 'Fresh Fruits',
      description: 'Organic fresh bananas',
      unit: '1 dozen',
      deliveryTime: '30 mins',
      isAvailable: true,
      deliveryFee: 20,
      images: [],
      vendorId: vendors[6]._id,
    },
    {
      name: 'Organic Carrots',
      price: 100,
      imageUrl: 'https://images.unsplash.com/photo-1597362925123-77861d3fbac7',
      category: 'Vegetables',
      description: 'Organic fresh carrots',
      unit: '1 kg',
      deliveryTime: '30 mins',
      isAvailable: true,
      deliveryFee: 20,
      images: [],
      vendorId: vendors[6]._id,
    },
    // Dairy Delight
    {
      name: 'Fresh Milk',
      price: 90,
      imageUrl: 'https://images.unsplash.com/photo-1628088062854-d1870b4553da',
      category: 'Dairy',
      description: 'Fresh cow milk',
      unit: '1 litre',
      deliveryTime: '25 mins',
      isAvailable: true,
      deliveryFee: 20,
      images: [],
      vendorId: vendors[7]._id,
    },
    {
      name: 'Cheese Block',
      price: 180,
      imageUrl: 'https://images.unsplash.com/photo-1628088062854-d1870b4553da',
      category: 'Dairy',
      description: 'Fresh cheese block',
      unit: '250g',
      deliveryTime: '25 mins',
      isAvailable: true,
      deliveryFee: 20,
      images: [],
      vendorId: vendors[7]._id,
    },
    {
      name: 'Yogurt',
      price: 70,
      imageUrl: 'https://images.unsplash.com/photo-1628088062854-d1870b4553da',
      category: 'Dairy',
      description: 'Fresh yogurt',
      unit: '500g',
      deliveryTime: '25 mins',
      isAvailable: true,
      deliveryFee: 15,
      images: [],
      vendorId: vendors[7]._id,
    },
  ];
  await this.deleteMany({ vendorId: { $in: vendors.map(v => v._id) } });
  return await this.insertMany(products);
};

// Static method to get popular products
productSchema.statics.getPopularProducts = async function(limit = 10) {
  return await this.find({ 
    isPopular: true, 
    isAvailable: true 
  })
  .sort({ rating: -1, reviews: -1 })
  .limit(limit)
  .populate('vendorId', 'storeName storeRating');
};

// Static method to get featured popular products
productSchema.statics.getFeaturedPopularProducts = async function(limit = 8) {
  return await this.find({ 
    isFeatured: true,
    isAvailable: true 
  })
  .sort({ featuredOrder: 1, rating: -1, reviews: -1 })
  .limit(limit)
  .populate('vendorId', 'storeName storeRating');
};

module.exports = mongoose.model('Product', productSchema); 