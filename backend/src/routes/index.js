const express = require('express');
const router = express.Router();

// Public routes
router.use('/auth', require('./auth'));
router.use('/users', require('./users'));
router.use('/vendors', require('./vendors'));
router.use('/products', require('./products'));
router.use('/orders', require('./orders'));
router.use('/addresses', require('./addresses'));
router.use('/banners', require('./banners'));
router.use('/categories', require('./categories'));
router.use('/favorites', require('./favorites'));
router.use('/tmart', require('./tmart'));
router.use('/mart', require('./mart'));
router.use('/today-deals', require('./todayDeals'));
router.use('/daily-essentials', require('./dailyEssentials'));

// Admin routes
router.use('/admin', require('./admin'));
router.use('/admin/featured-products', require('./adminFeaturedProducts'));
router.use('/admin/banners', require('./adminBanners'));
router.use('/admin/categories', require('./adminCategories'));
router.use('/admin/orders', require('./adminOrders'));
router.use('/admin/users', require('./adminUsers'));
router.use('/admin/vendors', require('./adminVendors'));
router.use('/admin/products', require('./adminProducts'));
router.use('/admin/addresses', require('./adminAddresses'));

// Customer routes
router.use('/customer', require('./customer'));

module.exports = router;
