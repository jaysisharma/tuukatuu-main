const User = require('../models/User');

// Get user favorites
const getUserFavorites = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    
    // Debug: Log user object structure
    console.log('🔍 User object keys:', Object.keys(user.toObject()));
    console.log('🔍 User favorites field:', user.favorites);
    console.log('🔍 User favorites type:', typeof user.favorites);
    
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
    console.log('🔍 Adding to favorites:', { itemId, itemType, itemName, itemImage, rating, category });
    
    const user = await User.findById(req.user.id);
    console.log('🔍 User found:', user ? 'Yes' : 'No');
    console.log('🔍 User object:', JSON.stringify(user, null, 2));
    
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Initialize favorites array if it doesn't exist
    if (!user.favorites) {
      console.log('🔍 Initializing favorites array');
      user.favorites = [];
    }
    console.log('🔍 Current favorites:', user.favorites);

    // Check if already in favorites
    const existingFavorite = user.favorites.find(
      fav => fav.itemId === itemId && fav.itemType === itemType
    );

    if (existingFavorite) {
      return res.status(400).json({ message: 'Item already in favorites' });
    }

    const newFavorite = {
      itemId,
      itemType,
      itemName,
      itemImage,
      rating,
      category,
      addedAt: new Date()
    };
    
    console.log('🔍 Adding new favorite:', newFavorite);
    user.favorites.push(newFavorite);
    console.log('🔍 Updated favorites array:', user.favorites);

    console.log('🔍 Saving user...');
    await user.save();
    console.log('🔍 User saved successfully');
    
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

    // Initialize favorites array if it doesn't exist
    if (!user.favorites) {
      user.favorites = [];
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

    // Initialize favorites array if it doesn't exist
    if (!user.favorites) {
      user.favorites = [];
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

// Test endpoint to check user schema
const testUserSchema = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    
    // Get the raw user document
    const userDoc = user.toObject();
    
    res.json({
      message: 'User schema test',
      userKeys: Object.keys(userDoc),
      hasFavorites: 'favorites' in userDoc,
      favoritesType: typeof userDoc.favorites,
      favoritesValue: userDoc.favorites,
      userSchema: User.schema.obj
    });
  } catch (error) {
    console.error('Error testing user schema:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

module.exports = {
  getUserFavorites,
  addToFavorites,
  removeFromFavorites,
  checkIfFavorited,
  getFavoritesCount,
  clearAllFavorites,
  testUserSchema
}; 