const Product = require('../models/Product');

// Get all products with featured status
exports.getAllProducts = async (req, res) => {
  try {
    const { page = 1, limit = 20, search = '', category = '', featured = '' } = req.query;
    const skip = (parseInt(page) - 1) * parseInt(limit);
    
    let query = {};
    
    // Search filter
    if (search) {
      query.name = { $regex: search, $options: 'i' };
    }
    
    // Category filter
    if (category) {
      query.category = { $regex: category, $options: 'i' };
    }
    
    // Featured filter
    if (featured === 'true') {
      query.isFeatured = true;
    } else if (featured === 'false') {
      query.isFeatured = false;
    }
    
    const products = await Product.find(query)
      .populate('vendorId', 'storeName storeRating')
      .sort({ featuredOrder: 1, createdAt: -1 })
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
  } catch (error) {
    console.error('❌ Error in getAllProducts:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch products'
    });
  }
};

// Get featured products
exports.getFeaturedProducts = async (req, res) => {
  try {
    const products = await Product.getFeaturedPopularProducts();
    
    res.json({
      success: true,
      data: products,
      total: products.length
    });
  } catch (error) {
    console.error('❌ Error in getFeaturedProducts:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch featured products'
    });
  }
};

// Toggle featured status
exports.toggleFeatured = async (req, res) => {
  try {
    const { productId } = req.params;
    const { isFeatured, featuredOrder } = req.body;
    
    const product = await Product.findById(productId);
    if (!product) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }
    
    const updateData = {};
    if (isFeatured !== undefined) {
      updateData.isFeatured = isFeatured;
    }
    if (featuredOrder !== undefined) {
      updateData.featuredOrder = featuredOrder;
    }
    
    const updatedProduct = await Product.findByIdAndUpdate(
      productId,
      updateData,
      { new: true }
    ).populate('vendorId', 'storeName storeRating');
    
    res.json({
      success: true,
      data: updatedProduct,
      message: `Product ${isFeatured ? 'featured' : 'unfeatured'} successfully`
    });
  } catch (error) {
    console.error('❌ Error in toggleFeatured:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update featured status'
    });
  }
};

// Update featured order
exports.updateFeaturedOrder = async (req, res) => {
  try {
    const { products } = req.body; // Array of { productId, featuredOrder }
    
    if (!Array.isArray(products)) {
      return res.status(400).json({
        success: false,
        message: 'Products array is required'
      });
    }
    
    const updatePromises = products.map(({ productId, featuredOrder }) =>
      Product.findByIdAndUpdate(productId, { featuredOrder }, { new: true })
    );
    
    const updatedProducts = await Promise.all(updatePromises);
    
    res.json({
      success: true,
      data: updatedProducts,
      message: 'Featured order updated successfully'
    });
  } catch (error) {
    console.error('❌ Error in updateFeaturedOrder:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update featured order'
    });
  }
};

// Bulk toggle featured status
exports.bulkToggleFeatured = async (req, res) => {
  try {
    const { productIds, isFeatured } = req.body;
    
    if (!Array.isArray(productIds)) {
      return res.status(400).json({
        success: false,
        message: 'Product IDs array is required'
      });
    }
    
    const result = await Product.updateMany(
      { _id: { $in: productIds } },
      { isFeatured }
    );
    
    res.json({
      success: true,
      message: `${result.modifiedCount} products ${isFeatured ? 'featured' : 'unfeatured'} successfully`
    });
  } catch (error) {
    console.error('❌ Error in bulkToggleFeatured:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update featured status'
    });
  }
};

// Get categories for filtering
exports.getCategories = async (req, res) => {
  try {
    const categories = await Product.distinct('category');
    
    res.json({
      success: true,
      data: categories
    });
  } catch (error) {
    console.error('❌ Error in getCategories:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch categories'
    });
  }
}; 