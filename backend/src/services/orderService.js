const Order = require('../models/Order');
const Product = require('../models/Product');
const Rider = require('../models/Rider');
const User = require('../models/User');
const { calculateDistance, validateCoordinates } = require('../utils/locationUtils');

exports.placeOrder = async (user, orderData) => {
  const { items, customerLocation, deliveryAddress, ...rest } = orderData;
  
  // Validate customer location
  if (!customerLocation || !validateCoordinates(customerLocation.latitude, customerLocation.longitude)) {
    throw new Error('Valid customer location is required');
  }

  // Populate items with product details and validate inventory
  const populatedItems = await Promise.all(items.map(async (item) => {
    const product = await Product.findById(item.product);
    if (!product) throw new Error(`Product not found: ${item.product}`);
    if (!product.isAvailable) throw new Error(`Product is not available: ${product.name}`);
    if (product.stock < item.quantity) throw new Error(`Insufficient stock for ${product.name}`);
    
    return {
      product: product._id,
      quantity: item.quantity,
      price: product.price,
      name: product.name,
      image: product.imageUrl || product.image,
      specialInstructions: item.specialInstructions || '',
      unit: product.unit,
      category: product.category,
    };
  }));

  // Calculate totals
  const itemTotal = populatedItems.reduce((sum, item) => sum + (item.price * item.quantity), 0);
  const tax = itemTotal * 0.13; // 13% tax
  const deliveryFee = await calculateDeliveryFee(customerLocation);
  const tip = orderData.tip || 0;
  const total = itemTotal + tax + deliveryFee + tip;

  // Create order with comprehensive data
  const order = new Order({ 
    customerId: user.id,
    vendorId: orderData.vendorId,
    vendorType: orderData.orderType === 'tmart' ? 'tmart' : 'regular',
    items: populatedItems,
    itemTotal,
    tax,
    deliveryFee,
    tip,
    total,
    paymentMethod: orderData.paymentMethod || 'cash',
    customerLocation: {
      latitude: customerLocation.latitude,
      longitude: customerLocation.longitude,
      address: deliveryAddress || customerLocation.address,
      landmark: customerLocation.landmark
    },
    specialInstructions: orderData.instructions || '',
    estimatedDeliveryTime: calculateEstimatedDeliveryTime(orderData.orderType),
    priority: determineOrderPriority(orderData),
    orderType: orderData.orderType || 'regular',
    status: 'pending'
  });
  
  // Initialize status history
  order.statusHistory = [{ 
    status: order.status, 
    updatedBy: user.id, 
    timestamp: new Date(),
    note: 'Order placed successfully',
    location: {
      latitude: customerLocation.latitude,
      longitude: customerLocation.longitude
    }
  }];
  
  await order.save();
  console.log(order);
  
  // Update product inventory
  for (const item of populatedItems) {
    await Product.findByIdAndUpdate(item.product, {
      $inc: { stock: -item.quantity }
    });
  }
  
  // Trigger rider assignment
  // await assignRiderToOrder(order._id);
  
  return order;
};

exports.getOrders = async (user) => {
  let orders;
  const populateOptions = [
    { path: 'customerId', select: 'name phone email' },
    { path: 'vendorId', select: 'storeName phone' },
    { path: 'riderId', select: 'profile.fullName profile.phone vehicle.licensePlate performance.averageRating' }
  ];
  
  if (user.role === 'admin') {
    orders = await Order.find()
      .populate(populateOptions)
      .sort({ createdAt: -1 });
  } else if (user.role === 'vendor') {
    orders = await Order.find({ vendorId: user.id })
      .populate(populateOptions)
      .sort({ createdAt: -1 });
  } else if (user.role === 'rider') {
    orders = await Order.find({ riderId: user.id })
      .populate(populateOptions)
      .sort({ createdAt: -1 });
  } else {
    orders = await Order.find({ customerId: user.id })
      .populate(populateOptions)
      .sort({ createdAt: -1 });
  }
  
  return orders;
};

exports.getVendorOrders = async (vendorId, filters = {}) => {
  const query = { vendorId };
  
  // Apply filters
  if (filters.status) query.status = filters.status;
  if (filters.dateFrom) query.createdAt = { $gte: new Date(filters.dateFrom) };
  if (filters.dateTo) query.createdAt = { ...query.createdAt, $lte: new Date(filters.dateTo) };
  
  return await Order.find(query)
    .populate('customerId', 'name phone')
    .populate('riderId', 'profile.fullName profile.phone')
    .sort({ createdAt: -1 });
};

