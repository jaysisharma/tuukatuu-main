const User = require('../models/User');
const { shuffleVendors } = require('../utils/shuffleUtils');

exports.getAllUsers = async (role, search) => {
  const query = {};
  if (role) query.role = role;
  if (search) {
    query.$or = [
      { name: { $regex: search, $options: 'i' } },
      { email: { $regex: search, $options: 'i' } },
      { phone: { $regex: search, $options: 'i' } },
    ];
  }
  return await User.find(query).select('-password');
};

exports.blockUser = async (id) => {
  return await User.findByIdAndUpdate(id, { isActive: false }, { new: true }).select('-password');
};

exports.activateUser = async (id) => {
  return await User.findByIdAndUpdate(id, { isActive: true }, { new: true }).select('-password');
};

exports.updateUserRole = async (id, role) => {
  if (!['admin', 'vendor', 'rider', 'customer'].includes(role)) {
    throw new Error('Invalid role');
  }
  return await User.findByIdAndUpdate(id, { role }, { new: true }).select('-password');
};

exports.getVendors = async (search, options = {}) => {
  const { shuffle = true } = options;
  const query = { role: 'vendor' };
  if (search) {
    query.$or = [
      { name: { $regex: search, $options: 'i' } },
      { email: { $regex: search, $options: 'i' } },
      { phone: { $regex: search, $options: 'i' } },
      { storeName: { $regex: search, $options: 'i' } },
    ];
  }
  let vendors = await User.find(query).select('-password');
  
  if (shuffle) {
    vendors = shuffleVendors(vendors, {
      prioritizeFeatured: true,
      maintainQualityOrder: true,
      considerRating: true
    });
  }
  
  return vendors;
};

exports.approveVendor = async (id) => {
  return await User.findOneAndUpdate({ _id: id, role: 'vendor' }, { isActive: true }, { new: true }).select('-password');
};

exports.rejectVendor = async (id) => {
  return await User.findOneAndUpdate({ _id: id, role: 'vendor' }, { isActive: false }, { new: true }).select('-password');
};

exports.editVendor = async (id, updates) => {
  const allowed = ['storeName', 'storeDescription', 'storeImage', 'storeBanner', 'storeTags', 'isFeatured'];
  const updateData = {};
  for (const key of allowed) {
    if (updates[key] !== undefined) updateData[key] = updates[key];
  }
  return await User.findOneAndUpdate({ _id: id, role: 'vendor' }, updateData, { new: true }).select('-password');
};

exports.getVendorPerformance = async (id) => {
  const vendor = await User.findOne({ _id: id, role: 'vendor' }).select('-password');
  if (!vendor) throw new Error('Vendor not found');
  return {
    storeRating: vendor.storeRating,
    storeReviews: vendor.storeReviews,
  };
}; 