const express = require('express');
const router = express.Router();
const tmartController = require('../controllers/tmartController');
const { authenticateToken } = require('../middleware/auth');

// Banners and Categories
router.get('/banners', tmartController.getBanners);
router.get('/categories', tmartController.getCategories);
router.get('/categories/featured', tmartController.getFeaturedCategories);
router.get('/daily-essentials', tmartController.getDailyEssentials);

// Products
router.get('/products/:productId', tmartController.getProductDetails);
router.get('/category/query', tmartController.getProductsByCategory);
router.get('/search', tmartController.searchProducts);
router.get('/best-sellers', tmartController.getBestSellers);
router.get('/popular', tmartController.getPopularProducts);
router.get('/featured-popular', tmartController.getFeaturedPopularProducts);
router.get('/new-arrivals', tmartController.getNewArrivals);
router.get('/recommendations', tmartController.getRecommendations);

// Deals and Offers
router.get('/deals', tmartController.getDeals);
router.get('/deals/today', tmartController.getTodayDeals);

// Store and User specific
router.get('/store-info', tmartController.getStoreInfo);
router.get('/recently-ordered', authenticateToken, tmartController.getRecentlyOrdered);
router.get('/similar', tmartController.getSimilarProducts);
router.get('/similar-general', tmartController.getSimilarProductsGeneral);

module.exports = router; 