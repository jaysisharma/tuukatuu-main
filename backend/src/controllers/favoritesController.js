const User = require('../models/User');

// Get user favorites
const getUserFavorites = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    res.json(user.favorites || []);
  } catch (error) {
    console.error('Error getting user favorites:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Add item to favorites
const addToFavorites = async (req, res) => {
  try {
    const { itemId, itemType, itemName, itemImage, rating, category } = req.body;
    const user = await User.findById(req.user.id);
    
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Check if already in favorites
    const existingFavorite = user.favorites.find(
      fav => fav.itemId === itemId && fav.itemType === itemType
    );

    if (existingFavorite) {
      return res.status(400).json({ message: 'Item already in favorites' });
    }

    user.favorites.push({
      itemId,
      itemType,
      itemName,
      itemImage,
      rating,
      category,
      addedAt: new Date()
    });

    await user.save();
    res.json({ message: 'Added to favorites', favorites: user.favorites });
  } catch (error) {
    console.error('Error adding to favorites:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Remove item from favorites
const removeFromFavorites = async (req, res) => {
  try {
    const { itemId } = req.params;
    const user = await User.findById(req.user.id);
    
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    user.favorites = user.favorites.filter(
      fav => fav.itemId !== itemId
    );

    await user.save();
    res.json({ message: 'Removed from favorites', favorites: user.favorites });
  } catch (error) {
    console.error('Error removing from favorites:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Check if item is favorited
const checkIfFavorited = async (req, res) => {
  try {
    const { itemId } = req.params;
    const user = await User.findById(req.user.id);
    
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    const isFavorited = user.favorites.some(fav => fav.itemId === itemId);
    res.json({ isFavorited });
  } catch (error) {
    console.error('Error checking if favorited:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Get favorites count
const getFavoritesCount = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    
    const count = user.favorites ? user.favorites.length : 0;
    res.json({ count });
  } catch (error) {
    console.error('Error getting favorites count:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Clear all favorites
const clearAllFavorites = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    user.favorites = [];
    await user.save();
    res.json({ message: 'All favorites cleared' });
  } catch (error) {
    console.error('Error clearing favorites:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

module.exports = {
  getUserFavorites,
  addToFavorites,
  removeFromFavorites,
  checkIfFavorited,
  getFavoritesCount,
  clearAllFavorites
}; 