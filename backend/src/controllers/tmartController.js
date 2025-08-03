const TMartBanner = require('../models/TMartBanner');
const TMartCategory = require('../models/TMartCategory');
const TMartDeal = require('../models/TMartDeal');
const Order = require('../models/Order');
const User = require('../models/User');
const Product = require('../models/Product');

exports.getBanners = async (req, res) => {
  try {
    const banners = await TMartBanner.find({ 
      isActive: true,
      startDate: { $lte: new Date() },
      endDate: { $gte: new Date() }
    }).sort({ sortOrder: 1, createdAt: -1 });
    
    res.json({
      success: true,
      data: banners
    });
  } catch (err) {
    res.status(500).json({ 
      success: false,
      message: err.message 
    });
  }
};

exports.getCategories = async (req, res) => {
  try {
    const Category = require('../models/Category');
    const categories = await Category.getAllActive();
    
    console.log(`All categories (${categories.length}):`, categories);
    
    res.json({
      success: true,
      data: categories
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: err.message
    });
  }
};

exports.getFeaturedCategories = async (req, res) => {
  try {
    const { limit = 8 } = req.query;
    const Category = require('../models/Category');
    const categories = await Category.getFeatured(parseInt(limit));
    
    console.log(`Featured categories (${categories.length}):`, categories);
    
    res.json({
      success: true,
      data: categories,
      total: categories.length,
      shown: categories.length
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: err.message
    });
  }
};

// Get daily essentials for TMart
exports.getDailyEssentials = async (req, res) => {
  try {
    const dailyEssentials = await Product.find({ 
      dailyEssential: true, 
      isAvailable: true 
    });
    
    console.log(`Daily essentials (${dailyEssentials.length}):`, dailyEssentials);
    
    res.json({
      success: true,
      data: dailyEssentials,
      total: dailyEssentials.length
    });
  } catch (err) {
    console.error('❌ Error in getDailyEssentials:', err);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch daily essentials'
    });
  }
};

// Get popular products for TMart
exports.getPopularProducts = async (req, res) => {
  try {
    const { limit = 10 } = req.query;
    const popularProducts = await Product.getPopularProducts(parseInt(limit));
    
    console.log(`Popular products (${popularProducts.length}):`, popularProducts);
    
    res.json({
      success: true,
      data: popularProducts,
      total: popularProducts.length
    });
  } catch (err) {
    console.error('❌ Error in getPopularProducts:', err);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch popular products'
    });
  }
};

// Get featured popular products for TMart
exports.getFeaturedPopularProducts = async (req, res) => {
  try {
    const { limit = 8 } = req.query;
    const featuredProducts = await Product.getFeaturedPopularProducts(parseInt(limit));
    
    console.log(`Featured popular products (${featuredProducts.length}):`, featuredProducts);
    
    res.json({
      success: true,
      data: featuredProducts,
      total: featuredProducts.length
    });
  } catch (err) {
    console.error('❌ Error in getFeaturedPopularProducts:', err);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch featured popular products'
    });
  }
};


exports.getProducts = async (req, res) => {
  try {
    const { category, search, limit = 20, page = 1, sort = 'createdAt', order = 'desc' } = req.query;
    const query = { isAvailable: true };
    
    if (category) {
      // First check if it's a combined category
      const Category = require('../models/Category');
      const categoryDoc = await Category.findOne({ 
        name: { $regex: new RegExp(`^${category}$`, 'i') },
        isActive: true 
      });
      
      if (categoryDoc && categoryDoc.combinedCategories && categoryDoc.combinedCategories.length > 0) {
        // It's a combined category - fetch products from all combined categories
        query.category = { $in: categoryDoc.combinedCategories };
        console.log(`🔍 Filtering by combined category "${categoryDoc.name}":`, categoryDoc.combinedCategories);
      } else {
        // Regular category or direct matching
        query.category = { $regex: category, $options: 'i' };
        console.log(`🔍 Using direct category matching: ${category}`);
      }
    }
    
    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { category: { $regex: search, $options: 'i' } },
        { brand: { $regex: search, $options: 'i' } },
        { tags: { $in: [new RegExp(search, 'i')] } },
      ];
    }
    
    const skip = (parseInt(page) - 1) * parseInt(limit);
    const sortOrder = order === 'asc' ? 1 : -1;
    
    console.log(`🔍 Query:`, JSON.stringify(query, null, 2));
    
    const products = await Product.find(query)
      .sort({ [sort]: sortOrder })
      .skip(skip)
      .limit(parseInt(limit));
      
    const total = await Product.countDocuments(query);
    
    console.log(`🔍 Found ${products.length} products out of ${total} total`);
    
    res.json({
      success: true,
      data: products,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / parseInt(limit))
      }
    });
  } catch (err) {
    console.error('❌ Error in getProducts:', err);
    res.status(500).json({ 
      success: false,
      message: err.message 
    });
  }
};

