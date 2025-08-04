const express = require('express');
const router = express.Router();

router.use('/auth', require('./auth'));
router.use('/products', require('./products'));
router.use('/orders', require('./orders'));
router.use('/tmart', require('./tmart'));
router.use('/addresses', require('./addresses'));
router.use('/location', require('./location'));
router.use('/coupons', require('./coupons'));
router.use('/banners', require('./banners'));
router.use('/admin', require('./admin'));
router.use('/admin/featured-products', require('./adminFeaturedProducts'));
router.use('/riders', require('./riders'));
router.use('/categories', require('./categories'));
router.use('/daily-essentials', require('./dailyEssentials'));
router.use('/', require('./todayDeals'));

module.exports = router; 