const Product = require('../models/Product');
const Banner = require('../models/Banner');
const Category = require('../models/Category');
const User = require('../models/User');
const { calculateDistance } = require('../utils/locationUtils');

// Utility function to shuffle arrays
const shuffleArray = (array) => {
  const shuffled = [...array];
  for (let i = shuffled.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
  }
  return shuffled;
};

// Get mart home data (banners, categories, featured products)
exports.getMartHome = async (req, res) => {
  try {
    // Get T-Mart banners first, then fallback to general banners
    let banners = await Banner.find({ 
      bannerType: 'tmart',
      isActive: true,
      startDate: { $lte: new Date() },
      $or: [
        { endDate: null },
        { endDate: { $gt: new Date() } }
      ]
    }).sort({ sortOrder: 1, priority: 1, createdAt: -1 });
    
    // If no T-Mart banners found, get general banners
    if (banners.length === 0) {
      banners = await Banner.find({ 
        isActive: true,
        startDate: { $lte: new Date() },
        $or: [
          { endDate: null },
          { endDate: { $gt: new Date() } }
        ]
      }).sort({ sortOrder: 1, priority: 1, createdAt: -1 });
    }

    // Get categories
    const categories = await Category.find({ isActive: true }).sort({ order: 1 });

    // Get daily essentials (store products marked as daily essentials)
    const dailyEssentials = await Product.find({
      dailyEssential: true,
      isAvailable: true,
      vendorType: 'store'
    })
    .select('name price imageUrl category rating reviews dailyEssential isFeaturedDailyEssential')
    .populate('vendorId', 'storeName storeImage')
    .sort({ isFeaturedDailyEssential: -1, rating: -1, createdAt: -1 })
    .limit(4);

    // Get trending products (store products with high ratings)
    const trendingProducts = await Product.find({ 
      isAvailable: true,
      vendorType: 'store',
      rating: { $gte: 4.0 },
      reviews: { $gte: 10 }
    }).populate('vendorId', 'storeName storeImage').limit(6);

    // Get explore products (featured store products)
    const exploreProducts = await Product.find({ 
      isAvailable: true,
      vendorType: 'store',
      isFeatured: true
    }).populate('vendorId', 'storeName storeImage').limit(10);

    // Shuffle all product arrays
    const shuffledDailyEssentials = shuffleArray(dailyEssentials);
    const shuffledTrendingProducts = shuffleArray(trendingProducts);
    const shuffledExploreProducts = shuffleArray(exploreProducts);

    res.json({
      success: true,
      data: {
        banners,
        categories,
        dailyEssentials: shuffledDailyEssentials,
        trendingProducts: shuffledTrendingProducts,
        exploreProducts: shuffledExploreProducts
      }
    });
  } catch (err) {
    console.error('❌ Error in getMartHome:', err);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch mart home data'
    });
  }
};

