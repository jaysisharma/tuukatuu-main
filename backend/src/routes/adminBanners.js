const express = require('express');
const router = express.Router();
const { authenticateToken: auth } = require('../middleware/auth');
const bannersController = require('../controllers/bannersController');
const upload = require('../middleware/upload');

// Get all banners with pagination and filtering
router.get('/', auth, bannersController.getAllBannersAdmin);

// Get banner statistics (must come before /:id routes)
router.get('/statistics', auth, bannersController.getBannerStatistics);

// Bulk update banners (must come before /:id routes)
router.post('/bulk-update', auth, bannersController.bulkUpdateBanners);

// Get banner by ID
router.get('/:id', auth, bannersController.getBannerById);

// Create banner
router.post('/', auth, upload.single('image'), bannersController.createBanner);

// Update banner
router.put('/:id', auth, upload.single('image'), bannersController.updateBanner);

// Delete banner
router.delete('/:id', auth, bannersController.deleteBanner);

// Toggle banner status
router.patch('/:id/toggle-status', auth, bannersController.toggleBannerStatus);

// Get banner analytics
router.get('/:id/analytics', auth, bannersController.getBannerAnalytics);

module.exports = router; 