exports.getCustomerOrders = async (customerId, filters = {}) => {
  const query = { customerId };
  
  // Apply filters
  if (filters.status) query.status = filters.status;
  if (filters.dateFrom) query.createdAt = { $gte: new Date(filters.dateFrom) };
  if (filters.dateTo) query.createdAt = { ...query.createdAt, $lte: new Date(filters.dateTo) };
  
  return await Order.find(query)
    .populate('vendorId', 'storeName')
    .populate('riderId', 'profile.fullName profile.phone vehicle.licensePlate')
    .sort({ createdAt: -1 });
};

exports.getOrderDetails = async (user, orderId) => {
  let order;
  const populateOptions = [
    { path: 'customerId', select: 'name phone email' },
    { path: 'vendorId', select: 'storeName phone' },
    { path: 'riderId', select: 'profile.fullName profile.phone vehicle.licensePlate performance.averageRating' }
  ];
  
  if (user.role === 'admin') {
    order = await Order.findById(orderId).populate(populateOptions);
  } else if (user.role === 'vendor') {
    order = await Order.findOne({ _id: orderId, vendorId: user.id }).populate(populateOptions);
  } else if (user.role === 'rider') {
    order = await Order.findOne({ _id: orderId, riderId: user.id }).populate(populateOptions);
  } else {
    order = await Order.findOne({ _id: orderId, customerId: user.id }).populate(populateOptions);
  }
  
  if (!order) throw new Error('Order not found or not authorized');
  
  // Calculate ETA if rider is assigned
  if (order.riderId && order.riderLocation) {
    order.estimatedDeliveryTime = order.calculateETA();
  }
  
  return order;
};

exports.updateOrderStatus = async (user, orderId, status, note = '') => {
  let order;
  let query;
  
  if (user.role === 'vendor') {
    query = { _id: orderId, vendorId: user.id };
  } else if (user.role === 'rider') {
    query = { _id: orderId, riderId: user.id };
  } else if (user.role === 'admin') {
    query = { _id: orderId };
  } else {
    throw new Error('Not authorized');
  }
  
  order = await Order.findOne(query);
  if (!order) throw new Error('Order not found or not authorized');
  
  // Validate status transition
  if (!isValidStatusTransition(order.status, status, user.role)) {
    throw new Error(`Invalid status transition from ${order.status} to ${status}`);
  }
  
  // Update order status
  order.status = status;
  
  // Add to status history
  order.statusHistory.push({ 
    status, 
    updatedBy: user.id, 
    timestamp: new Date(),
    note,
    location: user.role === 'rider' ? user.currentLocation : undefined
  });
  
  // Handle specific status updates
  if (status === 'delivered') {
    order.actualDeliveryTime = new Date();
    order.riderEarnings = calculateRiderEarnings(order);
  } else if (status === 'picked_up') {
    order.actualPickupTime = new Date();
  } else if (status === 'rejected') {
    order.rejectionReason = note;
  } else if (status === 'cancelled') {
    order.cancellationReason = note;
  }
  
  await order.save();
  
  // Send notifications
  await sendOrderStatusNotification(order, status);
  
  return order;
};

exports.assignRiderToOrder = async (orderId, riderId = null) => {
  const order = await Order.findById(orderId);
  if (!order) throw new Error('Order not found');
  
  if (riderId) {
    // Manual assignment
    const rider = await Rider.findById(riderId);
    if (!rider || rider.status !== 'available') {
      throw new Error('Rider not available');
    }
    
    order.riderId = riderId;
    order.riderAssignment.assignedAt = new Date();
    order.riderAssignment.autoAssigned = false;
  } else {
    // Auto-assignment based on proximity and availability
    const nearbyRiders = await findNearbyAvailableRiders(
      order.customerLocation.latitude,
      order.customerLocation.longitude
    );
    
    if (nearbyRiders.length === 0) {
      throw new Error('No riders available in the area');
    }
    
    // Select best rider based on rating, distance, and current load
    const bestRider = selectBestRider(nearbyRiders, order);
    order.riderId = bestRider._id;
    order.riderAssignment.assignedAt = new Date();
    order.riderAssignment.autoAssigned = true;
  }
  
  await order.save();
  
  // Send notification to rider
  await sendRiderAssignmentNotification(order);
  
  return order;
};

exports.acceptOrder = async (riderId, orderId) => {
  const order = await Order.findOne({ _id: orderId, riderId });
  if (!order) throw new Error('Order not found or not assigned to you');
  
  if (order.status !== 'pending' && order.status !== 'accepted') {
    throw new Error('Order cannot be accepted in current status');
  }
  
  order.status = 'accepted';
  order.riderAssignment.acceptedAt = new Date();
  
  order.statusHistory.push({
    status: 'accepted',
    updatedBy: riderId,
    timestamp: new Date(),
    note: 'Order accepted by rider'
  });
  
  await order.save();
  
      // Update rider status
    await Rider.findByIdAndUpdate(riderId, { 
      status: 'busy',
      'currentAssignment.orderId': orderId,
      'currentAssignment.assignedAt': new Date()
    });
  
  // Send notifications
  await sendOrderStatusNotification(order, 'accepted');
  
  return order;
};

