const mongoose = require('mongoose');

const todayDealSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true
  },
  description: {
    type: String,
    required: true
  },
  imageUrl: {
    type: String,
    required: true
  },
  originalPrice: {
    type: Number,
    required: true
  },
  price: {
    type: Number,
    required: true
  },
  discount: {
    type: Number,
    required: true
  },
  dealType: {
    type: String,
    enum: ['percentage', 'fixed', 'buy_one_get_one'],
    default: 'percentage'
  },
  description: {
    type: String,
    required: true
  },
  isActive: {
    type: Boolean,
    default: true
  },
  startDate: {
    type: Date,
    default: Date.now
  },
  endDate: {
    type: Date,
    required: true
  },
  maxQuantity: {
    type: Number,
    default: 10
  },
  soldQuantity: {
    type: Number,
    default: 0
  },
  category: {
    type: String,
    required: true
  },
  tags: [{
    type: String
  }],
  featured: {
    type: Boolean,
    default: false
  }
}, {
  timestamps: true
});

// Index for efficient queries
todayDealSchema.index({ isActive: 1, endDate: 1 });
todayDealSchema.index({ featured: 1, isActive: 1 });

// Virtual for remaining quantity
todayDealSchema.virtual('remainingQuantity').get(function() {
  return this.maxQuantity - this.soldQuantity;
});

// Virtual for deal status
todayDealSchema.virtual('isExpired').get(function() {
  return new Date() > this.endDate;
});

// Virtual for deal validity
todayDealSchema.virtual('isValid').get(function() {
  return this.isActive && !this.isExpired && this.remainingQuantity > 0;
});

module.exports = mongoose.model('TodayDeal', todayDealSchema); 