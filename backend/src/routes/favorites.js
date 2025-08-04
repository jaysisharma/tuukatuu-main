const express = require('express');
const router = express.Router();
const { authenticateToken: auth } = require('../middleware/auth');
const favoritesController = require('../controllers/favoritesController');

// Get user favorites
router.get('/', auth, favoritesController.getUserFavorites);

// Add item to favorites
router.post('/', auth, favoritesController.addToFavorites);

// Remove item from favorites
router.delete('/:itemId', auth, favoritesController.removeFromFavorites);

// Check if item is favorited
router.get('/check/:itemId', auth, favoritesController.checkIfFavorited);

// Get favorites count
router.get('/count', auth, favoritesController.getFavoritesCount);

// Clear all favorites
router.delete('/', auth, favoritesController.clearAllFavorites);

module.exports = router; 