// Get location-based trending products
exports.getLocationBasedTrendingProducts = async (req, res) => {
  try {
    const { latitude, longitude, limit = 6, radius = 10 } = req.query;
    
    if (!latitude || !longitude) {
      return res.status(400).json({
        success: false,
        message: 'Latitude and longitude are required'
      });
    }

    const userLat = parseFloat(latitude);
    const userLng = parseFloat(longitude);
    const searchRadius = parseFloat(radius);

    // Get all vendors with store type
    const vendors = await User.find({ 
      role: 'vendor',
      vendorType: 'store',
      isActive: true
    }).select('_id storeName storeCoordinates storeRating storeReviews');

    // Check if any vendors have coordinates
    const vendorsWithCoordinates = vendors.filter(vendor => vendor.storeCoordinates?.coordinates);
    
    let trendingProducts = [];
    
    if (vendorsWithCoordinates.length > 0) {
      // Filter vendors within radius and get their products
      const nearbyVendors = vendorsWithCoordinates.filter(vendor => {
        const coords = vendor.storeCoordinates.coordinates;
        const vendorLat = coords[1]; // latitude is at index 1
        const vendorLng = coords[0]; // longitude is at index 0
        
        // Calculate distance using Haversine formula
        const distance = calculateDistance(
          { latitude: userLat, longitude: userLng },
          { latitude: vendorLat, longitude: vendorLng }
        );
        
        return distance <= searchRadius;
      });

      const vendorIds = nearbyVendors.map(vendor => vendor._id);

      // Get trending products from nearby vendors
      trendingProducts = await Product.find({ 
        isAvailable: true,
        vendorType: 'store',
        vendorId: { $in: vendorIds },
        rating: { $gte: 4.0 },
        reviews: { $gte: 5 }
      })
      .populate('vendorId', 'storeName storeImage storeCoordinates')
      .sort({ rating: -1, reviews: -1, isPopular: -1 })
      .limit(parseInt(limit) * 2); // Get more to allow for distance sorting

      // Sort products by distance and rating
      trendingProducts = trendingProducts.map(product => {
        const vendor = product.vendorId;
        if (vendor?.storeCoordinates?.coordinates) {
          const coords = vendor.storeCoordinates.coordinates;
          const vendorLat = coords[1]; // latitude is at index 1
          const vendorLng = coords[0]; // longitude is at index 0
          
          const distance = calculateDistance(
            { latitude: userLat, longitude: userLng },
            { latitude: vendorLat, longitude: vendorLng }
          );
          
          return {
            ...product.toObject(),
            distance: distance,
            vendorDistance: distance
          };
        }
        return {
          ...product.toObject(),
          distance: 999, // Far away if no coordinates
          vendorDistance: 999
        };
      });

      // Sort by distance first, then by rating
      trendingProducts.sort((a, b) => {
        if (a.distance !== b.distance) {
          return a.distance.compareTo(b.distance);
        }
        return (b.rating ?? 0).compareTo(a.rating ?? 0);
      });
    }
    
    // If no location-based products found, get trending products from all vendors
    if (trendingProducts.length === 0) {
      trendingProducts = await Product.find({ 
        isAvailable: true,
        vendorType: 'store',
        rating: { $gte: 4.0 },
        reviews: { $gte: 5 }
      })
      .populate('vendorId', 'storeName storeImage storeCoordinates')
      .sort({ rating: -1, reviews: -1, isPopular: -1, createdAt: -1 })
      .limit(parseInt(limit) * 2);

      // Add distance as null to indicate no location data
      trendingProducts = trendingProducts.map(product => ({
        ...product.toObject(),
        distance: null,
        vendorDistance: null
      }));
    }

    // Limit to requested number
    trendingProducts = trendingProducts.slice(0, parseInt(limit));

    // Shuffle the final results for variety
    const shuffledTrendingProducts = shuffleArray(trendingProducts);

    res.json({
      success: true,
      data: shuffledTrendingProducts,
      total: trendingProducts.length,
      userLocation: { latitude: userLat, longitude: userLng },
      searchRadius: searchRadius,
      hasLocationData: vendorsWithCoordinates.length > 0 && trendingProducts.some(p => p.distance !== null)
    });
  } catch (err) {
    console.error('❌ Error in getLocationBasedTrendingProducts:', err);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch location-based trending products'
    });
  }
};

