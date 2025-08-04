const TMartBanner = require('../models/TMartBanner');
const TMartCategory = require('../models/TMartCategory');
const TMartDeal = require('../models/TMartDeal');
const Order = require('../models/Order');
const User = require('../models/User');
const Product = require('../models/Product');

// Get T-Mart banners
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

// Get T-Mart categories
exports.getCategories = async (req, res) => {
  try {
    const Category = require('../models/Category');
    const categories = await Category.getAllActive();
    
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

// Get featured categories for T-Mart
exports.getFeaturedCategories = async (req, res) => {
  try {
    const { limit = 8 } = req.query;
    const Category = require('../models/Category');
    const categories = await Category.getFeatured(parseInt(limit));
    
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

// Get daily essentials for T-Mart
exports.getDailyEssentials = async (req, res) => {
  try {
    const { limit = 6 } = req.query;
    const dailyEssentials = await Product.find({ 
      dailyEssential: true, 
      isAvailable: true,
      vendorType: 'store' // Only store products, no restaurant products
    }).limit(parseInt(limit));
    
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

// Get popular products for T-Mart
exports.getPopularProducts = async (req, res) => {
  try {
    const { limit = 8, shuffle = false } = req.query;
    const shouldShuffle = shuffle === 'true' || shuffle === '1';
    
    let query = { 
      isAvailable: true,
      isPopular: true,
      vendorType: 'store' // Only store products, no restaurant products
    };
    
    let products = await Product.find(query).limit(parseInt(limit));
    
    if (shouldShuffle) {
      products = products.sort(() => Math.random() - 0.5);
    }
    
    res.json({
      success: true,
      data: products,
      total: products.length
    });
  } catch (err) {
    console.error('❌ Error in getPopularProducts:', err);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch popular products'
    });
  }
};

// Get recommended products for T-Mart
exports.getRecommendations = async (req, res) => {
  try {
    const { limit = 6, userId } = req.query;
    
    let query = { 
      isAvailable: true,
      isFeatured: true,
      vendorType: 'store' // Only store products, no restaurant products
    };
    
    let products = await Product.find(query).limit(parseInt(limit));
    
    res.json({
      success: true,
      data: products,
      total: products.length
    });
  } catch (err) {
    console.error('❌ Error in getRecommendations:', err);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch recommendations'
    });
  }
};

// Get today's deals for T-Mart
exports.getTodayDeals = async (req, res) => {
  try {
    const { limit = 4 } = req.query;
    const today = new Date();
    
    const deals = await TMartDeal.find({
      isActive: true,
      startDate: { $lte: today },
      endDate: { $gte: today }
    }).limit(parseInt(limit));
    
    res.json({
      success: true,
      data: deals,
      total: deals.length
    });
  } catch (err) {
    console.error('❌ Error in getTodayDeals:', err);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch today\'s deals'
    });
  }
};

// Get all deals for T-Mart
exports.getDeals = async (req, res) => {
  try {
    const { limit = 4 } = req.query;
    const today = new Date();
    
    const deals = await TMartDeal.find({
      isActive: true,
      endDate: { $gte: today }
    }).limit(parseInt(limit));
    
    res.json({
      success: true,
      data: deals,
      total: deals.length
    });
  } catch (err) {
    console.error('❌ Error in getDeals:', err);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch deals'
    });
  }
};

// Get products by category for T-Mart
exports.getProductsByCategory = async (req, res) => {
  try {
    const { category, limit = 20, page = 1 } = req.query;
    const skip = (parseInt(page) - 1) * parseInt(limit);
    
    let query = { 
      isAvailable: true,
      vendorType: 'store' // Only store products, no restaurant products
    };
    
    if (category) {
      query.category = { $regex: category, $options: 'i' };
    }
    
    const products = await Product.find(query)
      .skip(skip)
      .limit(parseInt(limit))
      .sort({ createdAt: -1 });
    
    const total = await Product.countDocuments(query);
    
    res.json({
      success: true,
      data: products,
      total,
      page: parseInt(page),
      limit: parseInt(limit),
      hasMore: skip + products.length < total
    });
  } catch (err) {
    console.error('❌ Error in getProductsByCategory:', err);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch products by category'
    });
  }
};

// Search products for T-Mart
exports.searchProducts = async (req, res) => {
  try {
    const { q, limit = 20, page = 1 } = req.query;
    const skip = (parseInt(page) - 1) * parseInt(limit);
    
    if (!q) {
      return res.status(400).json({
        success: false,
        message: 'Search query is required'
      });
    }
    
    const query = {
      isAvailable: true,
      vendorType: 'store', // Only store products, no restaurant products
      $or: [
        { name: { $regex: q, $options: 'i' } },
        { category: { $regex: q, $options: 'i' } },
        { description: { $regex: q, $options: 'i' } },
        { tags: { $in: [new RegExp(q, 'i')] } }
      ]
    };
    
    const products = await Product.find(query)
      .skip(skip)
      .limit(parseInt(limit))
      .sort({ createdAt: -1 });
    
    const total = await Product.countDocuments(query);
    
    res.json({
      success: true,
      data: products,
      total,
      page: parseInt(page),
      limit: parseInt(limit),
      hasMore: skip + products.length < total,
      query: q
    });
  } catch (err) {
    console.error('❌ Error in searchProducts:', err);
    res.status(500).json({
      success: false,
      message: 'Failed to search products'
    });
  }
};

// Get product details for T-Mart
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
    
    res.json({
      success: true,
      data: product
    });
  } catch (err) {
    console.error('❌ Error in getProductDetails:', err);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch product details'
    });
  }
};

