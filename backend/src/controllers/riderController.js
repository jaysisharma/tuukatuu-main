const Rider = require('../models/Rider');
const User = require('../models/User');
const Order = require('../models/Order');
const logger = require('../utils/logger');

// Utility functions following DRY principle
const handleAsyncError = (fn) => async (req, res) => {
  try {
    await fn(req, res);
  } catch (error) {
    logger.error(`Error in ${fn.name}:`, error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};

const validateRiderExists = async (userId) => {
  const rider = await Rider.findOne({ userId }).populate('userId', 'name email phone');
  if (!rider) {
    throw new Error('Rider profile not found');
  }
  return rider;
};

const validateOrderExists = async (orderId) => {
  const order = await Order.findById(orderId);
  if (!order) {
    throw new Error('Order not found');
  }
  return order;
};

// Helper functions following DRY principle
const getDateRange = (period) => {
  const now = new Date();
  let startDate, endDate;

  switch (period) {
    case 'today':
      startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
      endDate = new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1);
      break;
    case 'week':
      const dayOfWeek = now.getDay();
      startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate() - dayOfWeek);
      endDate = new Date(startDate.getTime() + 7 * 24 * 60 * 60 * 1000);
      break;
    case 'month':
      startDate = new Date(now.getFullYear(), now.getMonth(), 1);
      endDate = new Date(now.getFullYear(), now.getMonth() + 1, 1);
      break;
    case 'all':
      startDate = new Date(0);
      endDate = now;
      break;
    default:
      throw new Error('Invalid period');
  }

  return { startDate, endDate };
};

const generateDailyStats = (orders, startDate, endDate) => {
  const dailyStats = [];
  const currentDate = new Date(startDate);
  
  while (currentDate < endDate) {
    const dayStart = new Date(currentDate);
    const dayEnd = new Date(currentDate.getTime() + 24 * 60 * 60 * 1000);
    
    const dayOrders = orders.filter(order => 
      order.deliveredAt >= dayStart && order.deliveredAt < dayEnd
    );
    
    const dayEarnings = dayOrders.reduce((sum, order) => sum + (order.deliveryFee || 50), 0);
    
    dailyStats.push({
      date: currentDate.toLocaleDateString(),
      orders: dayOrders.length,
      earnings: dayEarnings
    });
    
    currentDate.setDate(currentDate.getDate() + 1);
  }

  return dailyStats;
};

const generateMockPayments = () => {
  const now = new Date();
  return [
    {
      method: 'Bank Transfer',
      amount: 2500,
      date: new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000),
      status: 'completed'
    },
    {
      method: 'UPI',
      amount: 1800,
      date: new Date(now.getTime() - 14 * 24 * 60 * 60 * 1000),
      status: 'completed'
    }
  ];
};

const getTargetForPeriod = (period) => {
  const targets = {
    month: 10000,
    week: 2500,
    today: 500,
    all: 50000
  };
  return targets[period] || 1000;
};

// Get rider profile
const getProfile = async (req, res) => {
  const rider = await validateRiderExists(req.user.id);
  return res.json({ rider });
};

exports.getProfile = handleAsyncError(getProfile);

// Update rider profile
const updateProfile = async (req, res) => {
  const { profile, vehicle, workPreferences, settings } = req.body;
  const rider = await validateRiderExists(req.user.id);

  // Update fields following DRY principle
  const updateFields = { profile, vehicle, workPreferences, settings };
  Object.keys(updateFields).forEach(key => {
    if (updateFields[key]) {
      rider[key] = { ...rider[key], ...updateFields[key] };
    }
  });

  await rider.save();
  const updatedRider = await Rider.findById(rider._id).populate('userId', 'name email phone');

  return res.json({ 
    rider: updatedRider,
    message: 'Profile updated successfully' 
  });
};

exports.updateProfile = handleAsyncError(updateProfile);

// Update rider status
const updateStatus = async (req, res) => {
  const { status } = req.body;
  const validStatuses = ['online', 'offline', 'busy', 'on_delivery'];

  if (!validStatuses.includes(status)) {
    return res.status(400).json({ message: 'Invalid status' });
  }

  const rider = await validateRiderExists(req.user.id);
  rider.status = status;
  await rider.save();

  return res.json({ 
    message: 'Status updated successfully',
    status: rider.status 
  });
};

exports.updateStatus = handleAsyncError(updateStatus);

// Get available orders
const getAvailableOrders = async (req, res) => {
  await validateRiderExists(req.user.id);

  const availableOrders = await Order.find({
    status: 'ready_for_pickup',
    riderId: null,
  })
  .populate('vendorId', 'storeName')
  .populate('customerId', 'name')
  .limit(20);

  return res.json({ orders: availableOrders });
};

exports.getAvailableOrders = handleAsyncError(getAvailableOrders);

// Get rider's orders
const getOrders = async (req, res) => {
  const rider = await validateRiderExists(req.user.id);

  const orders = await Order.find({ riderId: rider._id })
    .populate('vendorId', 'storeName')
    .populate('customerId', 'name')
    .sort({ createdAt: -1 });

  return res.json({ orders });
};

exports.getOrders = handleAsyncError(getOrders);