// Get products by category for mart
exports.getProductsByCategory = async (req, res) => {
  try {
    const { category, subcategory, limit = 20, page = 1, sort = 'name' } = req.query;
    const skip = (parseInt(page) - 1) * parseInt(limit);
    
    let query = { 
      isAvailable: true,
      vendorType: 'store'
    };
    
    if (category && category !== 'all') {
      query.category = { $regex: new RegExp(category, 'i') };
    }

    // Add subcategory filtering if provided
    if (subcategory && subcategory !== 'all') {
      query.subcategory = { $regex: new RegExp(subcategory, 'i') };
    }

    // Get products by category
    const products = await Product.find(query)
      .populate('vendorId', 'storeName storeImage')
      .sort(sort === 'price' ? { price: 1 } : { name: 1 })
      .limit(limit)
      .skip(skip);

    // Shuffle products for variety
    const shuffledProducts = shuffleArray(products);

    // Get total count for pagination
    const total = await Product.countDocuments(query);
    const pages = Math.ceil(total / limit);

    res.json({
      success: true,
      data: shuffledProducts,
      pagination: {
        page,
        limit,
        total,
        pages,
        hasNext: page < pages,
        hasPrev: page > 1
      }
    });
  } catch (err) {
    console.error('❌ Error in getProductsByCategory:', err);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch products by category'
    });
  }
};

// Get store products (products from a specific vendor)
exports.getStoreProducts = async (req, res) => {
  try {
    const { storeId, limit = 20, page = 1 } = req.query;
    const skip = (parseInt(page) - 1) * parseInt(limit);
    
    if (!storeId) {
      return res.status(400).json({
        success: false,
        message: 'Store ID is required'
      });
    }

    // Verify the store exists and is a store vendor
    const store = await User.findOne({ 
      _id: storeId, 
      role: 'vendor', 
      vendorType: 'store',
      isActive: true 
    });

    if (!store) {
      return res.status(404).json({
        success: false,
        message: 'Store not found'
      });
    }

    // Get products from the store
    const products = await Product.find({
      vendorId: storeId,
      isAvailable: true
    })
    .populate('vendorId', 'storeName storeImage')
    .sort({ createdAt: -1 })
    .limit(limit)
    .skip(skip);

    // Shuffle products for variety
    const shuffledProducts = shuffleArray(products);

    // Get total count for pagination
    const total = await Product.countDocuments({
      vendorId: storeId,
      isAvailable: true
    });
    const pages = Math.ceil(total / limit);

    res.json({
      success: true,
      data: shuffledProducts,
      pagination: {
        page,
        limit,
        total,
        pages,
        hasNext: page < pages,
        hasPrev: page > 1
      }
    });
  } catch (err) {
    console.error('❌ Error in getStoreProducts:', err);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch store products'
    });
  }
};

// Get featured stores
exports.getFeaturedStores = async (req, res) => {
  try {
    const { limit = 10 } = req.query;
    
    const stores = await User.find({
      role: 'vendor',
      isActive: true,
      isFeatured: true
    }).select('storeName storeImage storeDescription storeRating storeReviews vendorType');

    // Shuffle stores for variety
    const shuffledStores = shuffleArray(stores);

    res.json({
      success: true,
      data: shuffledStores
    });
  } catch (err) {
    console.error('❌ Error in getFeaturedStores:', err);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch featured stores'
    });
  }
};

// Search products in mart
exports.searchMartProducts = async (req, res) => {
  try {
    const { q, category, minPrice, maxPrice, sort = 'relevance', limit = 20, page = 1 } = req.query;
    const skip = (parseInt(page) - 1) * parseInt(limit);
    
    let query = { 
      isAvailable: true,
      vendorType: 'store'
    };
    
    // Text search
    if (q) {
      query.$or = [
        { name: { $regex: new RegExp(q, 'i') } },
        { category: { $regex: new RegExp(q, 'i') } },
        { brand: { $regex: new RegExp(q, 'i') } },
        { tags: { $in: [new RegExp(q, 'i')] } }
      ];
    }
    
    // Category filter
    if (category && category !== 'all') {
      query.category = { $regex: new RegExp(category, 'i') };
    }
    
    // Price filter
    if (minPrice || maxPrice) {
      query.price = {};
      if (minPrice) query.price.$gte = parseFloat(minPrice);
      if (maxPrice) query.price.$lte = parseFloat(maxPrice);
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
      case 'popular':
        sortQuery = { reviews: -1 };
        break;
      case 'newest':
        sortQuery = { createdAt: -1 };
        break;
      default:
        sortQuery = { isFeatured: -1, rating: -1 }; // relevance
    }

    // Get products with pagination
    const products = await Product.find(query)
      .populate('vendorId', 'storeName storeImage')
      .sort(sortQuery)
      .limit(limit)
      .skip(skip);

    // Shuffle products for variety
    const shuffledProducts = shuffleArray(products);

    // Get total count for pagination
    const total = await Product.countDocuments(query);
    const pages = Math.ceil(total / limit);

    res.json({
      success: true,
      data: shuffledProducts,
      pagination: {
        page,
        limit,
        total,
        pages,
        hasNext: page < pages,
        hasPrev: page > 1
      }
    });
  } catch (err) {
    console.error('❌ Error in searchMartProducts:', err);
    res.status(500).json({
      success: false,
      message: 'Failed to search products'
    });
  }
};

