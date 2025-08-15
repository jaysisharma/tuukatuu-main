const User = require('../models/User');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const config = require('../config');
const { shuffleVendors } = require('../utils/shuffleUtils');

// Validate GeoJSON Point for storeCoordinates
const isValidGeoJSONPoint = (point) =>
  point &&
  point.type === 'Point' &&
  Array.isArray(point.coordinates) &&
  point.coordinates.length === 2 &&
  typeof point.coordinates[0] === 'number' &&
  typeof point.coordinates[1] === 'number';

// Build vendor query for geospatial + category filtering (used only in non-aggregation queries)
const buildVendorQuery = ({ category, latitude, longitude, radius }) => {
  const query = { role: 'vendor', isActive: true };

  if (category && category.toLowerCase() !== 'all') {
    query.storeTags = { $elemMatch: { $regex: category, $options: 'i' } };
  }

  if (latitude != null && longitude != null) {
    const userLat = parseFloat(latitude);
    const userLng = parseFloat(longitude);
    const maxDistanceMeters = (radius ? parseFloat(radius) : 10) * 1000;

    query.storeCoordinates = {
      $near: {
        $geometry: { type: 'Point', coordinates: [userLng, userLat] },
        $maxDistance: maxDistanceMeters,
      },
    };
  }

  return query;
};

exports.register = async (req, res) => {
  try {
    const {
      name,
      email,
      phone,
      password,
      role,
    } = req.body;

    console.log(req.body);

    if (typeof phone !== 'string') {
      return res.status(400).json({ message: 'Phone must be a string' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const userData = {
      name,
      email,
      phone,
      password: hashedPassword,
      role,
    };

    await new User(userData).save();
    res.status(201).json({ message: 'User registered successfully' });
  } catch (err) {
    console.log(err);
    res.status(400).json({ message: err.message });
  }
};

exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ message: 'Email and password required' });
    }

    const user = await User.findOne({ email });
    if (!user) return res.status(400).json({ message: 'Invalid credentials' });

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return res.status(400).json({ message: 'Invalid credentials' });

    const token = jwt.sign({ id: user._id, role: user.role }, config.jwtSecret, {
      expiresIn: '7d',
    });

    res.json({
      token,
      user: { id: user._id, name: user.name, email: user.email, role: user.role },
    });
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
    const allowedUpdates = ['name', 'phone'];
    const updates = {};

    allowedUpdates.forEach((field) => {
      if (req.body[field]) updates[field] = req.body[field];
    });

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
    if (!user) return res.status(404).json({ message: 'User not found' });

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

// exports.getVendors = async (req, res) => {
//   try {
//     const { shuffle = 'true' } = req.query;
//     const shouldShuffle = shuffle === 'true' || shuffle === '1';
    
//     let vendors = await User.find({ role: 'vendor' }).select('-password');
    
//     // Apply smart shuffling for better user experience
//     if (shouldShuffle) {
//       vendors = shuffleVendors(vendors, {
//         prioritizeFeatured: true,
//         maintainQualityOrder: true,
//         considerRating: true
//       });
//     }
    
//     res.json(vendors);
//   } catch (err) {
//     res.status(500).json({ message: err.message });
//   }
// };

// exports.getFeaturedVendors = async (req, res) => {
//   try {
//     const { shuffle = 'true' } = req.query;
//     const shouldShuffle = shuffle === 'true' || shuffle === '1';
    
//     let vendors = await User.find({ role: 'vendor', isFeatured: true }).select('-password');
    
//     // Apply smart shuffling for featured vendors
//     if (shouldShuffle) {
//       vendors = shuffleVendors(vendors, {
//         prioritizeFeatured: true,
//         maintainQualityOrder: true,
//         considerRating: true
//       });
//     }
    
//     res.json(vendors);
//   } catch (err) {
//     res.status(500).json({ message: err.message });
//   }
// };

// exports.getVendorsByCategory = async (req, res) => {
//   try {
//     const { category } = req.params;
//     let { latitude, longitude, radius, limit } = req.query;

//     limit = Math.min(parseInt(limit) || 20, 50);

//     const match = { role: 'vendor', isActive: true };

//     if (category && category.toLowerCase() !== 'all') {
//       match.storeTags = { $elemMatch: { $regex: category, $options: 'i' } };
//     }

//     const pipeline = [];

//     if (latitude != null && longitude != null) {
//       latitude = parseFloat(latitude);
//       longitude = parseFloat(longitude);
//       radius = parseFloat(radius) || 10;

//       pipeline.push({
//         $geoNear: {
//           near: { type: 'Point', coordinates: [longitude, latitude] },
//           distanceField: 'distance',
//           maxDistance: radius * 1000,
//           spherical: true,
//           query: match,
//         },
//       });
//     } else {
//       pipeline.push({ $match: match });
//     }

//     pipeline.push({ $project: { password: 0 } });

//     let vendors = await User.aggregate(pipeline);
    
//     // Apply smart shuffling for better variety while maintaining quality
//     const { shuffle = 'true' } = req.query;
//     const shouldShuffle = shuffle === 'true' || shuffle === '1';
    
//     if (shouldShuffle) {
//       vendors = shuffleVendors(vendors, {
//         prioritizeFeatured: true,
//         maintainQualityOrder: true,
//         considerRating: true
//       });
//     }

//     res.json(vendors);
//   } catch (err) {
//     res.status(500).json({ message: err.message });
//   }
// };

// exports.getNearbyVendors = async (req, res) => {
//   try {
//     let { latitude, longitude, radius, limit } = req.query;

//     if (!latitude || !longitude) {
//       return res.status(400).json({ message: 'Latitude and longitude are required' });
//     }

//     latitude = parseFloat(latitude);
//     longitude = parseFloat(longitude);
//     radius = parseFloat(radius) || 10;
//     limit = Math.min(parseInt(limit) || 20, 50);

//     const pipeline = [
//       {
//         $geoNear: {
//           near: { type: 'Point', coordinates: [longitude, latitude] },
//           distanceField: 'distance',
//           maxDistance: radius * 1000,
//           spherical: true,
//           query: { role: 'vendor', isActive: true },
//         },
//       },
//       { $project: { password: 0 } },
//     ];

//     let vendors = await User.aggregate(pipeline);
    
//     // Apply smart shuffling for nearby vendors
//     const { shuffle = 'true' } = req.query;
//     const shouldShuffle = shuffle === 'true' || shuffle === '1';
    
//     if (shouldShuffle) {
//       vendors = shuffleVendors(vendors, {
//         prioritizeFeatured: true,
//         maintainQualityOrder: true,
//         considerRating: true
//       });
//     }
    
//     res.json(vendors);
//   } catch (err) {
//     res.status(500).json({ message: err.message });
//   }
// };
