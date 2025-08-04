const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  title: {
    type: String,
    required: true,
    trim: true
  },
  message: {
    type: String,
    required: true,
    trim: true
  },
  type: {
    type: String,
    enum: ['order', 'promotion', 'system', 'delivery', 'payment'],
    default: 'system'
  },
  isRead: {
    type: Boolean,
    default: false
  },
  isSent: {
    type: Boolean,
    default: false
  },
  data: {
    orderId: String,
    vendorId: String,
    productId: String,
    amount: Number,
    deliveryTime: String,
    trackingNumber: String
  },
  priority: {
    type: String,
    enum: ['low', 'medium', 'high'],
    default: 'medium'
  },
  scheduledFor: {
    type: Date
  },
  sentAt: {
    type: Date
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

// Index for efficient queries
notificationSchema.index({ user: 1, createdAt: -1 });
notificationSchema.index({ user: 1, isRead: 1 });
notificationSchema.index({ scheduledFor: 1, isSent: false });

// Virtual for time ago
notificationSchema.virtual('timeAgo').get(function() {
  const now = new Date();
  const diffInSeconds = Math.floor((now - this.createdAt) / 1000);
  
  if (diffInSeconds < 60) {
    return 'Just now';
  } else if (diffInSeconds < 3600) {
    const minutes = Math.floor(diffInSeconds / 60);
    return `${minutes} minute${minutes > 1 ? 's' : ''} ago`;
  } else if (diffInSeconds < 86400) {
    const hours = Math.floor(diffInSeconds / 3600);
    return `${hours} hour${hours > 1 ? 's' : ''} ago`;
  } else {
    const days = Math.floor(diffInSeconds / 86400);
    return `${days} day${days > 1 ? 's' : ''} ago`;
  }
});

// Static method to create order notification
notificationSchema.statics.createOrderNotification = async function(userId, orderId, type, data = {}) {
  const notifications = {
    'order_placed': {
      title: 'Order Placed Successfully',
      message: 'Your order has been placed and is being processed.',
      type: 'order'
    },
    'order_confirmed': {
      title: 'Order Confirmed',
      message: 'Your order has been confirmed by the vendor.',
      type: 'order'
    },
    'order_preparing': {
      title: 'Order Being Prepared',
      message: 'Your order is being prepared by the vendor.',
      type: 'order'
    },
    'order_ready': {
      title: 'Order Ready for Pickup',
      message: 'Your order is ready for pickup.',
      type: 'order'
    },
    'order_out_for_delivery': {
      title: 'Out for Delivery',
      message: 'Your order is out for delivery.',
      type: 'delivery'
    },
    'order_delivered': {
      title: 'Order Delivered',
      message: 'Your order has been delivered successfully.',
      type: 'delivery'
    },
    'order_cancelled': {
      title: 'Order Cancelled',
      message: 'Your order has been cancelled.',
      type: 'order'
    },
    'order_rejected': {
      title: 'Order Rejected',
      message: 'Your order has been rejected by the vendor.',
      type: 'order'
    }
  };

  const notificationData = notifications[type];
  if (!notificationData) {
    throw new Error(`Invalid notification type: ${type}`);
  }

  const notification = new this({
    user: userId,
    title: notificationData.title,
    message: notificationData.message,
    type: notificationData.type,
    data: {
      orderId,
      ...data
    }
  });

  return await notification.save();
};

// Static method to create promotion notification
notificationSchema.statics.createPromotionNotification = async function(userId, title, message, data = {}) {
  const notification = new this({
    user: userId,
    title,
    message,
    type: 'promotion',
    data
  });

  return await notification.save();
};

// Static method to create system notification
notificationSchema.statics.createSystemNotification = async function(userId, title, message, data = {}) {
  const notification = new this({
    user: userId,
    title,
    message,
    type: 'system',
    data
  });

  return await notification.save();
};

// Static method to get unread count
notificationSchema.statics.getUnreadCount = async function(userId) {
  return await this.countDocuments({ user: userId, isRead: false });
};

// Static method to mark all as read
notificationSchema.statics.markAllAsRead = async function(userId) {
  return await this.updateMany(
    { user: userId, isRead: false },
    { isRead: true }
  );
};

// Static method to delete old notifications
notificationSchema.statics.deleteOldNotifications = async function(daysOld = 30) {
  const cutoffDate = new Date();
  cutoffDate.setDate(cutoffDate.getDate() - daysOld);
  
  return await this.deleteMany({
    createdAt: { $lt: cutoffDate },
    isRead: true
  });
};

// Static method to seed notifications
notificationSchema.statics.seedNotifications = async function() {
  const notifications = [
    {
      title: 'Welcome to Tuukatuu!',
      message: 'Thank you for joining us. Start exploring our wide range of products.',
      type: 'system',
      priority: 'high'
    },
    {
      title: 'Special Offer',
      message: 'Get 20% off on your first order. Use code WELCOME20',
      type: 'promotion',
      priority: 'medium'
    },
    {
      title: 'New Features Available',
      message: 'Check out our new features including real-time order tracking.',
      type: 'system',
      priority: 'low'
    }
  ];

  try {
    // Get a sample user to assign notifications to
    const User = require('./User');
    const sampleUser = await User.findOne();
    
    if (sampleUser) {
      for (const notificationData of notifications) {
        await this.createSystemNotification(
          sampleUser._id,
          notificationData.title,
          notificationData.message
        );
      }
      console.log('✅ Notifications seeded successfully');
    } else {
      console.log('⚠️ No users found to seed notifications');
    }
  } catch (error) {
    console.error('❌ Error seeding notifications:', error);
    throw error;
  }
};

module.exports = mongoose.model('Notification', notificationSchema); 