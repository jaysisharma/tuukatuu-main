const express = require('express');
const router = express.Router();
const dailyEssentialController = require('../controllers/dailyEssentialController');
const { authenticateToken, requireAdmin } = require('../middleware/auth');

// Public routes (for mobile app)
router.get('/', dailyEssentialController.getDailyEssentials);

// Admin routes (require authentication and admin role)
router.use(authenticateToken, requireAdmin);

// Daily essential management
router.post('/add', dailyEssentialController.addDailyEssential);
router.post('/remove', dailyEssentialController.removeDailyEssential);
router.post('/toggle-featured', dailyEssentialController.toggleFeaturedDailyEssential);

module.exports = router; 