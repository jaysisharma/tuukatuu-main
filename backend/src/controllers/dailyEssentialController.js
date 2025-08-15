const Product = require('../models/Product');

exports.getDailyEssentials = async (req, res) => {
  try {
    const dailyEssentials = await Product.find({ dailyEssential: true })
      .select('name price imageUrl category dailyEssential isFeaturedDailyEssential')
      .sort({ isFeaturedDailyEssential: -1, createdAt: -1 });
    
    res.status(200).json({
      success: true,
      data: dailyEssentials
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching daily essentials',
      error: error.message
    });
  }
}

// Toggle daily essential status - add if not present, remove if present
exports.toggleDailyEssential = async (req, res) => {
  try {
    const { productId, isFeatured = false } = req.body;
    
    if (!productId) {
      return res.status(400).json({
        success: false,
        message: 'Product ID is required'
      });
    }

    const product = await Product.findById(productId);
    if (!product) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    // Toggle the daily essential status
    const wasDailyEssential = product.dailyEssential;
    product.dailyEssential = !wasDailyEssential;
    
    // If removing from daily essentials, also remove featured status
    if (!product.dailyEssential) {
      product.isFeaturedDailyEssential = false;
    } else {
      // If adding to daily essentials, set featured status if specified
      product.isFeaturedDailyEssential = isFeatured;
    }

    await product.save();

    const message = product.dailyEssential 
      ? 'Product added to daily essentials'
      : 'Product removed from daily essentials';

    res.status(200).json({
      success: true,
      message: message,
      data: {
        productId: product._id,
        name: product.name,
        dailyEssential: product.dailyEssential,
        isFeaturedDailyEssential: product.isFeaturedDailyEssential
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error toggling daily essential status',
      error: error.message
    });
  }
}

exports.addDailyEssential = async (req, res) => {
  try{
    const { productId, isFeatured = false } = req.body;
    
    if (!productId) {
      return res.status(400).json({
        success: false,
        message: 'Product ID is required'
      });
    }

    const product = await Product.findById(productId);
    if(!product){
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    if (product.dailyEssential) {
      return res.status(400).json({
        success: false,
        message: 'Product is already a daily essential'
      });
    }

    product.dailyEssential = true;
    product.isFeaturedDailyEssential = isFeatured;
    await product.save(); 
    
    res.status(200).json({
      success: true,
      message: 'Product added to daily essentials',
      data: {
        productId: product._id,
        name: product.name,
        dailyEssential: product.dailyEssential,
        isFeaturedDailyEssential: product.isFeaturedDailyEssential
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error adding product to daily essentials',
      error: error.message
    });
  }
}

exports.removeDailyEssential = async (req, res) => {
  try{
    const { productId } = req.body;
    
    if (!productId) {
      return res.status(400).json({
        success: false,
        message: 'Product ID is required'
      });
    }

    const product = await Product.findById(productId);
    if(!product){
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    if (!product.dailyEssential) {
      return res.status(400).json({
        success: false,
        message: 'Product is not a daily essential'
      });
    }

    product.dailyEssential = false;
    product.isFeaturedDailyEssential = false;
    await product.save();
    
    res.status(200).json({
      success: true,
      message: 'Product removed from daily essentials',
      data: {
        productId: product._id,
        name: product.name,
        dailyEssential: product.dailyEssential,
        isFeaturedDailyEssential: product.isFeaturedDailyEssential
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error removing product from daily essentials',
      error: error.message
    });
  }
}

exports.toggleFeaturedDailyEssential = async (req, res) => {
  try{
    const { productId } = req.body;
    
    if (!productId) {
      return res.status(400).json({
        success: false,
        message: 'Product ID is required'
      });
    }

    const product = await Product.findById(productId);
    if(!product){
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }
    
    if (!product.dailyEssential) {
      return res.status(400).json({
        success: false,
        message: 'Product must be a daily essential to be featured'
      });
    }
    
    product.isFeaturedDailyEssential = !product.isFeaturedDailyEssential;
    await product.save();
    
    const message = product.isFeaturedDailyEssential 
      ? 'Product marked as featured daily essential'
      : 'Product unmarked as featured daily essential';
      
    res.status(200).json({
      success: true,
      message: message,
      data: {
        productId: product._id,
        name: product.name,
        dailyEssential: product.dailyEssential,
        isFeaturedDailyEssential: product.isFeaturedDailyEssential
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error toggling featured status',
      error: error.message
    });
  }
}

// Get all products with their daily essential status for admin
exports.getAllProductsWithDailyEssentialStatus = async (req, res) => {
  try {
    const { page = 1, limit = 20, search = '', filter = 'all' } = req.query;
    
    const query = {};
    
    // Apply search filter
    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { category: { $regex: search, $options: 'i' } }
      ];
    }
    
    // Apply daily essential filter
    if (filter === 'daily-essential') {
      query.dailyEssential = true;
    } else if (filter === 'featured-daily-essential') {
      query.dailyEssential = true;
      query.isFeaturedDailyEssential = true;
    } else if (filter === 'not-daily-essential') {
      query.dailyEssential = false;
    }

    const skip = (page - 1) * limit;
    
    const [products, total] = await Promise.all([
      Product.find(query)
        .select('name price imageUrl category dailyEssential isFeaturedDailyEssential createdAt')
        .sort({ dailyEssential: -1, isFeaturedDailyEssential: -1, createdAt: -1 })
        .skip(skip)
        .limit(parseInt(limit)),
      Product.countDocuments(query)
    ]);

    const totalPages = Math.ceil(total / limit);

    res.status(200).json({
      success: true,
      data: products,
      pagination: {
        current: parseInt(page),
        pages: totalPages,
        total,
        limit: parseInt(limit)
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching products with daily essential status',
      error: error.message
    });
  }
}