// Accept an order
const acceptOrder = async (req, res) => {
  const { orderId } = req.body;
  const rider = await validateRiderExists(req.user.id);

  if (rider.status !== 'online') {
    return res.status(400).json({ message: 'You must be online to accept orders' });
  }

  const order = await validateOrderExists(orderId);

  if (order.status !== 'ready_for_pickup') {
    return res.status(400).json({ message: 'Order is not available for pickup' });
  }

  if (order.riderId) {
    return res.status(400).json({ message: 'Order has already been assigned to another rider' });
  }

  // Assign order to rider
  order.riderId = rider._id;
  order.status = 'picked_up';
  order.assignedAt = new Date();
  await order.save();

  // Update rider status and current assignment
  rider.status = 'busy';
  rider.currentAssignment = {
    orderId: order._id,
    pickupLocation: order.pickupLocation,
    deliveryLocation: order.deliveryLocation
  };
  await rider.save();

  return res.json({ 
    message: 'Order accepted successfully',
    order 
  });
};

exports.acceptOrder = handleAsyncError(acceptOrder);

// Update order status
const updateOrderStatus = async (req, res) => {
  const { orderId, status } = req.body;
  const rider = await validateRiderExists(req.user.id);
  const order = await validateOrderExists(orderId);

  if (order.riderId.toString() !== rider._id.toString()) {
    return res.status(403).json({ message: 'You are not assigned to this order' });
  }

  // Validate status transition
  const validTransitions = {
    'picked_up': ['on_the_way'],
    'on_the_way': ['delivered', 'cancelled'],
    'delivered': [],
    'cancelled': []
  };

  if (!validTransitions[order.status].includes(status)) {
    return res.status(400).json({ message: `Invalid status transition from ${order.status} to ${status}` });
  }

  order.status = status;
  
  if (status === 'delivered') {
    order.deliveredAt = new Date();
    order.deliveryTime = order.deliveredAt - order.assignedAt;
    
    // Update rider performance
    rider.performance.completedDeliveries += 1;
    rider.performance.totalDeliveries += 1;
    
    // Calculate earnings (basic calculation)
    const deliveryFee = order.deliveryFee || 50;
    rider.earnings.totalEarnings += deliveryFee;
    rider.earnings.thisWeek += deliveryFee;
    rider.earnings.thisMonth += deliveryFee;
    
    // Clear current assignment
    rider.currentAssignment = null;
    rider.status = 'online';
  } else if (status === 'cancelled') {
    order.cancelledAt = new Date();
    rider.performance.totalDeliveries += 1;
    rider.currentAssignment = null;
    rider.status = 'online';
  }

  await order.save();
  await rider.save();

  return res.json({ 
    message: 'Order status updated successfully',
    order 
  });
};

exports.updateOrderStatus = handleAsyncError(updateOrderStatus);

// Get rider earnings
const getEarnings = async (req, res) => {
  const { period = 'month' } = req.query;
  const rider = await validateRiderExists(req.user.id);

  const { startDate, endDate } = getDateRange(period);
  const orders = await Order.find({
    riderId: rider._id,
    status: 'delivered',
    deliveredAt: { $gte: startDate, $lt: endDate }
  });

  const totalEarnings = orders.reduce((sum, order) => sum + (order.deliveryFee || 50), 0);
  const totalOrders = orders.length;
  const dailyStats = generateDailyStats(orders, startDate, endDate);
  const payments = generateMockPayments();

  const earnings = {
    total: totalEarnings,
    orders: totalOrders,
    target: getTargetForPeriod(period),
    dailyStats,
    payments,
    pendingAmount: totalEarnings > 1000 ? totalEarnings % 1000 : 0
  };

  return res.json({ earnings });
};

exports.getEarnings = handleAsyncError(getEarnings);

// Get rider performance
exports.getPerformance = async (req, res) => {
  try {
    const rider = await Rider.findOne({ userId: req.user.id });
    if (!rider) {
      return errorResponse(res, 'Rider profile not found', 404);
    }

    const performance = {
      totalDeliveries: rider.performance.totalDeliveries,
      completedDeliveries: rider.performance.completedDeliveries,
      onTimeDeliveries: rider.performance.onTimeDeliveries,
      averageRating: rider.performance.averageRating,
      completionRate: rider.performance.totalDeliveries > 0 
        ? (rider.performance.completedDeliveries / rider.performance.totalDeliveries * 100).toFixed(1)
        : 0,
      onTimeRate: rider.performance.completedDeliveries > 0
        ? (rider.performance.onTimeDeliveries / rider.performance.completedDeliveries * 100).toFixed(1)
        : 0
    };

    return res.json({ performance });
  } catch (error) {
    logger.error('Error getting rider performance:', error);
    return errorResponse(res, 'Failed to get performance', 500);
  }
};

// Change password
exports.changePassword = async (req, res) => {
  try {
    const { currentPassword, newPassword } = req.body;

    const user = await User.findById(req.user.id);
    if (!user) {
      return errorResponse(res, 'User not found', 404);
    }

    // Verify current password
    const isPasswordValid = await user.comparePassword(currentPassword);
    if (!isPasswordValid) {
      return errorResponse(res, 'Current password is incorrect', 400);
    }

    // Update password
    user.password = newPassword;
    await user.save();

    return res.json({ message: 'Password changed successfully' });
  } catch (error) {
    logger.error('Error changing password:', error);
    return errorResponse(res, 'Failed to change password', 500);
  }
}; 