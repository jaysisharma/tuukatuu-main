const mongoose = require('mongoose');

const orderSchema = new mongoose.Schema({
  customerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  vendorId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  riderId: { type: mongoose.Schema.Types.ObjectId, ref: 'Rider' },
  
  // Order type and vendor type
  orderType: { type: String, enum: ['regular', 'tmart'], default: 'regular' },
  vendorType: { type: String, enum: ['regular', 'tmart'], default: 'regular' },
  
  // Order items
  items: [
    {
      product: { type: mongoose.Schema.Types.ObjectId, ref: 'Product', required: true },
      quantity: { type: Number, required: true },
      price: { type: Number, required: true },
      name: { type: String },
      image: { type: String },
      specialInstructions: { type: String },
      unit: { type: String }, // For T-Mart products (e.g., "1kg", "500ml")
      category: { type: String }, // For T-Mart products (e.g., "Fruits & Vegetables")
    }
  ],
  
  // Financial details
  itemTotal: { type: Number, required: true },      // Subtotal of items
  tax: { type: Number, required: true },            // Tax amount
  deliveryFee: { type: Number, required: true },    // Delivery fee
  tip: { type: Number, default: 0 },                // Tip for rider
  total: { type: Number, required: true },          // Final paid amount
  riderEarnings: { type: Number, default: 0 },      // Rider's earnings for this order
  
  // Payment information
  paymentMethod: { type: String, enum: ['cash', 'card', 'upi', 'wallet'], required: true },
  paymentStatus: { type: String, enum: ['pending', 'paid', 'failed', 'refunded'], default: 'pending' },
  transactionId: { type: String },
  
  // Order status
  status: {
    type: String,
    enum: ['pending', 'accepted', 'preparing', 'ready_for_pickup', 'picked_up', 'on_the_way', 'delivered', 'cancelled', 'rejected'],
    default: 'pending'
  },
  rejectionReason: { type: String },
  cancellationReason: { type: String },
  
  // Location tracking
  customerLocation: {
    latitude: { type: Number },
    longitude: { type: Number },
    address: { type: String, required: true },
    landmark: { type: String },
  },
  vendorLocation: {
    latitude: { type: Number },
    longitude: { type: Number },
    address: { type: String },
  },
  riderLocation: {
    latitude: { type: Number },
    longitude: { type: Number },
    updatedAt: { type: Date },
  },
  
  // Delivery timing
  estimatedDeliveryTime: { type: Date },
  actualDeliveryTime: { type: Date },
  estimatedPickupTime: { type: Date },
  actualPickupTime: { type: Date },
  deliveryDistance: { type: Number }, // in kilometers
  
  // Customer feedback
  customerRating: { type: Number, min: 1, max: 5 },
  customerReview: { type: String },
  reviewDate: { type: Date },
  
  // Special instructions
  specialInstructions: { type: String },
  deliveryInstructions: { type: String },
  
  // Status history for tracking
  statusHistory: [
    {
      status: {
        type: String,
        enum: ['pending', 'accepted', 'preparing', 'ready_for_pickup', 'picked_up', 'on_the_way', 'delivered', 'cancelled', 'rejected'],
        required: true
      },
      updatedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
      timestamp: { type: Date, default: Date.now },
      note: { type: String }, // Optional note for status change
      location: {
        latitude: { type: Number },
        longitude: { type: Number },
      },
    }
  ],
  
  // Rider assignment
  riderAssignment: {
    assignedAt: { type: Date },
    acceptedAt: { type: Date },
    rejectedAt: { type: Date },
    rejectionReason: { type: String },
    autoAssigned: { type: Boolean, default: false },
  },
  
  // Notifications
  notifications: [
    {
      type: { type: String, enum: ['status_update', 'rider_assigned', 'rider_location', 'delivery_eta', 'payment'] },
      sentAt: { type: Date, default: Date.now },
      sentTo: { type: String, enum: ['customer', 'vendor', 'rider'] },
      message: { type: String },
      read: { type: Boolean, default: false },
    }
  ],
  
  // Order metadata
  priority: { type: String, enum: ['low', 'normal', 'high', 'urgent'], default: 'normal' },
  tags: [{ type: String }], // For special orders, promotions, etc.
  
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Virtual for order age
orderSchema.virtual('orderAge').get(function() {
  return Date.now() - this.createdAt;
});

// Virtual for delivery time
orderSchema.virtual('deliveryTime').get(function() {
  if (this.actualDeliveryTime && this.createdAt) {
    return this.actualDeliveryTime - this.createdAt;
  }
  return null;
});

// Indexes for better performance
orderSchema.index({ customerId: 1, createdAt: -1 });
orderSchema.index({ vendorId: 1, status: 1 });
orderSchema.index({ riderId: 1, status: 1 });
orderSchema.index({ status: 1, createdAt: -1 });
orderSchema.index({ orderType: 1, priority: 1 }); // For T-Mart priority orders
orderSchema.index({ vendorType: 1, status: 1 }); // For vendor type filtering
orderSchema.index({ 'customerLocation.latitude': 1, 'customerLocation.longitude': 1 });
orderSchema.index({ 'riderLocation.latitude': 1, 'riderLocation.longitude': 1 });

// Pre-save middleware to update status history
orderSchema.pre('save', function(next) {
  if (this.isModified('status')) {
    this.statusHistory.push({
      status: this.status,
      updatedBy: this.riderId || this.vendorId || this.customerId,
      timestamp: new Date(),
    });
  }
  next();
});

// Static method to find nearby orders
orderSchema.statics.findNearbyOrders = function(latitude, longitude, maxDistance = 10) {
  return this.find({
    'customerLocation.latitude': {
      $gte: latitude - (maxDistance / 111), // Rough conversion to degrees
      $lte: latitude + (maxDistance / 111)
    },
    'customerLocation.longitude': {
      $gte: longitude - (maxDistance / 111),
      $lte: longitude + (maxDistance / 111)
    },
    status: { $in: ['pending', 'accepted', 'preparing'] }
  });
};

// Instance method to calculate ETA
orderSchema.methods.calculateETA = function() {
  if (!this.riderLocation || !this.customerLocation) {
    return null;
  }
  
  // Simple distance calculation (Haversine formula would be better)
  const latDiff = this.riderLocation.latitude - this.customerLocation.latitude;
  const lngDiff = this.riderLocation.longitude - this.customerLocation.longitude;
  const distance = Math.sqrt(latDiff * latDiff + lngDiff * lngDiff) * 111; // km
  
  // Assume average speed of 20 km/h
  const estimatedMinutes = Math.round((distance / 20) * 60);
  
  return new Date(Date.now() + estimatedMinutes * 60 * 1000);
};

module.exports = mongoose.model('Order', orderSchema); 