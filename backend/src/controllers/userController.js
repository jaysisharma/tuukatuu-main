const User = require('../models/User');
const Order = require('../models/Order');
const Address = require('../models/Address');
const Notification = require('../models/Notification');

// Get user profile
const getProfile = async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('-password');
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    res.json(user);
  } catch (error) {
    console.error('Error getting user profile:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Update user profile
const updateProfile = async (req, res) => {
  try {
    const { name, email, phone, avatar } = req.body;
    const user = await User.findById(req.user.id);
    
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    if (name) user.name = name;
    if (email) user.email = email;
    if (phone) user.phone = phone;
    if (avatar) user.avatar = avatar;

    await user.save();
    res.json({ message: 'Profile updated successfully', user });
  } catch (error) {
    console.error('Error updating user profile:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Get user orders
const getUserOrders = async (req, res) => {
  try {
    const orders = await Order.find({ user: req.user.id })
      .populate('vendor', 'storeName storeImage')
      .sort({ createdAt: -1 });
    res.json(orders);
  } catch (error) {
    console.error('Error getting user orders:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Get user favorites
const getUserFavorites = async (req, res) => {
  try {
    const user = await User.findById(req.user.id).populate('favorites');
    res.json(user.favorites || []);
  } catch (error) {
    console.error('Error getting user favorites:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Add to favorites
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

// Remove from favorites
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

// Get user addresses
const getUserAddresses = async (req, res) => {
  try {
    const addresses = await Address.find({ user: req.user.id });
    res.json(addresses);
  } catch (error) {
    console.error('Error getting user addresses:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Add user address
const addAddress = async (req, res) => {
  try {
    const { label, address, coordinates, isDefault } = req.body;
    const newAddress = new Address({
      user: req.user.id,
      label,
      address,
      coordinates,
      isDefault
    });

    if (isDefault) {
      // Set all other addresses to non-default
      await Address.updateMany(
        { user: req.user.id },
        { isDefault: false }
      );
    }

    await newAddress.save();
    res.json({ message: 'Address added successfully', address: newAddress });
  } catch (error) {
    console.error('Error adding address:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Update user address
const updateAddress = async (req, res) => {
  try {
    const { id } = req.params;
    const { label, address, coordinates, isDefault } = req.body;
    
    const addressDoc = await Address.findOne({ _id: id, user: req.user.id });
    if (!addressDoc) {
      return res.status(404).json({ message: 'Address not found' });
    }

    if (label) addressDoc.label = label;
    if (address) addressDoc.address = address;
    if (coordinates) addressDoc.coordinates = coordinates;
    if (isDefault !== undefined) addressDoc.isDefault = isDefault;

    if (isDefault) {
      // Set all other addresses to non-default
      await Address.updateMany(
        { user: req.user.id, _id: { $ne: id } },
        { isDefault: false }
      );
    }

    await addressDoc.save();
    res.json({ message: 'Address updated successfully', address: addressDoc });
  } catch (error) {
    console.error('Error updating address:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Delete user address
const deleteAddress = async (req, res) => {
  try {
    const { id } = req.params;
    const address = await Address.findOneAndDelete({ _id: id, user: req.user.id });
    
    if (!address) {
      return res.status(404).json({ message: 'Address not found' });
    }

    res.json({ message: 'Address deleted successfully' });
  } catch (error) {
    console.error('Error deleting address:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Get user notifications
const getNotifications = async (req, res) => {
  try {
    const notifications = await Notification.find({ user: req.user.id })
      .sort({ createdAt: -1 });
    res.json(notifications);
  } catch (error) {
    console.error('Error getting notifications:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Mark notification as read
const markNotificationAsRead = async (req, res) => {
  try {
    const { id } = req.params;
    const notification = await Notification.findOneAndUpdate(
      { _id: id, user: req.user.id },
      { isRead: true },
      { new: true }
    );

    if (!notification) {
      return res.status(404).json({ message: 'Notification not found' });
    }

    res.json({ message: 'Notification marked as read', notification });
  } catch (error) {
    console.error('Error marking notification as read:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Delete notification
const deleteNotification = async (req, res) => {
  try {
    const { id } = req.params;
    const notification = await Notification.findOneAndDelete({ _id: id, user: req.user.id });
    
    if (!notification) {
      return res.status(404).json({ message: 'Notification not found' });
    }

    res.json({ message: 'Notification deleted successfully' });
  } catch (error) {
    console.error('Error deleting notification:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

module.exports = {
  getProfile,
  updateProfile,
  getUserOrders,
  getUserFavorites,
  addToFavorites,
  removeFromFavorites,
  getUserAddresses,
  addAddress,
  updateAddress,
  deleteAddress,
  getNotifications,
  markNotificationAsRead,
  deleteNotification
}; 