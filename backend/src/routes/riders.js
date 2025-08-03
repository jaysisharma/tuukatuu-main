const express = require('express');
const router = express.Router();
const riderController = require('../controllers/riderController');
const { authenticateToken, authorizeRoles } = require('../middleware/auth');

// Apply authentication and authorization middleware to all routes
router.use(authenticateToken);
router.use(authorizeRoles('rider'));

// Profile management
router.get('/profile', riderController.getProfile);
router.put('/profile', riderController.updateProfile);

// Status management
router.put('/status', riderController.updateStatus);

// Order management
router.get('/orders/available', riderController.getAvailableOrders);
router.get('/orders', riderController.getOrders);
router.post('/orders/accept', riderController.acceptOrder);
router.put('/orders/status', riderController.updateOrderStatus);

// Earnings and performance
router.get('/earnings', riderController.getEarnings);
router.get('/performance', riderController.getPerformance);

// Account management
router.put('/change-password', riderController.changePassword);

module.exports = router; 