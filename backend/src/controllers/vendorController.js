const User = require('../models/User');
const Product = require('../models/Product');
const Order = require('../models/Order');
const { shuffleVendors } = require('../utils/shuffleUtils');

// Get all vendors
const getAllVendors = async (req, res) => {
  try {
    const { shuffle = 'true' } = req.query;
    const shouldShuffle = shuffle === 'true' || shuffle === '1';
    
    let vendors = await User.find({ 
      role: 'vendor', 
      isActive: true 
    }).select('-password');
    
    // Apply smart shuffling for better user experience
    if (shouldShuffle) {
      vendors = shuffleVendors(vendors, {
        prioritizeFeatured: true,
        maintainQualityOrder: true,
        considerRating: true
      });
    }
    
    res.json(vendors);
  } catch (error) {
    console.error('Error getting all vendors:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Get vendor by ID
const getVendorById = async (req, res) => {
  try {
    const vendor = await User.findOne({ 
      _id: req.params.id, 
      role: 'vendor' 
    }).select('-password');
    if (!vendor) {
      return res.status(404).json({ message: 'Vendor not found' });
    }
    res.json(vendor);
  } catch (error) {
    console.error('Error getting vendor by ID:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Get vendor products
const getVendorProducts = async (req, res) => {
  try {
    const products = await Product.find({ vendorId: req.params.id, isAvailable: true });
    res.json(products);
  } catch (error) {
    console.error('Error getting vendor products:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Get vendor orders
const getVendorOrders = async (req, res) => {
  try {
    const orders = await Order.find({ vendorId: req.params.id })
      .populate('userId', 'name email phone')
      .sort({ createdAt: -1 });
    res.json(orders);
  } catch (error) {
    console.error('Error getting vendor orders:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Get vendor analytics
const getVendorAnalytics = async (req, res) => {
  try {
    const vendorId = req.params.id;
    
    // Get total orders
    const totalOrders = await Order.countDocuments({ vendorId: vendorId });
    
    // Get total revenue
    const revenue = await Order.aggregate([
      { $match: { vendorId: vendorId, status: 'completed' } },
      { $group: { _id: null, total: { $sum: '$totalAmount' } } }
    ]);
    
    // Get recent orders
    const recentOrders = await Order.find({ vendorId: vendorId })
      .sort({ createdAt: -1 })
      .limit(10);
    
    res.json({
      totalOrders,
      totalRevenue: revenue[0]?.total || 0,
      recentOrders
    });
  } catch (error) {
    console.error('Error getting vendor analytics:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Update vendor profile
const updateVendorProfile = async (req, res) => {
  try {
    const { storeName, storeDescription, storeImage, storeAddress, storePhone } = req.body;
    const vendor = await User.findOne({ _id: req.user.id, role: 'vendor' });
    
    if (!vendor) {
      return res.status(404).json({ message: 'Vendor not found' });
    }

    if (storeName) vendor.storeName = storeName;
    if (storeDescription) vendor.storeDescription = storeDescription;
    if (storeImage) vendor.storeImage = storeImage;
    if (storeAddress) vendor.storeAddress = storeAddress;
    if (storePhone) vendor.storePhone = storePhone;

    await vendor.save();
    res.json({ message: 'Profile updated successfully', vendor });
  } catch (error) {
    console.error('Error updating vendor profile:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Get vendor categories
const getVendorCategories = async (req, res) => {
  try {
    const products = await Product.find({ vendor: req.params.id, isActive: true });
    const categories = [...new Set(products.map(product => product.category))];
    res.json(categories);
  } catch (error) {
    console.error('Error getting vendor categories:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Get nearby vendors
const getNearbyVendors = async (req, res) => {
  try {
    const { latitude, longitude, radius = 10, shuffle = 'true' } = req.query;
    const shouldShuffle = shuffle === 'true' || shuffle === '1';
    
    if (!latitude || !longitude) {
      return res.status(400).json({ message: 'Latitude and longitude are required' });
    }

    let vendors = await Vendor.find({
      isApproved: true,
      storeCoordinates: {
        $near: {
          $geometry: {
            type: 'Point',
            coordinates: [parseFloat(longitude), parseFloat(latitude)]
          },
          $maxDistance: parseFloat(radius) * 1000 // Convert km to meters
        }
      }
    }).select('-password');

    // Apply smart shuffling for nearby vendors
    if (shouldShuffle) {
      vendors = shuffleVendors(vendors, {
        prioritizeFeatured: true,
        maintainQualityOrder: true,
        considerRating: true
      });
    }

    res.json(vendors);
  } catch (error) {
    console.error('Error getting nearby vendors:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Get vendors by category
const getVendorsByCategory = async (req, res) => {
  try {
    const { category } = req.params;
    const { shuffle = 'true' } = req.query;
    const shouldShuffle = shuffle === 'true' || shuffle === '1';
    
    let vendors = await Vendor.find({
      isApproved: true,
      categories: { $in: [category] }
    }).select('-password');
    
    // Apply smart shuffling for vendors by category
    if (shouldShuffle) {
      vendors = shuffleVendors(vendors, {
        prioritizeFeatured: true,
        maintainQualityOrder: true,
        considerRating: true
      });
    }
    
    res.json(vendors);
  } catch (error) {
    console.error('Error getting vendors by category:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Get featured vendors
const getFeaturedVendors = async (req, res) => {
  try {
    const { shuffle = 'true' } = req.query;
    const shouldShuffle = shuffle === 'true' || shuffle === '1';
    
    let vendors = await Vendor.find({ 
      isApproved: true, 
      isFeatured: true 
    }).select('-password');
    
    // Apply smart shuffling for featured vendors
    if (shouldShuffle) {
      vendors = shuffleVendors(vendors, {
        prioritizeFeatured: true,
        maintainQualityOrder: true,
        considerRating: true
      });
    }
    
    res.json(vendors);
  } catch (error) {
    console.error('Error getting featured vendors:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Get vendors by type (restaurant/store)
const getVendorsByType = async (req, res) => {
  try {
    const { type, subType, shuffle = 'true' } = req.query;
    const shouldShuffle = shuffle === 'true' || shuffle === '1';
    const User = require('../models/User');
    
    let query = { 
      role: 'vendor', 
      isActive: true 
    };
    
    if (type) {
      query.vendorType = type;
    }
    
    if (subType) {
      query.vendorSubType = subType;
    }
    
    let vendors = await User.find(query)
      .select('-password')
      .sort({ storeRating: -1, storeReviews: -1 });
    
    // Apply smart shuffling for vendors by type
    if (shouldShuffle) {
      vendors = shuffleVendors(vendors, {
        prioritizeFeatured: true,
        maintainQualityOrder: true,
        considerRating: true
      });
    }
    
    console.log(`🔍 Found ${vendors.length} vendors for type: ${type}, subType: ${subType}`);
    
    res.json({
      success: true,
      data: vendors,
      total: vendors.length,
      filters: { type, subType }
    });
  } catch (error) {
    console.error('Error getting vendors by type:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Get vendors for map display
const getVendorsForMap = async (req, res) => {
  try {
    const { shuffle = 'true' } = req.query;
    const shouldShuffle = shuffle === 'true' || shuffle === '1';
    
    let vendors = await Vendor.getVendorsForMap();
    
    // Apply smart shuffling for map vendors
    if (shouldShuffle) {
      vendors = shuffleVendors(vendors, {
        prioritizeFeatured: true,
        maintainQualityOrder: true,
        considerRating: true
      });
    }
    
    res.json(vendors);
  } catch (error) {
    console.error('Error getting vendors for map:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Get vendors within map bounds
const getVendorsInBounds = async (req, res) => {
  try {
    const { bounds, shuffle = 'true' } = req.query;
    const shouldShuffle = shuffle === 'true' || shuffle === '1';
    
    if (!bounds) {
      return res.status(400).json({ message: 'Bounds parameter is required' });
    }

    let boundsObj;
    try {
      boundsObj = JSON.parse(bounds);
    } catch (e) {
      return res.status(400).json({ message: 'Invalid bounds format' });
    }

    let vendors = await Vendor.getVendorsInBounds(boundsObj);
    
    // Apply smart shuffling for vendors in bounds
    if (shouldShuffle) {
      vendors = shuffleVendors(vendors, {
        prioritizeFeatured: true,
        maintainQualityOrder: true,
        considerRating: true
      });
    }
    
    res.json(vendors);
  } catch (error) {
    console.error('Error getting vendors in bounds:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

module.exports = {
  getAllVendors,
  getVendorById,
  getVendorProducts,
  getVendorOrders,
  getVendorAnalytics,
  updateVendorProfile,
  getVendorCategories,
  getNearbyVendors,
  getVendorsByCategory,
  getFeaturedVendors,
  getVendorsByType,
  getVendorsForMap,
  getVendorsInBounds
}; 