exports.rejectOrder = async (riderId, orderId, reason) => {
  const order = await Order.findOne({ _id: orderId, riderId });
  if (!order) throw new Error('Order not found or not assigned to you');
  
  order.riderId = null;
  order.riderAssignment.rejectedAt = new Date();
  order.riderAssignment.rejectionReason = reason;
  
  order.statusHistory.push({
    status: 'pending',
    updatedBy: riderId,
    timestamp: new Date(),
    note: `Order rejected: ${reason}`
  });
  
  await order.save();
  
  // Try to assign to another rider
  await assignRiderToOrder(orderId);
  
  return order;
};

exports.updateRiderLocation = async (riderId, latitude, longitude) => {
  const order = await Order.findOne({ 
    riderId, 
    status: { $in: ['accepted', 'preparing', 'ready_for_pickup', 'picked_up', 'on_the_way'] }
  });
  
  if (order) {
    order.riderLocation = {
      latitude,
      longitude,
      updatedAt: new Date()
    };
    
    // Update ETA
    order.estimatedDeliveryTime = order.calculateETA();
    
    await order.save();
    
    // Send location update notification to customer
    await sendLocationUpdateNotification(order);
  }
  
  // Update rider's current location
  await Rider.findByIdAndUpdate(riderId, {
    'currentLocation.coordinates': [longitude, latitude],
    'currentLocation.lastUpdated': new Date()
  });
  
  return { success: true };
};

exports.cancelOrder = async (userId, orderId, reason, userRole) => {
  const order = await Order.findById(orderId);
  if (!order) throw new Error('Order not found');
  
  // Check if user can cancel this order
  if (userRole === 'customer' && order.customerId.toString() !== userId) {
    throw new Error('Not authorized to cancel this order');
  }
  
  if (userRole === 'vendor' && order.vendorId.toString() !== userId) {
    throw new Error('Not authorized to cancel this order');
  }
  
  // Check if order can be cancelled
  if (!canCancelOrder(order.status)) {
    throw new Error('Order cannot be cancelled in current status');
  }
  
  order.status = 'cancelled';
  order.cancellationReason = reason;
  
  order.statusHistory.push({
    status: 'cancelled',
    updatedBy: userId,
    timestamp: new Date(),
    note: `Order cancelled by ${userRole}: ${reason}`
  });
  
  // If rider was assigned, free them up
  if (order.riderId) {
    await Rider.findByIdAndUpdate(order.riderId, {
      status: 'available',
      currentOrderId: null
    });
  }
  
  await order.save();
  
  // Send cancellation notifications
  await sendOrderStatusNotification(order, 'cancelled');
  
  return order;
};

exports.rateOrder = async (customerId, orderId, rating, review) => {
  const order = await Order.findOne({ _id: orderId, customerId });
  if (!order) throw new Error('Order not found or not authorized');
  
  if (order.status !== 'delivered') {
    throw new Error('Can only rate delivered orders');
  }
  
  if (order.customerRating) {
    throw new Error('Order already rated');
  }
  
  order.customerRating = rating;
  order.customerReview = review;
  order.reviewDate = new Date();
  
  await order.save();
  
  // Update rider rating if applicable
  if (order.riderId) {
    await updateRiderRating(order.riderId, rating);
  }
  
  return order;
};

// Helper functions
async function calculateDeliveryFee(customerLocation) {
  // Base delivery fee
  let baseFee = 50;
  
  // Add distance-based fee (simplified calculation)
  // In production, use Google Maps API for accurate distance
  const distance = 5; // km - would be calculated from vendor to customer
  const distanceFee = Math.max(0, (distance - 3) * 10); // 10 per km after 3km
  
  return baseFee + distanceFee;
}

function calculateEstimatedDeliveryTime(orderType = 'regular') {
  // T-Mart orders have faster delivery (15-20 minutes)
  if (orderType === 'tmart') {
    const baseTime = 20; // 20 minutes for T-Mart
    return new Date(Date.now() + baseTime * 60 * 1000);
  }
  
  // Regular orders: 30-45 minutes
  const baseTime = 30;
  return new Date(Date.now() + baseTime * 60 * 1000);
}

function determineOrderPriority(orderData) {
  // T-Mart orders get high priority
  if (orderData.orderType === 'tmart') {
    return 'high';
  }
  
  // Regular orders based on value
  if (orderData.total > 1000) return 'high';
  if (orderData.total > 500) return 'normal';
  return 'low';
}

