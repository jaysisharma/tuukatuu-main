const User = require('../models/User');
const Product = require('../models/Product');
const Order = require('../models/Order');
const Rider = require('../models/Rider');
const bcrypt = require('bcryptjs');
const { successResponse, errorResponse } = require('../utils/response');
const logger = require('../utils/logger');

exports.getUsers = async (req, res) => {
  try {
    const { role, search } = req.query;
    const query = {};
    if (role) query.role = role;
    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } },
        { phone: { $regex: search, $options: 'i' } },
      ];
    }
    const users = await User.find(query).select('-password');
    res.json(users);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.blockUser = async (req, res) => {
  try {
    const user = await User.findByIdAndUpdate(req.params.id, { isActive: false }, { new: true }).select('-password');
    if (!user) return res.status(404).json({ message: 'User not found' });
    res.json(user);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.activateUser = async (req, res) => {
  try {
    const user = await User.findByIdAndUpdate(req.params.id, { isActive: true }, { new: true }).select('-password');
    if (!user) return res.status(404).json({ message: 'User not found' });
    res.json(user);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.updateUserRole = async (req, res) => {
  try {
    const { role } = req.body;
    if (!['admin', 'vendor', 'rider', 'customer'].includes(role)) {
      return res.status(400).json({ message: 'Invalid role' });
    }
    const user = await User.findByIdAndUpdate(req.params.id, { role }, { new: true }).select('-password');
    if (!user) return res.status(404).json({ message: 'User not found' });
    res.json(user);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.deleteUser = async (req, res) => {
  try {
    const user = await User.findByIdAndDelete(req.params.id).select('-password');
    if (!user) return res.status(404).json({ message: 'User not found' });
    res.json(user);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.createUser = async (req, res) => {
  try {
    const { name, email, phone, password, role = 'customer', isActive = true, isFeatured = false, storeName, storeDescription, storeImage, storeBanner, storeTags, storeCategories, storeCoordinates, storeAddress } = req.body;
    if (!name || !email || !phone || !password) {
      return res.status(400).json({ message: 'Name, email, phone, and password are required' });
    }
    const existing = await User.findOne({ $or: [{ email }, { phone }] });
    if (existing) {
      return res.status(400).json({ message: 'Email or phone already exists' });
    }
    const hashedPassword = await bcrypt.hash(password, 10);
    const userData = { name, email, phone, password: hashedPassword, role, isActive };
    if (role === 'vendor') {
      userData.storeName = storeName;
      userData.storeDescription = storeDescription;
      userData.storeImage = storeImage;
      userData.storeBanner = storeBanner;
      userData.storeTags = Array.isArray(storeTags) ? storeTags : (typeof storeTags === 'string' ? storeTags.split(',').map(t => t.trim()).filter(Boolean) : []);
      userData.storeCategories = Array.isArray(storeCategories) ? storeCategories : (typeof storeCategories === 'string' ? storeCategories.split(',').map(t => t.trim()).filter(Boolean) : []);
      userData.isFeatured = isFeatured;
      userData.storeCoordinates = storeCoordinates;
      userData.storeAddress = storeAddress;
    }
    const user = new User(userData);
    await user.save();
    const userObj = user.toObject();
    delete userObj.password;
    res.status(201).json(userObj);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

exports.getVendors = async (req, res) => {
  try {
    const { search } = req.query;
    const query = { role: 'vendor' };
    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } },
        { phone: { $regex: search, $options: 'i' } },
        { storeName: { $regex: search, $options: 'i' } },
      ];
    }
    const vendors = await User.find(query).select('-password');
    res.json(vendors);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.approveVendor = async (req, res) => {
  try {
    const vendor = await User.findOneAndUpdate({ _id: req.params.id, role: 'vendor' }, { isActive: true }, { new: true }).select('-password');
    if (!vendor) return res.status(404).json({ message: 'Vendor not found' });
    res.json(vendor);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.rejectVendor = async (req, res) => {
  try {
    const vendor = await User.findOneAndUpdate({ _id: req.params.id, role: 'vendor' }, { isActive: false }, { new: true }).select('-password');
    if (!vendor) return res.status(404).json({ message: 'Vendor not found' });
    res.json(vendor);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.editVendor = async (req, res) => {
  try {
    const allowed = ['storeName', 'storeDescription', 'storeImage', 'storeBanner', 'storeTags', 'isFeatured'];
    const updates = {};
    for (const key of allowed) {
      if (req.body[key] !== undefined) updates[key] = req.body[key];
    }
    const vendor = await User.findOneAndUpdate({ _id: req.params.id, role: 'vendor' }, updates, { new: true }).select('-password');
    if (!vendor) return res.status(404).json({ message: 'Vendor not found' });
    res.json(vendor);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getVendorPerformance = async (req, res) => {
  try {
    const vendor = await User.findOne({ _id: req.params.id, role: 'vendor' }).select('-password');
    if (!vendor) return res.status(404).json({ message: 'Vendor not found' });
    res.json({
      storeRating: vendor.storeRating,
      storeReviews: vendor.storeReviews,
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getVendorProducts = async (req, res) => {
  try {
    const products = await Product.find({ vendorId: req.params.id });
    res.json(products);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getVendorSales = async (req, res) => {
  try {
    const orders = await Order.find({ vendorId: req.params.id, status: { $ne: 'cancelled' } });
    const totalSales = orders.reduce((sum, o) => sum + (o.total || 0), 0);
    res.json({ totalSales, orderCount: orders.length });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getDashboardStats = async (req, res) => {
  try {
    const [
      totalUsers,
      totalVendors,
      totalCustomers,
      totalRiders,
      totalProducts,
      totalOrders,
      totalCoupons,
      totalBanners,
      activeVendors,
      featuredVendors,
      activeCustomers,
      orders
    ] = await Promise.all([
      User.countDocuments(),
      User.countDocuments({ role: 'vendor' }),
      User.countDocuments({ role: 'customer' }),
      User.countDocuments({ role: 'rider' }),
      Product.countDocuments(),
      Order.countDocuments(),
      require('../models/Coupon').countDocuments(),
      require('../models/Banner').countDocuments(),
      User.countDocuments({ role: 'vendor', isActive: true }),
      User.countDocuments({ role: 'vendor', isFeatured: true }),
      User.countDocuments({ role: 'customer', isActive: true }),
      Order.find().sort({ createdAt: -1 }).limit(5).populate('customerId', 'name').populate('vendorId', 'storeName')
    ]);
    const totalSales = (await Order.aggregate([
      { $match: { status: { $ne: 'cancelled' } } },
      { $group: { _id: null, total: { $sum: '$total' } } }
    ]))[0]?.total || 0;
    res.json({
      totalUsers,
      totalVendors,
      totalCustomers,
      totalRiders,
      totalProducts,
      totalOrders,
      totalCoupons,
      totalBanners,
      activeVendors,
      featuredVendors,
      activeCustomers,
      totalSales,
      recentOrders: orders
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getSalesAnalytics = async (req, res) => {
  try {
    const Order = require('../models/Order');
    const Product = require('../models/Product');
    const User = require('../models/User');
    const now = new Date();
    // Sales by day (last 30 days)
    const days = Array.from({length: 30}, (_, i) => {
      const d = new Date(now);
      d.setDate(now.getDate() - (29 - i));
      d.setHours(0,0,0,0);
      return d;
    });
    const salesByDay = await Promise.all(days.map(async (day, i) => {
      const nextDay = new Date(day); nextDay.setDate(day.getDate() + 1);
      const orders = await Order.find({ createdAt: { $gte: day, $lt: nextDay }, status: { $ne: 'cancelled' } });
      const total = orders.reduce((sum, o) => sum + (o.total || 0), 0);
      return { date: day, total };
    }));
    // Sales by month (last 12 months)
    const months = Array.from({length: 12}, (_, i) => {
      const d = new Date(now);
      d.setMonth(now.getMonth() - (11 - i), 1);
      d.setHours(0,0,0,0);
      return d;
    });
    const salesByMonth = await Promise.all(months.map(async (month, i) => {
      const nextMonth = new Date(month); nextMonth.setMonth(month.getMonth() + 1);
      const orders = await Order.find({ createdAt: { $gte: month, $lt: nextMonth }, status: { $ne: 'cancelled' } });
      const total = orders.reduce((sum, o) => sum + (o.total || 0), 0);
      return { month: month.toISOString().slice(0,7), total };
    }));
    // Top 5 vendors by sales
    const topVendorsAgg = await Order.aggregate([
      { $match: { status: { $ne: 'cancelled' } } },
      { $group: { _id: '$vendorId', total: { $sum: '$total' }, orderCount: { $sum: 1 } } },
      { $sort: { total: -1 } },
      { $limit: 5 }
    ]);
    const topVendors = await Promise.all(topVendorsAgg.map(async v => {
      const vendor = await User.findById(v._id).select('storeName email');
      return { ...v, vendor };
    }));
    // Top 5 products by sales
    const topProductsAgg = await Order.aggregate([
      { $unwind: '$items' },
      { $group: { _id: '$items.product', total: { $sum: { $multiply: ['$items.price', '$items.quantity'] } }, quantity: { $sum: '$items.quantity' } } },
      { $sort: { total: -1 } },
      { $limit: 5 }
    ]);
    const topProducts = await Promise.all(topProductsAgg.map(async p => {
      const product = await Product.findById(p._id).select('name image');
      return { ...p, product };
    }));
    // Order status distribution
    const statusAgg = await Order.aggregate([
      { $group: { _id: '$status', count: { $sum: 1 } } }
    ]);
    // Total sales, total orders, avg order value
    const totalSales = (await Order.aggregate([
      { $match: { status: { $ne: 'cancelled' } } },
      { $group: { _id: null, total: { $sum: '$total' }, count: { $sum: 1 } } }
    ]))[0] || { total: 0, count: 0 };
    const avgOrderValue = totalSales.count ? (totalSales.total / totalSales.count) : 0;
    // Sales by category
    const categoryAgg = await Order.aggregate([
      { $unwind: '$items' },
      { $lookup: { from: 'products', localField: 'items.product', foreignField: '_id', as: 'prod' } },
      { $unwind: '$prod' },
      { $group: { _id: '$prod.category', total: { $sum: { $multiply: ['$items.price', '$items.quantity'] } } } },
      { $sort: { total: -1 } }
    ]);
    // Sales by hour (for heatmap)
    const hourAgg = await Order.aggregate([
      { $match: { status: { $ne: 'cancelled' } } },
      { $project: { hour: { $hour: '$createdAt' }, total: 1 } },
      { $group: { _id: '$hour', total: { $sum: '$total' }, count: { $sum: 1 } } },
      { $sort: { _id: 1 } }
    ]);
    res.json({
      salesByDay,
      salesByMonth,
      topVendors,
      topProducts,
      statusDistribution: statusAgg,
      totalSales: totalSales.total,
      totalOrders: totalSales.count,
      avgOrderValue,
      salesByCategory: categoryAgg,
      salesByHour: hourAgg
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// ==================== RIDER MANAGEMENT ====================

exports.getRiders = async (req, res) => {
  try {
    const {
      page = 1,
      limit = 10,
      status,
      isApproved,
      search,
      sortBy = 'createdAt',
      sortOrder = 'desc'
    } = req.query;

    const skip = (page - 1) * limit;
    let query = {};

    // Filter by status
    if (status) query.status = status;

    // Filter by approval status
    if (isApproved !== undefined) {
      query['verification.isApproved'] = isApproved === 'true';
    }

    // Search functionality
    if (search) {
      query.$or = [
        { 'profile.fullName': { $regex: search, $options: 'i' } },
        { 'profile.email': { $regex: search, $options: 'i' } },
        { 'profile.phone': { $regex: search, $options: 'i' } },
        { 'vehicle.licensePlate': { $regex: search, $options: 'i' } },
        { 'documents.drivingLicense.number': { $regex: search, $options: 'i' } }
      ];
    }

    // Build sort object
    const sort = {};
    sort[sortBy] = sortOrder === 'desc' ? -1 : 1;

    const riders = await Rider.find(query)
      .populate('userId', 'name email phone')
      .skip(skip)
      .limit(parseInt(limit))
      .sort(sort);

    const total = await Rider.countDocuments(query);

    return res.json({
      riders,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    logger.error('Error getting riders:', error);
    return res.status(500).json({ message: 'Failed to get riders' });
  }
};

exports.getRiderById = async (req, res) => {
  try {
    const { riderId } = req.params;

    const rider = await Rider.findById(riderId)
      .populate('userId', 'name email phone')
      .populate('currentAssignment.orderId');

    if (!rider) {
      return res.status(404).json({ message: 'Rider not found' });
    }

    return res.json({ rider });
  } catch (error) {
    logger.error('Error getting rider by ID:', error);
    return res.status(500).json({ message: 'Failed to get rider' });
  }
};

exports.createRider = async (req, res) => {
  try {
    logger.info('Attempting to create rider with data:', req.body);

    const {
      name,
      email,
      phone,
      password,
      profile,
      vehicle,
      documents,
      workPreferences,
      bankDetails // Optional
    } = req.body;

    // --- 1. Basic Validation (Already good) ---
    if (!name || !email || !phone || !password) {
      logger.warn('Missing basic required fields for rider creation:', { name: !!name, email: !!email, phone: !!phone, password: !!password });
      return errorResponse(res, 'Name, email, phone, and password are required', 400);
    }

    // --- 2. More Detailed Validation for Nested Objects ---
    // Profile validation
    if (!profile || !profile.fullName || typeof profile.fullName !== 'string' || profile.fullName.trim() === '') {
      return errorResponse(res, 'Profile full name is required and must be a non-empty string', 400);
    }
    // Add more profile validation as per your schema if needed (e.g., gender, emergencyContact)

    // Vehicle validation
    if (!vehicle) {
        return errorResponse(res, 'Vehicle information is required', 400);
    }
    if (!vehicle.type || typeof vehicle.type !== 'string' || vehicle.type.trim() === '') {
        return errorResponse(res, 'Vehicle type is required', 400);
    }
    if (!vehicle.brand || typeof vehicle.brand !== 'string' || vehicle.brand.trim() === '') {
        return errorResponse(res, 'Vehicle brand is required', 400);
    }
    if (!vehicle.model || typeof vehicle.model !== 'string' || vehicle.model.trim() === '') {
        return errorResponse(res, 'Vehicle model is required', 400);
    }
    if (!vehicle.licensePlate || typeof vehicle.licensePlate !== 'string' || vehicle.licensePlate.trim() === '') {
        return errorResponse(res, 'Vehicle license plate is required', 400);
    }

    // Documents validation
    if (!documents || !documents.drivingLicense) {
        return errorResponse(res, 'Driving license document information is required', 400);
    }
    if (!documents.drivingLicense.number || typeof documents.drivingLicense.number !== 'string' || documents.drivingLicense.number.trim() === '') {
        return errorResponse(res, 'Driving license number is required', 400);
    }
    if (!documents.drivingLicense.expiryDate || typeof documents.drivingLicense.expiryDate !== 'string' || documents.drivingLicense.expiryDate.trim() === '') {
        return errorResponse(res, 'Driving license expiry date is required', 400);
    }

    // Driving License Number format validation
    if (!/^DL\d{13}$/.test(documents.drivingLicense.number)) {
        return errorResponse(res, 'Driving License number must be "DL" followed by 13 digits', 400);
    }

    // Driving License Expiry Date validation (must be a valid future date)
    const expiryDate = new Date(documents.drivingLicense.expiryDate);
    // Check if date is valid AND if it's in the future (compared to current time)
    if (isNaN(expiryDate.getTime()) || expiryDate < new Date()) {
        return errorResponse(res, 'Driving License Expiry Date must be a valid future date', 400);
    }

    // Check if user already exists
    const existingUser = await User.findOne({ $or: [{ email }, { phone }] });
    if (existingUser) {
      logger.warn('User already exists with this email or phone:', { email, phone });
      return errorResponse(res, 'User with this email or phone already exists', 400);
    }

    logger.info('Creating user with role rider');

    // Create user first
    const hashedPassword = await bcrypt.hash(password, 10);
    const user = new User({
      name,
      email,
      phone,
      password: hashedPassword,
      role: 'rider',
      isActive: true
    });
    await user.save();

    // Create rider profile
    const rider = new Rider({
      userId: user._id,
      profile: {
        fullName: profile.fullName,
        email: profile.email || email, // Use provided email if available, else from top-level
        phone: profile.phone || phone, // Use provided phone if available, else from top-level
        gender: profile.gender || 'male', // Default if not provided
        emergencyContact: profile.emergencyContact // Ensure this structure matches your schema
      },
      vehicle: {
        type: vehicle.type,
        brand: vehicle.brand,
        model: vehicle.model,
        year: vehicle.year || new Date().getFullYear(),
        color: vehicle.color || 'Unknown', // Default if not provided
        licensePlate: vehicle.licensePlate
      },
      documents: {
        drivingLicense: {
          number: documents.drivingLicense.number,
          expiryDate: documents.drivingLicense.expiryDate
        }
      },
      workPreferences: {
        isAvailable: workPreferences?.isAvailable ?? true, // Use nullish coalescing for boolean
        workingHours: workPreferences?.workingHours,
        preferredAreas: workPreferences?.preferredAreas,
        maxDistance: workPreferences?.maxDistance
      },
      bankDetails, // This can be optional, ensure schema handles it
      verification: {
        isVerified: true, // Assuming creation via admin panel implies immediate verification
        isApproved: true, // Assuming admin creation implies immediate approval
        submittedAt: new Date(),
        approvedAt: new Date(),
        approvedBy: req.user.id // This assumes `req.user.id` is populated by your auth middleware
      },
      status: 'offline' // New riders typically start as offline
    });

    await rider.save();
    logger.info('Rider created successfully:', rider._id);

    const riderWithUser = await Rider.findById(rider._id)
      .populate('userId', 'name email phone');

    return successResponse(res, { rider: riderWithUser }, 'Rider created successfully', 201);
  } catch (error) {
    logger.error('Error creating rider:', error);
    // Handle specific Mongoose validation errors
    if (error.name === 'ValidationError') {
        const messages = Object.values(error.errors).map(val => val.message);
        return errorResponse(res, messages.join(', '), 400);
    }
    // Handle duplicate key error (e.g., if vehicle.licensePlate or phone/email has a unique index)
    if (error.code === 11000) {
        const field = Object.keys(error.keyValue)[0];
        const value = Object.values(error.keyValue)[0];
        return errorResponse(res, `A rider with this ${field}: '${value}' already exists.`, 409);
    }
    return errorResponse(res, 'Failed to create rider due to an unexpected server error.', 500);
  }
};

exports.updateRider = async (req, res) => {
  try {
    const { riderId } = req.params;
    const updateData = req.body;

    // Remove fields that shouldn't be updated directly
    delete updateData.verification;
    delete updateData.earnings;
    delete updateData.performance;
    delete updateData.currentAssignment;

    const rider = await Rider.findByIdAndUpdate(
      riderId,
      { $set: updateData },
      { new: true, runValidators: true }
    ).populate('userId', 'name email phone');

    if (!rider) {
      return res.status(404).json({ message: 'Rider not found' });
    }

    return res.json({
      rider,
      message: 'Rider updated successfully'
    });
  } catch (error) {
    logger.error('Error updating rider:', error);
    return res.status(500).json({ message: 'Failed to update rider' });
  }
};

exports.approveRider = async (req, res) => {
  try {
    const { riderId } = req.params;
    const { isApproved, rejectionReason } = req.body;

    const rider = await Rider.findById(riderId);
    if (!rider) {
      return errorResponse(res, 'Rider not found', 404);
    }

    rider.verification.isApproved = isApproved;
    rider.verification.approvedAt = new Date();
    rider.verification.approvedBy = req.user.id;

    if (!isApproved && rejectionReason) {
      rider.verification.rejectionReason = rejectionReason;
    }

    await rider.save();

    return res.json({
      rider,
      message: `Rider ${isApproved ? 'approved' : 'rejected'} successfully`
    });
  } catch (error) {
    logger.error('Error approving rider:', error);
    return res.status(500).json({ message: 'Failed to approve rider' });
  }
};

exports.blockRider = async (req, res) => {
  try {
    const { riderId } = req.params;
    const { isBlocked, reason } = req.body;

    const rider = await Rider.findById(riderId);
    if (!rider) {
      return errorResponse(res, 'Rider not found', 404);
    }

    // Update rider status
    rider.status = isBlocked ? 'offline' : 'online';
    rider.workPreferences.isAvailable = !isBlocked;

    // Update user status
    await User.findByIdAndUpdate(rider.userId, {
      isActive: !isBlocked
    });

    await rider.save();

    return res.json({
      rider,
      message: `Rider ${isBlocked ? 'blocked' : 'unblocked'} successfully`
    });
  } catch (error) {
    logger.error('Error blocking rider:', error);
    return res.status(500).json({ message: 'Failed to block rider' });
  }
};

exports.deleteRider = async (req, res) => {
  try {
    const { riderId } = req.params;

    const rider = await Rider.findById(riderId);
    if (!rider) {
      return errorResponse(res, 'Rider not found', 404);
    }

    // Check if rider has active orders
    const activeOrders = await Order.find({
      riderId: rider._id,
      status: { $in: ['picked_up', 'on_the_way'] }
    });

    if (activeOrders.length > 0) {
      return errorResponse(res, 'Cannot delete rider with active orders', 400);
    }

    // Delete rider and associated user
    await Promise.all([
      Rider.findByIdAndDelete(riderId),
      User.findByIdAndDelete(rider.userId)
    ]);

    return res.json({
      message: 'Rider deleted successfully'
    });
  } catch (error) {
    logger.error('Error deleting rider:', error);
    return res.status(500).json({ message: 'Failed to delete rider' });
  }
};

exports.getRiderAnalytics = async (req, res) => {
  try {
    const { period = 'month' } = req.query;

    let startDate;
    switch (period) {
      case 'week':
        startDate = new Date();
        startDate.setDate(startDate.getDate() - 7);
        break;
      case 'month':
        startDate = new Date();
        startDate.setMonth(startDate.getMonth() - 1);
        break;
      case 'year':
        startDate = new Date();
        startDate.setFullYear(startDate.getFullYear() - 1);
        break;
      default:
        startDate = new Date();
        startDate.setMonth(startDate.getMonth() - 1);
    }

    // Get rider statistics
    const totalRiders = await Rider.countDocuments();
    const approvedRiders = await Rider.countDocuments({ 'verification.isApproved': true });
    const onlineRiders = await Rider.countDocuments({ status: 'online' });
    const newRiders = await Rider.countDocuments({ createdAt: { $gte: startDate } });

    // Get performance statistics
    const performanceStats = await Rider.aggregate([
      {
        $group: {
          _id: null,
          avgRating: { $avg: '$performance.averageRating' },
          avgCompletionRate: {
            $avg: {
              $cond: [
                { $gt: ['$performance.totalDeliveries', 0] },
                { $divide: ['$performance.completedDeliveries', '$performance.totalDeliveries'] },
                0
              ]
            }
          },
          totalEarnings: { $sum: '$earnings.totalEarnings' },
          totalDeliveries: { $sum: '$performance.totalDeliveries' }
        }
      }
    ]);

    // Get status distribution
    const statusDistribution = await Rider.aggregate([
      {
        $group: {
          _id: '$status',
          count: { $sum: 1 }
        }
      }
    ]);

    // Get vehicle type distribution
    const vehicleDistribution = await Rider.aggregate([
      {
        $group: {
          _id: '$vehicle.type',
          count: { $sum: 1 }
        }
      }
    ]);

    // Get top performing riders
    const topRiders = await Rider.find()
      .populate('userId', 'name email')
      .sort({ 'performance.averageRating': -1, 'performance.completedDeliveries': -1 })
      .limit(5);

    const analytics = {
      period,
      overview: {
        totalRiders,
        approvedRiders,
        onlineRiders,
        newRiders,
        approvalRate: totalRiders > 0 ? (approvedRiders / totalRiders * 100).toFixed(1) : 0
      },
      performance: performanceStats[0] || {
        avgRating: 0,
        avgCompletionRate: 0,
        totalEarnings: 0,
        totalDeliveries: 0
      },
      statusDistribution,
      vehicleDistribution,
      topRiders
    };

    return successResponse(res, { analytics });
  } catch (error) {
    logger.error('Error getting rider analytics:', error);
    return errorResponse(res, 'Failed to get rider analytics', 500);
  }
};

exports.getRiderPerformance = async (req, res) => {
  try {
    const { riderId } = req.params;
    const { period = 'month' } = req.query;

    const rider = await Rider.findById(riderId);
    if (!rider) {
      return res.status(404).json({ message: 'Rider not found' });
    }

    // Calculate performance metrics
    const performance = {
      totalOrders: rider.performance.totalDeliveries,
      totalEarnings: rider.earnings.totalEarnings,
      avgOrderValue: rider.performance.totalDeliveries > 0 
        ? rider.earnings.totalEarnings / rider.performance.totalDeliveries 
        : 0,
      completionRate: rider.performance.totalDeliveries > 0 
        ? (rider.performance.completedDeliveries / rider.performance.totalDeliveries * 100).toFixed(1)
        : 0,
      averageRating: rider.performance.averageRating.toFixed(1),
      onTimeRate: rider.performance.completedDeliveries > 0
        ? (rider.performance.onTimeDeliveries / rider.performance.completedDeliveries * 100).toFixed(1)
        : 0,
      dailyStats: []
    };

    // Calculate period-specific earnings
    let startDate;
    switch (period) {
      case 'week':
        startDate = new Date();
        startDate.setDate(startDate.getDate() - 7);
        performance.weeklyEarnings = rider.earnings.thisWeek;
        break;
      case 'month':
        startDate = new Date();
        startDate.setMonth(startDate.getMonth() - 1);
        performance.monthlyEarnings = rider.earnings.thisMonth;
        break;
      default:
        startDate = new Date();
        startDate.setMonth(startDate.getMonth() - 1);
        performance.monthlyEarnings = rider.earnings.thisMonth;
    }

    // Generate daily stats for the last 7 days
    const dailyStats = [];
    for (let i = 6; i >= 0; i--) {
      const date = new Date();
      date.setDate(date.getDate() - i);
      date.setHours(0, 0, 0, 0);
      
      dailyStats.push({
        date: date.toLocaleDateString(),
        orders: Math.floor(Math.random() * 10) + 1, // Mock data
        earnings: Math.floor(Math.random() * 500) + 100 // Mock data
      });
    }
    performance.dailyStats = dailyStats;

    return res.json({ performance });
  } catch (error) {
    logger.error('Error getting rider performance:', error);
    return res.status(500).json({ message: 'Failed to get rider performance' });
  }
}; 