exports.getBestSellers = async (req, res) => {
  try {
    const products = await Product.find({ 
      isAvailable: true,
      isBestSeller: true 
    })
      .sort({ rating: -1, reviews: -1 })
      .limit(10);
      
    res.json({
      success: true,
      data: products
    });
  } catch (err) {
    res.status(500).json({ 
      success: false,
      message: err.message 
    });
  }
};

exports.getPopularItems = async (req, res) => {
  try {
    const { limit = 10 } = req.query;
    const products = await Product.getPopularProducts(parseInt(limit));
    
    console.log(`Popular items (${products.length}):`, products);
    
    res.json({
      success: true,
      data: products
    });
  } catch (err) {
    console.error('❌ Error in getPopularItems:', err);
    res.status(500).json({ 
      success: false,
      message: err.message 
    });
  }
};

exports.getRecommendations = async (req, res) => {
  try {
    const { limit = 12 } = req.query;
    
    // Get a mix of popular, trending, and diverse products
    const popularProducts = await Product.find({ 
      isAvailable: true,
      rating: { $gte: 4.0 }
    })
      .sort({ rating: -1, reviews: -1 })
      .limit(Math.ceil(parseInt(limit) / 2));
    
    // Get some newer products to add variety
    const newProducts = await Product.find({ 
      isAvailable: true,
      rating: { $gte: 3.5 }
    })
      .sort({ createdAt: -1 })
      .limit(Math.ceil(parseInt(limit) / 2));
    
    // Combine and shuffle the products
    const allProducts = [...popularProducts, ...newProducts];
    const shuffledProducts = allProducts
      .sort(() => Math.random() - 0.5)
      .slice(0, parseInt(limit));
    
    console.log(`🔍 Recommendations: ${shuffledProducts.length} products`);
    
    res.json({
      success: true,
      data: shuffledProducts,
      total: shuffledProducts.length
    });
  } catch (err) {
    console.error('❌ Error in getRecommendations:', err);
    res.status(500).json({ 
      success: false,
      message: err.message 
    });
  }
};

exports.getDeals = async (req, res) => {
  try {
    const now = new Date();
    const deals = await TMartDeal.find({
      isActive: true,
      startDate: { $lte: now },
      endDate: { $gte: now }
    })
      .sort({ isFeatured: -1, createdAt: -1 })
      .limit(10);
      
    res.json({
      success: true,
      data: deals
    });
  } catch (err) {
    res.status(500).json({ 
      success: false,
      message: err.message 
    });
  }
};

