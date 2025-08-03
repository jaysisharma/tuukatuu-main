const User = require('../models/User');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');

exports.register = async (req, res) => {
  try {
    const { name, email, phone, password, role, storeName, storeDescription, storeImage, storeBanner, storeTags, storeCategories, storeCoordinates, storeAddress } = req.body;
    if (typeof phone !== 'string') {
      return res.status(400).json({ message: 'Phone must be a string' });
    }
    const hashedPassword = await bcrypt.hash(password, 10);
    const userData = { name, email, phone, password: hashedPassword, role };
    
    // Add store-specific fields if registering as vendor
    if (role === 'vendor') {
      userData.storeName = storeName;
      userData.storeDescription = storeDescription;
      userData.storeImage = storeImage;
      userData.storeBanner = storeBanner;
      userData.storeTags = Array.isArray(storeTags) ? storeTags : (typeof storeTags === 'string' ? storeTags.split(',').map(t => t.trim()).filter(Boolean) : []);
      userData.storeCategories = Array.isArray(storeCategories) ? storeCategories : (typeof storeCategories === 'string' ? storeCategories.split(',').map(t => t.trim()).filter(Boolean) : []);
      userData.storeCoordinates = storeCoordinates;
      userData.storeAddress = storeAddress;
    }
    
    const user = new User(userData);
    await user.save();
    res.status(201).json({ message: 'User registered successfully' });
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ email });
    if (!user) return res.status(400).json({ message: 'Invalid credentials' });
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return res.status(400).json({ message: 'Invalid credentials' });
    const token = jwt.sign({ id: user._id, role: user.role }, process.env.JWT_SECRET, { expiresIn: '7d' });
    res.json({ token, user: { id: user._id, name: user.name, email: user.email, role: user.role } });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getMe = async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('-password');
    res.json(user);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.updateMe = async (req, res) => {
  try {
    const updates = {};
    if (req.body.name) updates.name = req.body.name;
    if (req.body.phone) updates.phone = req.body.phone;
    const user = await User.findByIdAndUpdate(req.user.id, updates, { new: true }).select('-password');
    res.json(user);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.changePassword = async (req, res) => {
  try {
    const { oldPassword, newPassword } = req.body;
    if (!oldPassword || !newPassword) {
      return res.status(400).json({ message: 'Old and new password required' });
    }
    const user = await User.findById(req.user.id);
    const isMatch = await bcrypt.compare(oldPassword, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: 'Old password is incorrect' });
    }
    user.password = await bcrypt.hash(newPassword, 10);
    await user.save();
    res.json({ message: 'Password changed successfully' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getVendors = async (req, res) => {
  try {
    const vendors = await User.find({ role: 'vendor' }).select('-password');
    res.json(vendors);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getFeaturedVendors = async (req, res) => {
  try {
    const vendors = await User.find({ role: 'vendor', isFeatured: true }).select('-password');
    res.json(vendors);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getVendorsByCategory = async (req, res) => {
  try {
    const { category } = req.params;
    const { latitude, longitude, radius = 10 } = req.query; // radius in km
    
    console.log('🔍 getVendorsByCategory called with:', { category, latitude, longitude, radius });
    
    let query = { role: 'vendor', isActive: true };
    
    // Filter by category (using storeTags - more reliable)
    if (category && category !== 'all') {
      // Use storeTags instead of storeCategories for better matching
      query.storeTags = { $regex: category, $options: 'i' };
      console.log('🔍 Query:', JSON.stringify(query));
    }
    
    let vendors = await User.find(query).select('-password');
    console.log(`🔍 Found ${vendors.length} vendors for category "${category}"`);
    
    // Log the first few vendors for debugging
    vendors.slice(0, 3).forEach(vendor => {
      console.log(`🔍 Vendor: ${vendor.storeName}, tags: ${JSON.stringify(vendor.storeTags)}`);
    });
    
    // Filter by distance if coordinates provided
    if (latitude && longitude) {
      const userLat = parseFloat(latitude);
      const userLng = parseFloat(longitude);
      const maxRadius = parseFloat(radius);
      
      vendors = vendors.filter(vendor => {
        if (!vendor.storeCoordinates) return false;
        
        const distance = calculateDistance(
          userLat, userLng,
          vendor.storeCoordinates.latitude,
          vendor.storeCoordinates.longitude
        );
        
        return distance <= maxRadius;
      });
      
      // Sort by distance
      vendors.sort((a, b) => {
        const distanceA = calculateDistance(
          userLat, userLng,
          a.storeCoordinates.latitude,
          a.storeCoordinates.longitude
        );
        const distanceB = calculateDistance(
          userLat, userLng,
          b.storeCoordinates.latitude,
          b.storeCoordinates.longitude
        );
        return distanceA.compareTo(distanceB);
      });
    }
    
    console.log(`🔍 Returning ${vendors.length} vendors`);
    res.json(vendors);
  } catch (err) {
    console.error('❌ Error in getVendorsByCategory:', err);
    res.status(500).json({ message: err.message });
  }
};

exports.getNearbyVendors = async (req, res) => {
  try {
    const { latitude, longitude, radius = 10 } = req.query; // radius in km
    
    if (!latitude || !longitude) {
      return res.status(400).json({ message: 'Latitude and longitude are required' });
    }
    
    const userLat = parseFloat(latitude);
    const userLng = parseFloat(longitude);
    const maxRadius = parseFloat(radius);
    
    const vendors = await User.find({ 
      role: 'vendor', 
      isActive: true,
      storeCoordinates: { $exists: true, $ne: null }
    }).select('-password');
    
    const nearbyVendors = vendors
      .filter(vendor => {
        const distance = calculateDistance(
          userLat, userLng,
          vendor.storeCoordinates.latitude,
          vendor.storeCoordinates.longitude
        );
        return distance <= maxRadius;
      })
      .sort((a, b) => {
        const distanceA = calculateDistance(
          userLat, userLng,
          a.storeCoordinates.latitude,
          a.storeCoordinates.longitude
        );
        const distanceB = calculateDistance(
          userLat, userLng,
          b.storeCoordinates.latitude,
          b.storeCoordinates.longitude
        );
        return distanceA.compareTo(distanceB);
      });
    
    res.json(nearbyVendors);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Helper function to calculate distance between two points using Haversine formula
function calculateDistance(lat1, lon1, lat2, lon2) {
  const R = 6371; // Radius of the Earth in kilometers
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const a = 
    Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) * 
    Math.sin(dLon/2) * Math.sin(dLon/2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
  const distance = R * c; // Distance in kilometers
  return distance;
} 