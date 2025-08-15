const express = require('express');
const router = express.Router();
const dailyEssentialController = require('../controllers/dailyEssentialController');
const { authenticateToken, requireAdmin } = require('../middleware/auth');

// Public routes (no auth required)
router.get('/', dailyEssentialController.getDailyEssentials);

// Admin routes (require admin authentication)
router.post('/admin/add', authenticateToken, requireAdmin, dailyEssentialController.addDailyEssential);
router.delete('/admin/remove', authenticateToken, requireAdmin, dailyEssentialController.removeDailyEssential);
router.patch('/admin/toggle', authenticateToken, requireAdmin, dailyEssentialController.toggleDailyEssential);
router.patch('/admin/toggle-featured', authenticateToken, requireAdmin, dailyEssentialController.toggleFeaturedDailyEssential);
router.get('/admin/products', authenticateToken, requireAdmin, dailyEssentialController.getAllProductsWithDailyEssentialStatus);
router.get('/admin/all', authenticateToken, requireAdmin, dailyEssentialController.getDailyEssentials);

module.exports = router; 
