const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const { authenticateToken } = require('../middleware/auth');

router.post('/register', authController.register);
router.post('/login', authController.login);
router.get('/me', authenticateToken, authController.getMe);
router.put('/me', authenticateToken, authController.updateMe);
router.put('/change-password', authenticateToken, authController.changePassword);
// router.get('/vendors', authController.getVendors);
// router.get('/featured-vendors', authController.getFeaturedVendors);
// router.get('/vendors/category/:category', authController.getVendorsByCategory);
// router.get('/vendors/nearby', authController.getNearbyVendors);

module.exports = router;
