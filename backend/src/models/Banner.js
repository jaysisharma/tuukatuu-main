const mongoose = require('mongoose');

const bannerSchema = new mongoose.Schema({
  // Basic Information
  title: {
    type: String,
    required: true,
    trim: true
  },
  subtitle: {
    type: String,
    trim: true,
    default: ''
  },
  description: {
    type: String,
    trim: true,
    default: ''
  },
  
  // Media
  image: {
    type: String,
    required: true
  },
  imageAlt: {
    type: String,
    default: ''
  },
  
  // Link Configuration
  link: {
    type: String,
    default: ''
  },
  linkType: {
    type: String,
    enum: ['product', 'category', 'external', 'none'],
    default: 'none'
  },
  linkTarget: {
    type: String,
    default: ''
  },
  
  // Banner Type and Category
  bannerType: {
    type: String,
    enum: ['regular', 'tmart', 'hero', 'category', 'promotional', 'deal'],
    default: 'regular'
  },
  category: {
    type: String,
    enum: ['restaurant', 'grocery', 'pharmacy', 'general'],
    default: 'general'
  },
  
  // Display Settings
  sortOrder: {
    type: Number,
    default: 0
  },
  priority: {
    type: Number,
    default: 1
  },
  backgroundColor: {
    type: String,
    default: '#FF6B35'
  },
  textColor: {
    type: String,
    default: '#FFFFFF'
  },
  
  // Status and Visibility
  isActive: {
    type: Boolean,
    default: true
  },
  isFeatured: {
    type: Boolean,
    default: false
  },
  
  // Scheduling
  startDate: {
    type: Date,
    default: Date.now
  },
  endDate: {
    type: Date,
    default: null
  },
  
  // Targeting
  targetAudience: {
    type: [String],
    default: []
  },
  
  // Analytics
  clicks: {
    type: Number,
    default: 0
  },
  impressions: {
    type: Number,
    default: 0
  },
  
  // Metadata
  createdBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  updatedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Indexes for better query performance
bannerSchema.index({ bannerType: 1, isActive: 1 });
bannerSchema.index({ category: 1, isActive: 1 });
bannerSchema.index({ isFeatured: 1, isActive: 1 });
bannerSchema.index({ sortOrder: 1, priority: 1 });
bannerSchema.index({ startDate: 1, endDate: 1 });
bannerSchema.index({ createdAt: -1 });
bannerSchema.index({ bannerType: 1, category: 1 });

// Virtual for banner status
bannerSchema.virtual('status').get(function() {
  if (!this.isActive) return 'inactive';
  if (this.endDate && new Date() > this.endDate) return 'expired';
  if (this.startDate && new Date() < this.startDate) return 'scheduled';
  return 'active';
});

// Virtual for click-through rate
bannerSchema.virtual('ctr').get(function() {
  if (this.impressions === 0) return 0;
  return (this.clicks / this.impressions * 100).toFixed(2);
});

// Pre-save middleware to validate dates
bannerSchema.pre('save', function(next) {
  if (this.endDate && this.startDate && this.endDate <= this.startDate) {
    return next(new Error('End date must be after start date'));
  }
  next();
});

// Static method to get active banners by type
bannerSchema.statics.getActiveByType = function(type, options = {}) {
  const now = new Date();
  const query = {
    isActive: true,
    startDate: { $lte: now },
    $or: [
      { endDate: null },
      { endDate: { $gt: now } }
    ]
  };
  
  if (type) {
    query.bannerType = type;
  }
  
  if (options.category) {
    query.category = options.category;
  }
  
  if (options.featured) {
    query.isFeatured = true;
  }
  
  return this.find(query)
    .sort({ sortOrder: 1, priority: 1, createdAt: -1 })
    .limit(options.limit || 10);
};

// Static method to get active banners
bannerSchema.statics.getActive = function(options = {}) {
  return this.getActiveByType(null, options);
};

// Static method to get featured banners
bannerSchema.statics.getFeatured = function(options = {}) {
  return this.getActiveByType(null, { ...options, featured: true });
};

// Static method to get banners by type
bannerSchema.statics.getByType = function(type, options = {}) {
  return this.getActiveByType(type, options);
};

// Method to increment impressions
bannerSchema.methods.incrementImpression = function() {
  this.impressions += 1;
  return this.save();
};

// Method to increment clicks
bannerSchema.methods.incrementClick = function() {
  this.clicks += 1;
  return this.save();
};

// Method to update analytics
bannerSchema.methods.updateAnalytics = function(type) {
  if (type === 'impression') {
    this.impressions += 1;
  } else if (type === 'click') {
    this.clicks += 1;
  }
  return this.save();
};

module.exports = mongoose.model('Banner', bannerSchema); 