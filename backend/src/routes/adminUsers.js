const express = require('express');
const router = express.Router();
const { authenticateToken: auth } = require('../middleware/auth');
const adminController = require('../controllers/adminController');

// Get all users
router.get('/', auth, adminController.getUsers);

// Get user by ID
router.get('/:id', auth, (req, res) => res.json({ message: 'Get user by ID - to be implemented' }));

// Update user
router.put('/:id', auth, (req, res) => res.json({ message: 'Update user - to be implemented' }));

// Delete user
router.delete('/:id', auth, adminController.deleteUser);

// Get user orders
router.get('/:id/orders', auth, (req, res) => res.json({ message: 'Get user orders - to be implemented' }));

// Get user analytics
router.get('/:id/analytics', auth, (req, res) => res.json({ message: 'Get user analytics - to be implemented' }));

// Block/unblock user
router.patch('/:id/block', auth, adminController.blockUser);

// Get user addresses
router.get('/:id/addresses', auth, (req, res) => res.json({ message: 'Get user addresses - to be implemented' }));

module.exports = router; 