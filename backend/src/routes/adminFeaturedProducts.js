const express = require('express');
const router = express.Router();
const adminFeaturedProductsController = require('../controllers/adminFeaturedProductsController');
const { authenticateToken, requireAdmin } = require('../middleware/auth');

// Apply admin middleware to all routes
router.use(authenticateToken, requireAdmin);

// Get all products with filters
router.get('/products', adminFeaturedProductsController.getAllProducts);

// Get featured products
router.get('/featured', adminFeaturedProductsController.getFeaturedProducts);

// Get categories for filtering
router.get('/categories', adminFeaturedProductsController.getCategories);

// Toggle featured status for a single product
router.patch('/products/:productId/featured', adminFeaturedProductsController.toggleFeatured);

// Update featured order
router.put('/featured-order', adminFeaturedProductsController.updateFeaturedOrder);

// Bulk toggle featured status
router.post('/bulk-toggle-featured', adminFeaturedProductsController.bulkToggleFeatured);

module.exports = router; 