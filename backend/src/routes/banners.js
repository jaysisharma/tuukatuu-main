const express = require('express');
const router = express.Router();
const bannersController = require('../controllers/bannersController');
const { authenticateToken, authorizeRoles } = require('../middleware/auth');
const upload = require('../middleware/upload');

// Public routes (no auth required)
router.get('/', bannersController.getAllBanners);
router.get('/:id', bannersController.getBannerById);
router.post('/:id/click', bannersController.recordBannerClick);

// Note: Admin routes are now handled in /admin/banners to avoid conflicts
// All admin operations moved to adminBanners.js

module.exports = router; 