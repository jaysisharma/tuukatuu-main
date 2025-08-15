const express = require('express');
const router = express.Router();
const productsController = require('../controllers/productsController');
const { authenticateToken, requireAdmin } = require('../middleware/auth');
const Product = require('../models/Product'); // Added missing import for Product model

// Apply admin middleware to all routes
router.use(authenticateToken, requireAdmin);

// Get all products with admin filters
router.get('/', async (req, res) => {
  try {
    const { vendorId, search, page = 1, limit = 20, isAvailable, isFeatured, isPopular, category } = req.query;
    const query = {};
    
    if (vendorId) query.vendorId = vendorId;
    if (isAvailable !== undefined) query.isAvailable = isAvailable === 'true';
    if (isFeatured === 'true') query.isFeatured = true;
    if (isPopular === 'true') query.isPopular = true;
    if (category) query.category = { $regex: category, $options: 'i' };
    
    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { category: { $regex: search, $options: 'i' } },
        { description: { $regex: search, $options: 'i' } },
      ];
    }
    
    const skip = (parseInt(page) - 1) * parseInt(limit);
    const [products, total] = await Promise.all([
      Product.find(query)
        .populate({ 
          path: 'vendorId', 
          select: 'storeName storeDescription storeImage storeBanner storeRating storeReviews storeAddress vendorType vendorSubType storeTags storeCategories' 
        })
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(parseInt(limit)),
      Product.countDocuments(query)
    ]);
    
    const totalPages = Math.ceil(total / parseInt(limit));
    
    res.json({ 
      products, 
      total,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        totalPages
      }
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Get product by ID
router.get('/:id', async (req, res) => {
  try {
    const product = await Product.findById(req.params.id)
      .populate({ 
        path: 'vendorId', 
        select: 'storeName storeDescription storeImage storeBanner storeRating storeReviews storeAddress vendorType vendorSubType storeTags storeCategories' 
      });
    
    if (!product) {
      return res.status(404).json({ message: 'Product not found' });
    }
    
    res.json(product);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Create product (admin can create products for any vendor)
router.post('/', productsController.createProduct);

// Update product
router.put('/:id', productsController.updateProduct);

// Delete product
router.delete('/:id', productsController.deleteProduct);

// Approve product
router.patch('/:id/approve', async (req, res) => {
  try {
    const product = await Product.findByIdAndUpdate(
      req.params.id, 
      { isApproved: true, approvedAt: new Date() }, 
      { new: true }
    );
    
    if (!product) {
      return res.status(404).json({ message: 'Product not found' });
    }
    
    res.json(product);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Reject product
router.patch('/:id/reject', async (req, res) => {
  try {
    const { reason } = req.body;
    const product = await Product.findByIdAndUpdate(
      req.params.id, 
      { 
        isApproved: false, 
        rejectedAt: new Date(),
        rejectionReason: reason 
      }, 
      { new: true }
    );
    
    if (!product) {
      return res.status(404).json({ message: 'Product not found' });
    }
    
    res.json(product);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Get product analytics
router.get('/:id/analytics', async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);
    if (!product) {
      return res.status(404).json({ message: 'Product not found' });
    }
    
    // Basic analytics - you can expand this based on your needs
    const analytics = {
      productId: product._id,
      name: product.name,
      views: product.views || 0,
      sales: product.sales || 0,
      revenue: (product.price * (product.sales || 0)),
      rating: product.rating || 0,
      reviews: product.reviews || 0,
      createdAt: product.createdAt,
      lastUpdated: product.updatedAt
    };
    
    res.json(analytics);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Get products by vendor
router.get('/vendor/:vendorId', async (req, res) => {
  try {
    const { page = 1, limit = 20 } = req.query;
    const skip = (parseInt(page) - 1) * parseInt(limit);
    
    const [products, total] = await Promise.all([
      Product.find({ vendorId: req.params.vendorId })
        .populate({ 
          path: 'vendorId', 
          select: 'storeName storeDescription storeImage storeBanner storeRating storeReviews storeAddress vendorType vendorSubType storeTags storeCategories' 
        })
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(parseInt(limit)),
      Product.countDocuments({ vendorId: req.params.vendorId })
    ]);
    
    const totalPages = Math.ceil(total / parseInt(limit));
    
    res.json({ 
      products, 
      total,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        totalPages
      }
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Get products by category
router.get('/category/:category', async (req, res) => {
  try {
    const { page = 1, limit = 20 } = req.query;
    const skip = (parseInt(page) - 1) * parseInt(limit);
    
    const [products, total] = await Promise.all([
      Product.find({ 
        category: { $regex: req.params.category, $options: 'i' },
        isAvailable: true 
      })
        .populate({ 
          path: 'vendorId', 
          select: 'storeName storeDescription storeImage storeBanner storeRating storeReviews storeAddress vendorType vendorSubType storeTags storeCategories' 
        })
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(parseInt(limit)),
      Product.countDocuments({ 
        category: { $regex: req.params.category, $options: 'i' },
        isAvailable: true 
      })
    ]);
    
    const totalPages = Math.ceil(total / parseInt(limit));
    
    res.json({ 
      products, 
      total,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        totalPages
      }
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router; 