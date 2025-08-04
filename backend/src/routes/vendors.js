const express = require('express');
const router = express.Router();
const { authenticateToken: auth } = require('../middleware/auth');
const vendorController = require('../controllers/vendorController');

// Get all vendors
router.get('/', vendorController.getAllVendors);

// Get vendor by ID
router.get('/:id', vendorController.getVendorById);

// Get vendor products
router.get('/:id/products', vendorController.getVendorProducts);

// Get vendor orders
router.get('/:id/orders', auth, vendorController.getVendorOrders);

// Get vendor analytics
router.get('/:id/analytics', auth, vendorController.getVendorAnalytics);

// Update vendor profile
router.put('/profile', auth, vendorController.updateVendorProfile);

// Get vendor categories
router.get('/:id/categories', vendorController.getVendorCategories);

// Get nearby vendors
router.get('/nearby', vendorController.getNearbyVendors);

// Get vendors by category
router.get('/category/:category', vendorController.getVendorsByCategory);

// Get featured vendors
router.get('/featured', vendorController.getFeaturedVendors);

// Get vendors by type (restaurant/store)
router.get('/type', vendorController.getVendorsByType);

// Get vendors for map display
router.get('/map', vendorController.getVendorsForMap);

// Get vendors within map bounds
router.get('/map/bounds', vendorController.getVendorsInBounds);

module.exports = router; 