function isValidStatusTransition(currentStatus, newStatus, userRole) {
  const validTransitions = {
    vendor: {
      pending: ['accepted', 'rejected'],
      accepted: ['preparing'],
      preparing: ['ready_for_pickup'],
      ready_for_pickup: ['handed_over']
    },
    rider: {
      accepted: ['picked_up'],
      picked_up: ['on_the_way'],
      on_the_way: ['delivered']
    }
  };
  
  return validTransitions[userRole]?.[currentStatus]?.includes(newStatus) || false;
}

async function findNearbyAvailableRiders(latitude, longitude, maxDistance = 10) {
  return await Rider.find({
    status: { $in: ['online', 'available'] },
    'workPreferences.isAvailable': true,
    'verification.isApproved': true,
    'currentLocation.coordinates': {
      $near: {
        $geometry: {
          type: 'Point',
          coordinates: [longitude, latitude]
        },
        $maxDistance: maxDistance * 1000 // Convert to meters
      }
    }
  }).sort({ 'performance.averageRating': -1, 'currentLocation.lastUpdated': -1 });
}

function selectBestRider(riders, order) {
  // Score riders based on multiple factors
  return riders.reduce((best, rider) => {
    const score = calculateRiderScore(rider, order);
    return score > best.score ? { rider, score } : best;
  }, { rider: null, score: -1 }).rider;
}

function calculateRiderScore(rider, order) {
  let score = 0;
  
  // Rating factor (0-5)
  score += (rider.performance?.averageRating || 3) * 10;
  
  // Distance factor (closer is better)
  if (rider.currentLocation?.coordinates && order.customerLocation) {
    const distance = calculateDistance(
      rider.currentLocation.coordinates[1], // latitude
      rider.currentLocation.coordinates[0], // longitude
      order.customerLocation.latitude,
      order.customerLocation.longitude
    );
    score += Math.max(0, 50 - distance * 5);
  }
  
  // Activity factor (more recent activity is better)
  const lastUpdated = rider.currentLocation?.lastUpdated || new Date(0);
  const hoursSinceActive = (Date.now() - lastUpdated.getTime()) / (1000 * 60 * 60);
  score += Math.max(0, 20 - hoursSinceActive);
  
  return score;
}

function calculateRiderEarnings(order) {
  // Base delivery fee
  let earnings = 30;
  
  // Distance bonus
  if (order.deliveryDistance > 5) {
    earnings += (order.deliveryDistance - 5) * 5;
  }
  
  // Tip
  earnings += order.tip || 0;
  
  return earnings;
}

function canCancelOrder(status) {
  return ['pending', 'accepted', 'preparing'].includes(status);
}

async function updateRiderRating(riderId, newRating) {
  const rider = await Rider.findById(riderId);
  if (!rider) return;
  
  const totalRatings = rider.totalRatings || 0;
  const currentRating = rider.rating || 0;
  
  rider.rating = ((currentRating * totalRatings) + newRating) / (totalRatings + 1);
  rider.totalRatings = totalRatings + 1;
  
  await rider.save();
}

// Notification functions
async function sendOrderStatusNotification(order, status) {
  try {
    // Log the status change for debugging
    console.log(`📱 Order Status Change: Order ${order._id} -> ${status}`);
    
    // Add notification record to order
    order.notifications.push({
      type: 'status_update',
      sentAt: new Date(),
      sentTo: 'customer',
      message: `Order status changed to ${status}`,
      read: false,
    });
    
    // Save the order with notification record
    await order.save();
    
    // Log success
    console.log(`✅ Status notification recorded for order ${order._id}`);
    
  } catch (error) {
    console.error(`❌ Error sending status notification for order ${order._id}:`, error);
  }
}

async function sendRiderAssignmentNotification(order) {
  try {
    console.log(`🚚 Rider Assignment: Order ${order._id} assigned to rider ${order.riderId}`);
    
    // Add notification record
    order.notifications.push({
      type: 'rider_assigned',
      sentAt: new Date(),
      sentTo: 'customer',
      message: 'A rider has been assigned to your order',
      read: false,
    });
    
    await order.save();
    console.log(`✅ Rider assignment notification recorded for order ${order._id}`);
    
  } catch (error) {
    console.error(`❌ Error sending rider assignment notification for order ${order._id}:`, error);
  }
}

async function sendLocationUpdateNotification(order) {
  try {
    console.log(`📍 Location Update: Order ${order._id} location updated`);
    
    // Add notification record
    order.notifications.push({
      type: 'rider_location',
      sentAt: new Date(),
      sentTo: 'customer',
      message: 'Rider location has been updated',
      read: false,
    });
    
    await order.save();
    console.log(`✅ Location update notification recorded for order ${order._id}`);
    
  } catch (error) {
    console.error(`❌ Error sending location update notification for order ${order._id}:`, error);
  }
}

// The assignRiderToOrder function is already exported above 