// Get product details for mart
exports.getProductDetails = async (req, res) => {
  try {
    const { productId } = req.params;
    
    const product = await Product.findOne({ 
      _id: productId,
      isAvailable: true,
      vendorType: 'store'
    }).populate('vendorId', 'storeName storeImage storeRating storeAddress');

    if (!product) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    // Get similar products from same category
    const similarProducts = await Product.find({
      category: product.category,
      _id: { $ne: productId },
      isAvailable: true,
      vendorType: 'store'
    })
    .populate('vendorId', 'storeName storeImage')
    .limit(4);

    res.json({
      success: true,
      data: {
        product,
        similarProducts
      }
    });
  } catch (err) {
    console.error('❌ Error in getProductDetails:', err);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch product details'
    });
  }
};

// Get mart categories
exports.getMartCategories = async (req, res) => {
  try {
    const categories = await Category.find({ 
      isActive: true 
    }).sort({ sortOrder: 1, name: 1 });

    res.json({
      success: true,
      data: categories
    });
  } catch (err) {
    console.error('❌ Error in getMartCategories:', err);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch categories'
    });
  }
};

// Get user favorites (store products only)
exports.getUserFavorites = async (req, res) => {
  try {
    const userId = req.user.id;
    
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Get favorite store products
    const favoriteProducts = await Product.find({
      _id: { $in: user.favorites.filter(fav => fav.itemType === 'product').map(fav => fav.itemId) },
      isAvailable: true,
      vendorType: 'store'
    }).populate('vendorId', 'storeName storeImage storeRating');

    res.json({
      success: true,
      data: favoriteProducts,
      total: favoriteProducts.length
    });
  } catch (err) {
    console.error('❌ Error in getUserFavorites:', err);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch user favorites'
    });
  }
};

// Get user recent products (store products only)
exports.getUserRecentProducts = async (req, res) => {
  try {
    const userId = req.user.id;
    const { limit = 10 } = req.query;
    
    // Get recent orders for this user
    const Order = require('../models/Order');
    const recentOrders = await Order.find({ 
      customerId: userId,
      status: { $in: ['delivered', 'completed'] }
    })
    .sort({ updatedAt: -1 })
    .limit(parseInt(limit))
    .populate('items.productId');

    // Extract unique store products from recent orders
    const recentProductIds = [...new Set(
      recentOrders.flatMap(order => 
        order.items
          .filter(item => item.productId && item.productId.vendorType === 'store')
          .map(item => item.productId._id)
      )
    )];

    const recentProducts = await Product.find({
      _id: { $in: recentProductIds },
      isAvailable: true,
      vendorType: 'store'
    }).populate('vendorId', 'storeName storeImage storeRating');

    res.json({
      success: true,
      data: recentProducts,
      total: recentProducts.length
    });
  } catch (err) {
    console.error('❌ Error in getUserRecentProducts:', err);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch recent products'
    });
  }
};
