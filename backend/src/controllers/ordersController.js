const Order = require('../models/Order');
const Product = require('../models/Product');
const orderService = require('../services/orderService');
const { validateCoordinates } = require('../utils/locationUtils');

exports.placeOrder = async (req, res) => {
  try {
    const { items, itemTotal, tax, deliveryFee, tip, total, customerLocation, ...rest } = req.body;
    
    // Validate customer location
    if (!customerLocation || !validateCoordinates(customerLocation.latitude, customerLocation.longitude)) {
      return res.status(400).json({ message: 'Valid customer location is required' });
    }
    
    const order = await orderService.placeOrder(req.user, {
      items,
      itemTotal,
      tax,
      deliveryFee,
      tip,
      total,
      customerLocation,
      ...rest
    });
    console.log("Helloss", order);
    
    res.status(201).json(order);
  } catch (err) {
    console.log(err);
    res.status(400).json({ message: err.message });
  }
};

exports.getOrders = async (req, res) => {
  try {
    const filters = {
      status: req.query.status,
      dateFrom: req.query.dateFrom,
      dateTo: req.query.dateTo,
      limit: parseInt(req.query.limit) || 50,
      page: parseInt(req.query.page) || 1
    };
    
    let orders;
    if (req.user.role === 'admin') {
      orders = await orderService.getOrders(req.user);
    } else if (req.user.role === 'vendor') {
      orders = await orderService.getVendorOrders(req.user.id, filters);
    } else if (req.user.role === 'rider') {
      orders = await orderService.getOrders(req.user);
    } else {
      orders = await orderService.getCustomerOrders(req.user.id, filters);
    }
    
    // Apply pagination
    const startIndex = (filters.page - 1) * filters.limit;
    const endIndex = startIndex + filters.limit;
    const paginatedOrders = orders.slice(startIndex, endIndex);
    
    res.json({
      orders: paginatedOrders,
      pagination: {
        currentPage: filters.page,
        totalPages: Math.ceil(orders.length / filters.limit),
        totalOrders: orders.length,
        hasNextPage: endIndex < orders.length,
        hasPrevPage: filters.page > 1
      }
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getVendorOrders = async (req, res) => {
  try {
    const filters = {
      status: req.query.status,
      dateFrom: req.query.dateFrom,
      dateTo: req.query.dateTo
    };
    
    const orders = await orderService.getVendorOrders(req.user.id, filters);
    res.json(orders);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getCustomerOrders = async (req, res) => {
  try {
    const filters = {
      status: req.query.status,
      dateFrom: req.query.dateFrom,
      dateTo: req.query.dateTo
    };
    
    const orders = await orderService.getCustomerOrders(req.user.id, filters);
    res.json(orders);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getOrderDetails = async (req, res) => {
  try {
    const order = await orderService.getOrderDetails(req.user, req.params.id);
    res.json(order);
  } catch (err) {
    if (err.message.includes('not found')) {
      res.status(404).json({ message: err.message });
    } else {
      res.status(500).json({ message: err.message });
    }
  }
};

exports.updateOrderStatus = async (req, res) => {
  try {
    const { status, note, rejectionReason } = req.body;
    
    // Validate status transition
    if (!status) {
      return res.status(400).json({ message: 'Status is required' });
    }
    
    const order = await orderService.updateOrderStatus(req.user, req.params.id, status, note || rejectionReason);
    res.json(order);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

// New endpoints for enhanced order management

exports.assignRider = async (req, res) => {
  try {
    const { riderId } = req.body;
    
    if (!req.user.role === 'admin' && !req.user.role === 'vendor') {
      return res.status(403).json({ message: 'Not authorized to assign riders' });
    }
    
    const order = await orderService.assignRiderToOrder(req.params.id, riderId);
    res.json(order);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

exports.acceptOrder = async (req, res) => {
  try {
    if (req.user.role !== 'rider') {
      return res.status(403).json({ message: 'Only riders can accept orders' });
    }
    
    const order = await orderService.acceptOrder(req.user.id, req.params.id);
    res.json(order);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

exports.rejectOrder = async (req, res) => {
  try {
    const { reason } = req.body;
    
    if (req.user.role !== 'rider') {
      return res.status(403).json({ message: 'Only riders can reject orders' });
    }
    
    if (!reason || reason.trim().length < 3) {
      return res.status(400).json({ message: 'Rejection reason is required (minimum 3 characters)' });
    }
    
    const order = await orderService.rejectOrder(req.user.id, req.params.id, reason);
    res.json(order);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

exports.updateRiderLocation = async (req, res) => {
  try {
    const { latitude, longitude } = req.body;
    
    if (req.user.role !== 'rider') {
      return res.status(403).json({ message: 'Only riders can update location' });
    }
    
    if (!validateCoordinates(latitude, longitude)) {
      return res.status(400).json({ message: 'Valid coordinates are required' });
    }
    
    const result = await orderService.updateRiderLocation(req.user.id, latitude, longitude);
    res.json(result);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

exports.cancelOrder = async (req, res) => {
  try {
    const { reason } = req.body;
    
    if (!reason || reason.trim().length < 3) {
      return res.status(400).json({ message: 'Cancellation reason is required (minimum 3 characters)' });
    }
    
    const order = await orderService.cancelOrder(req.user.id, req.params.id, reason, req.user.role);
    res.json(order);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

exports.rateOrder = async (req, res) => {
  try {
    const { rating, review } = req.body;
    
    if (req.user.role !== 'customer') {
      return res.status(403).json({ message: 'Only customers can rate orders' });
    }
    
    if (!rating || rating < 1 || rating > 5) {
      return res.status(400).json({ message: 'Valid rating (1-5) is required' });
    }
    
    const order = await orderService.rateOrder(req.user.id, req.params.id, rating, review);
    res.json(order);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

exports.getOrderAnalytics = async (req, res) => {
  try {
    if (req.user.role !== 'admin' && req.user.role !== 'vendor') {
      return res.status(403).json({ message: 'Not authorized' });
    }
    
    const { startDate, endDate } = req.query;
    const query = {};
    
    if (req.user.role === 'vendor') {
      query.vendorId = req.user.id;
    }
    
    if (startDate && endDate) {
      query.createdAt = {
        $gte: new Date(startDate),
        $lte: new Date(endDate)
      };
    }
    
    const orders = await Order.find(query);
    
    // Calculate analytics
    const analytics = {
      totalOrders: orders.length,
      totalRevenue: orders.reduce((sum, order) => sum + order.total, 0),
      averageOrderValue: orders.length > 0 ? orders.reduce((sum, order) => sum + order.total, 0) / orders.length : 0,
      statusBreakdown: {},
      deliveryTimes: [],
      topProducts: {}
    };
    
    // Status breakdown
    orders.forEach(order => {
      analytics.statusBreakdown[order.status] = (analytics.statusBreakdown[order.status] || 0) + 1;
    });
    
    // Delivery times for completed orders
    const deliveredOrders = orders.filter(order => order.status === 'delivered' && order.actualDeliveryTime);
    analytics.deliveryTimes = deliveredOrders.map(order => {
      const deliveryTime = order.actualDeliveryTime - order.createdAt;
      return Math.round(deliveryTime / (1000 * 60)); // Convert to minutes
    });
    
    // Top products
    orders.forEach(order => {
      order.items.forEach(item => {
        const productName = item.name || 'Unknown Product';
        analytics.topProducts[productName] = (analytics.topProducts[productName] || 0) + item.quantity;
      });
    });
    
    res.json(analytics);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getNearbyOrders = async (req, res) => {
  try {
    if (req.user.role !== 'rider') {
      return res.status(403).json({ message: 'Only riders can access nearby orders' });
    }
    
    const { latitude, longitude, maxDistance = 10 } = req.query;
    
    if (!validateCoordinates(parseFloat(latitude), parseFloat(longitude))) {
      return res.status(400).json({ message: 'Valid coordinates are required' });
    }
    
    const orders = await Order.findNearbyOrders(
      parseFloat(latitude),
      parseFloat(longitude),
      parseFloat(maxDistance)
    ).populate('customerId', 'name phone')
     .populate('vendorId', 'storeName address');
    
    res.json(orders);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getOrderTimeline = async (req, res) => {
  try {
    const order = await orderService.getOrderDetails(req.user, req.params.id);
    
    const timeline = order.statusHistory.map(history => ({
      status: history.status,
      timestamp: history.timestamp,
      note: history.note,
      location: history.location
    }));
    
    res.json(timeline);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getRiderEarnings = async (req, res) => {
  try {
    if (req.user.role !== 'rider') {
      return res.status(403).json({ message: 'Only riders can access earnings' });
    }
    
    const { startDate, endDate } = req.query;
    const query = { riderId: req.user.id };
    
    if (startDate && endDate) {
      query.createdAt = {
        $gte: new Date(startDate),
        $lte: new Date(endDate)
      };
    }
    
    const orders = await Order.find(query);
    
    const earnings = {
      totalEarnings: orders.reduce((sum, order) => sum + (order.riderEarnings || 0), 0),
      totalOrders: orders.length,
      averageEarnings: orders.length > 0 ? orders.reduce((sum, order) => sum + (order.riderEarnings || 0), 0) / orders.length : 0,
      totalTips: orders.reduce((sum, order) => sum + (order.tip || 0), 0),
      completedOrders: orders.filter(order => order.status === 'delivered').length
    };
    
    res.json(earnings);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.searchOrders = async (req, res) => {
  try {
    const { query, status, dateFrom, dateTo } = req.query;
    
    let searchQuery = {};
    
    // Role-based filtering
    if (req.user.role === 'vendor') {
      searchQuery.vendorId = req.user.id;
    } else if (req.user.role === 'rider') {
      searchQuery.riderId = req.user.id;
    } else if (req.user.role === 'customer') {
      searchQuery.customerId = req.user.id;
    }
    
    // Text search
    if (query) {
      searchQuery.$or = [
        { _id: { $regex: query, $options: 'i' } },
        { 'items.name': { $regex: query, $options: 'i' } },
        { specialInstructions: { $regex: query, $options: 'i' } }
      ];
    }
    
    // Status filter
    if (status) {
      searchQuery.status = status;
    }
    
    // Date range filter
    if (dateFrom || dateTo) {
      searchQuery.createdAt = {};
      if (dateFrom) searchQuery.createdAt.$gte = new Date(dateFrom);
      if (dateTo) searchQuery.createdAt.$lte = new Date(dateTo);
    }
    
    const orders = await Order.find(searchQuery)
      .populate('customerId', 'name phone')
      .populate('vendorId', 'storeName')
      .populate('riderId', 'name phone')
      .sort({ createdAt: -1 })
      .limit(50);
    
    res.json(orders);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
}; 

// T-Mart specific order placement
exports.placeTmartOrder = async (req, res) => {
  try {
    const { 
      items, 
      totalAmount, 
      deliveryFee, 
      finalTotal, 
      customerLocation, 
      deliveryAddress,
      specialInstructions,
      paymentMethod 
    } = req.body;
 
    // Validate required fields
    if (!items || !Array.isArray(items) || items.length === 0) {
      return res.status(400).json({ 
        success: false,
        message: 'Order items are required' 
      });
    }
       console.log("Hello", req.body);
    if (!customerLocation || !validateCoordinates(customerLocation.latitude, customerLocation.longitude)) {
      return res.status(400).json({ 
        success: false,
        message: 'Valid customer location is required' 
      });
    }
    
    // Validate T-Mart products
    const productIds = items.map(item => item.productId || item.id);
    
    const products = await Product.find({ _id: { $in: productIds } });
    console.log("Hellop", products);
    if (products.length !== productIds.length) {
      return res.status(400).json({ 
        success: false,
        message: 'Some products are not available' 
      });
    }
    
    // Calculate totals
    const calculatedTotal = items.reduce((sum, item) => {
      const productId = item.productId || item.id;
      const product = products.find(p => p._id.toString() === productId);
      return sum + (product.price * item.quantity);
    }, 0);
    
    const calculatedDeliveryFee = calculatedTotal >= 500 ? 0 : 40;
    const calculatedFinalTotal = calculatedTotal + calculatedDeliveryFee;
    
    // Validate totals
    if (Math.abs(calculatedTotal - totalAmount) > 0.01) {
      return res.status(400).json({ 
        success: false,
        message: 'Total amount mismatch' 
      });
    }
    
    if (Math.abs(calculatedFinalTotal - finalTotal) > 0.01) {
      return res.status(400).json({ 
        success: false,
        message: 'Final total mismatch' 
      });
    }
    
    // Create order data
    const orderData = {
      customerId: req.user.id,
      vendorType: 'tmart',
      vendorId: 'tmart', // T-Mart is a special vendor
      items: items.map(item => {
        const productId = item.productId || item.id;
        const product = products.find(p => p._id.toString() === productId);
        return {
          product: productId,
          name: product.name,
          price: product.price,
          quantity: item.quantity,
          image: product.imageUrl,
          unit: product.unit,
          category: product.category
        };
      }),
      itemTotal: calculatedTotal,
      deliveryFee: calculatedDeliveryFee,
      total: calculatedFinalTotal,
      customerLocation,
      deliveryAddress: deliveryAddress || customerLocation,
      specialInstructions: specialInstructions || '',
      paymentMethod: paymentMethod || 'cash',
      status: 'pending',
      orderType: 'tmart',
      estimatedDeliveryTime: new Date(Date.now() + 30 * 60 * 1000), // 30 minutes
    };
    
    // Place order using existing service
    const order = await orderService.placeOrder(req.user, orderData);
    
    res.status(201).json({
      success: true,
      message: 'T-Mart order placed successfully',
      data: order
    });
    
  } catch (err) {
    console.error('❌ Error placing T-Mart order:', err);
    res.status(500).json({ 
      success: false,
      message: err.message 
    });
  }
}; 