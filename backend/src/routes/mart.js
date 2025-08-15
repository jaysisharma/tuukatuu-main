const express = require('express');
const router = express.Router();
const martController = require('../controllers/martController');
const { authenticateToken } = require('../middleware/auth');

// Public mart routes (no authentication required)
router.get('/home', martController.getMartHome);
router.get('/categories', martController.getMartCategories);
router.get('/products/category', martController.getProductsByCategory);
router.get('/products/:productId', martController.getProductDetails);
router.get('/search', martController.searchMartProducts);
router.get('/stores/featured', martController.getFeaturedStores);
router.get('/stores/:storeId/products', martController.getStoreProducts);
router.get('/trending/location', martController.getLocationBasedTrendingProducts);

// Protected routes (authentication required)
router.get('/user/favorites', authenticateToken, martController.getUserFavorites);
router.get('/user/recent', authenticateToken, martController.getUserRecentProducts);

module.exports = router;