// Get best sellers for T-Mart
exports.getBestSellers = async (req, res) => {
  try {
    const { limit = 8 } = req.query;
    
    const products = await Product.find({
      isAvailable: true,
      isBestSeller: true,
      vendorType: 'store' // Only store products, no restaurant products
    }).limit(parseInt(limit));
    
    res.json({
      success: true,
      data: products,
      total: products.length
    });
  } catch (err) {
    console.error('❌ Error in getBestSellers:', err);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch best sellers'
    });
  }
};

// Get new arrivals for T-Mart
exports.getNewArrivals = async (req, res) => {
  try {
    const { limit = 8 } = req.query;
    const oneWeekAgo = new Date();
    oneWeekAgo.setDate(oneWeekAgo.getDate() - 7);
    
    const products = await Product.find({
      isAvailable: true,
      vendorType: 'store', // Only store products, no restaurant products
      createdAt: { $gte: oneWeekAgo }
    }).limit(parseInt(limit)).sort({ createdAt: -1 });
    
    res.json({
      success: true,
      data: products,
      total: products.length
    });
  } catch (err) {
    console.error('❌ Error in getNewArrivals:', err);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch new arrivals'
    });
  }
};

// Get featured popular products for T-Mart
exports.getFeaturedPopularProducts = async (req, res) => {
  try {
    const { limit = 8 } = req.query;
    
    const products = await Product.find({
      isAvailable: true,
      isPopular: true,
      isFeatured: true,
      vendorType: 'store' // Only store products, no restaurant products
    }).limit(parseInt(limit));
    
    res.json({
      success: true,
      data: products,
      total: products.length
    });
  } catch (err) {
    console.error('❌ Error in getFeaturedPopularProducts:', err);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch featured popular products'
    });
  }
};

// Get store info for T-Mart
exports.getStoreInfo = async (req, res) => {
  try {
    const storeInfo = {
      name: 'T-Mart Express',
      description: 'Your trusted grocery delivery partner',
      rating: 4.5,
      deliveryTime: '15-30 mins',
      deliveryFee: 20,
      minimumOrder: 100,
      isOpen: true,
      image: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=400&h=400&fit=crop'
    };
    
    res.json({
      success: true,
      data: storeInfo
    });
  } catch (err) {
    console.error('❌ Error in getStoreInfo:', err);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch store info'
    });
  }
};

// Get similar products for T-Mart
exports.getSimilarProducts = async (req, res) => {
  try {
    const { productId, limit = 6 } = req.query;
    
    if (!productId) {
      return res.status(400).json({
        success: false,
        message: 'Product ID is required'
      });
    }

    // First get the current product to find its category
    const currentProduct = await Product.findById(productId);
    if (!currentProduct) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    // Find similar products based on category and other criteria
    const similarProducts = await Product.find({
      _id: { $ne: productId }, // Exclude current product
      isAvailable: true,
      vendorType: 'store', // Only store products
      $or: [
        { category: currentProduct.category }, // Same category
        { tags: { $in: currentProduct.tags || [] } }, // Similar tags
        { brand: currentProduct.brand }, // Same brand
        { 
          price: { 
            $gte: currentProduct.price * 0.7, 
            $lte: currentProduct.price * 1.3 
          } 
        }, // Similar price range
      ]
    })
    .limit(parseInt(limit))
    .sort({ 
      rating: -1, 
      reviews: -1, 
      isPopular: 1, 
      isFeatured: 1 
    });

    res.json({
      success: true,
      data: similarProducts,
      total: similarProducts.length
    });
  } catch (err) {
    console.error('❌ Error in getSimilarProducts:', err);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch similar products'
    });
  }
};

// Get similar products for regular products (restaurants/stores)
exports.getSimilarProductsGeneral = async (req, res) => {
  try {
    const { productId, limit = 6 } = req.query;
    
    if (!productId) {
      return res.status(400).json({
        success: false,
        message: 'Product ID is required'
      });
    }

    // First get the current product to find its category
    const currentProduct = await Product.findById(productId);
    if (!currentProduct) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    // Find similar products based on category and other criteria
    const similarProducts = await Product.find({
      _id: { $ne: productId }, // Exclude current product
      isAvailable: true,
      $or: [
        { category: currentProduct.category }, // Same category
        { tags: { $in: currentProduct.tags || [] } }, // Similar tags
        { brand: currentProduct.brand }, // Same brand
        { vendorId: currentProduct.vendorId }, // Same vendor
        { 
          price: { 
            $gte: currentProduct.price * 0.7, 
            $lte: currentProduct.price * 1.3 
          } 
        }, // Similar price range
      ]
    })
    .limit(parseInt(limit))
    .sort({ 
      rating: -1, 
      reviews: -1, 
      isPopular: 1, 
      isFeatured: 1 
    });

    res.json({
      success: true,
      data: similarProducts,
      total: similarProducts.length
    });
  } catch (err) {
    console.error('❌ Error in getSimilarProductsGeneral:', err);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch similar products'
    });
  }
};

// Get recently ordered items for T-Mart (requires authentication)
exports.getRecentlyOrdered = async (req, res) => {
  try {
    const { userId } = req.user;
    const { limit = 10 } = req.query;
    
    const recentOrders = await Order.find({
      userId: userId,
      status: { $in: ['delivered', 'completed'] }
    })
    .sort({ createdAt: -1 })
    .limit(parseInt(limit))
    .populate('items.productId');
    
    const recentProducts = recentOrders
      .flatMap(order => order.items)
      .map(item => item.productId)
      .filter(product => product && product.isAvailable)
      .slice(0, parseInt(limit));
    
    res.json({
      success: true,
      data: recentProducts,
      total: recentProducts.length
    });
  } catch (err) {
    console.error('❌ Error in getRecentlyOrdered:', err);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch recently ordered items'
    });
  }
}; 