exports.getCombos = async (req, res) => {
  try {
    const combos = await Combo.find({ isActive: true }).populate('products');
    res.json(combos);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getRecentlyOrdered = async (req, res) => {
  try {
    if (!req.user) return res.status(401).json({ message: 'Unauthorized' });
    const orders = await Order.find({ customerId: req.user.id }).sort({ createdAt: -1 }).limit(10);
    // Flatten product list, most recent first, unique
    const seen = new Set();
    const products = [];
    for (const order of orders) {
      for (const item of order.items) {
        if (!seen.has(item.product.toString())) {
          seen.add(item.product.toString());
          products.push(item);
        }
      }
    }
    res.json(products);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getStoreInfo = async (req, res) => {
  try {
    // For demo: return the first featured vendor
    const vendor = await User.findOne({ role: 'vendor', isFeatured: true });
    if (!vendor) return res.status(404).json({ message: 'No featured vendor found' });
    res.json({
      success: true,
      data: {
        name: vendor.storeName,
        address: vendor.storeDescription,
        eta: '15-30 mins',
      }
    });
  } catch (err) {
    res.status(500).json({ 
      success: false,
      message: err.message 
    });
  }
};

// Get daily essentials
exports.getDailyEssentials = async (req, res) => {
  try {
    const products = await Product.find({ 
      isAvailable: true,
      category: { $in: ['Dairy & Eggs', 'Bakery', 'Fruits & Vegetables'] }
    })
      .sort({ rating: -1 })
      .limit(8);
      
    res.json({
      success: true,
      data: products
    });
  } catch (err) {
    res.status(500).json({ 
      success: false,
      message: err.message 
    });
  }
};

// Get new arrivals
exports.getNewArrivals = async (req, res) => {
  try {
    const products = await Product.find({ 
      isAvailable: true,
      isNewArrival: true 
    })
      .sort({ createdAt: -1 })
      .limit(10);
      
    res.json({
      success: true,
      data: products
    });
  } catch (err) {
    res.status(500).json({ 
      success: false,
      message: err.message 
    });
  }
};

// Search products with advanced filters
exports.searchProducts = async (req, res) => {
  try {
    const { 
      q, 
      category, 
      minPrice, 
      maxPrice, 
      rating, 
      isVegetarian, 
      isOrganic,
      isVegan,
      isGlutenFree,
      hasDiscount,
      sort = 'relevance',
      page = 1,
      limit = 20 
    } = req.query;
    
    const query = { isAvailable: true };
    
    // Text search
    if (q) {
      query.$or = [
        { name: { $regex: q, $options: 'i' } },
        { description: { $regex: q, $options: 'i' } },
        { brand: { $regex: q, $options: 'i' } },
        { tags: { $in: [new RegExp(q, 'i')] } },
      ];
    }
    
    // Category filter - try multiple ways to find the category
    if (category) {
      let categoryDoc = await TMartCategory.findOne({ name: category, isActive: true });
      
      // If not found by name, try by displayName
      if (!categoryDoc) {
        categoryDoc = await TMartCategory.findOne({ 
          displayName: { $regex: category, $options: 'i' }, 
          isActive: true 
        });
      }
      
      // If still not found, try partial match on both name and displayName
      if (!categoryDoc) {
        categoryDoc = await TMartCategory.findOne({ 
          $or: [
            { name: { $regex: category, $options: 'i' } },
            { displayName: { $regex: category, $options: 'i' } }
          ],
          isActive: true 
        });
      }
      
      if (categoryDoc) {
        query.category = categoryDoc.displayName;
      }
    }
    
    // Price filter
    if (minPrice || maxPrice) {
      query.price = {};
      if (minPrice) query.price.$gte = parseFloat(minPrice);
      if (maxPrice) query.price.$lte = parseFloat(maxPrice);
    }
    
    // Rating filter
    if (rating) {
      query.rating = { $gte: parseFloat(rating) };
    }
    
    // Dietary filters
    if (isVegetarian === 'true') {
      query.isVegetarian = true;
    }
    
    if (isOrganic === 'true') {
      query.isOrganic = true;
    }
    
    if (isVegan === 'true') {
      query.isVegan = true;
    }
    
    if (isGlutenFree === 'true') {
      query.isGlutenFree = true;
    }
    
    // Discount filter
    if (hasDiscount === 'true') {
      if (query.$or) {
        // If we already have an $or query (from search), we need to combine them
        const searchOr = query.$or;
        query.$and = [
          { $or: searchOr },
          { $or: [
            { discount: { $gt: 0 } },
            { originalPrice: { $exists: true, $gt: 0 } }
          ]}
        ];
        delete query.$or;
      } else {
        query.$or = [
          { discount: { $gt: 0 } },
          { originalPrice: { $exists: true, $gt: 0 } }
        ];
      }
    }
    
    // Sorting
    let sortQuery = {};
    switch (sort) {
      case 'price_low':
        sortQuery = { price: 1 };
        break;
      case 'price_high':
        sortQuery = { price: -1 };
        break;
      case 'rating':
        sortQuery = { rating: -1 };
        break;
      case 'newest':
        sortQuery = { createdAt: -1 };
        break;
      case 'popular':
        sortQuery = { reviews: -1 };
        break;
      case 'discount':
        sortQuery = { discount: -1 };
        break;
      default:
        sortQuery = { rating: -1, reviews: -1 };
    }
    
    const skip = (parseInt(page) - 1) * parseInt(limit);
    
    const products = await Product.find(query)
      .sort(sortQuery)
      .skip(skip)
      .limit(parseInt(limit));
      
    const total = await Product.countDocuments(query);
    
    res.json({
      success: true,
      data: products,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / parseInt(limit))
      }
    });
  } catch (err) {
    res.status(500).json({ 
      success: false,
      message: err.message 
    });
  }
};

exports.getProductsByCategory = async (req, res) => {
  try {
    const { category } = req.query;

    if (!category) {
      return res.status(400).json({
        success: false,
        message: "Category is required as a query parameter."
      });
    }

    const products = await Product.find({
      category: new RegExp(`^${category}$`, 'i'),
      isAvailable: true
    });

    res.json({
      success: true,
      data: products
    });

  } catch (err) {
    res.status(500).json({
      success: false,
      message: err.message
    });
  }
};



// Get product details
exports.getProductDetails = async (req, res) => {
  try {
    const { productId } = req.params;
    
    const product = await Product.findById(productId);
    if (!product) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }
    
    // Get related products
    const relatedProducts = await Product.find({
      category: product.category,
      _id: { $ne: productId },
      isAvailable: true
    })
      .limit(4)
      .sort({ rating: -1 });
    
    res.json({
      success: true,
      data: product,
      relatedProducts
    });
  } catch (err) {
    res.status(500).json({ 
      success: false,
      message: err.message 
    });
  }
}; 