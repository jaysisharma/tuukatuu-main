const express = require('express');
const router = express.Router();
const { authenticateToken: auth } = require('../middleware/auth');
const userController = require('../controllers/userController');

// Get user profile
router.get('/profile', auth, userController.getProfile);

// Update user profile
router.put('/profile', auth, userController.updateProfile);

// Get user orders
router.get('/orders', auth, userController.getUserOrders);

// Get user favorites
router.get('/favorites', auth, userController.getUserFavorites);

// Add to favorites
router.post('/favorites', auth, userController.addToFavorites);

// Remove from favorites
router.delete('/favorites/:itemId', auth, userController.removeFromFavorites);

// Get user addresses
router.get('/addresses', auth, userController.getUserAddresses);

// Add user address
router.post('/addresses', auth, userController.addAddress);

// Update user address
router.put('/addresses/:id', auth, userController.updateAddress);

// Delete user address
router.delete('/addresses/:id', auth, userController.deleteAddress);

// Get user notifications
router.get('/notifications', auth, userController.getNotifications);

// Mark notification as read
router.patch('/notifications/:id/read', auth, userController.markNotificationAsRead);

// Delete notification
router.delete('/notifications/:id', auth, userController.deleteNotification);

module.exports = router; 