const mongoose = require('mongoose');

const tmartBannerSchema = new mongoose.Schema({
  title: { type: String, required: true },
  subtitle: { type: String },
  description: { type: String },
  imageUrl: { type: String, required: true },
  mobileImageUrl: { type: String },
  desktopImageUrl: { type: String },
  backgroundColor: { type: String, default: '#2E7D32' },
  textColor: { type: String, default: '#FFFFFF' },
  buttonText: { type: String },
  buttonColor: { type: String, default: '#FF6B35' },
  actionType: {
    type: String,
    enum: ['category', 'product', 'deals', 'external', 'none'],
    default: 'none'
  },
  actionValue: { type: String }, // category name, product id, or external URL
  isActive: { type: Boolean, default: true },
  isFeatured: { type: Boolean, default: false },
  sortOrder: { type: Number, default: 0 },
  startDate: { type: Date },
  endDate: { type: Date },
  targetAudience: {
    type: String,
    enum: ['all', 'new_users', 'existing_users', 'premium_users'],
    default: 'all'
  },
  tags: [{ type: String }],
}, { timestamps: true });

// Add indexes
tmartBannerSchema.index({ isActive: 1, sortOrder: 1 });
tmartBannerSchema.index({ isFeatured: 1, isActive: 1 });
tmartBannerSchema.index({ startDate: 1, endDate: 1 });

// Virtual for checking if banner is currently active
tmartBannerSchema.virtual('isCurrentlyActive').get(function() {
  const now = new Date();
  if (!this.isActive) return false;
  if (this.startDate && now < this.startDate) return false;
  if (this.endDate && now > this.endDate) return false;
  return true;
});

// Static method for seeding T-Mart banners
tmartBannerSchema.statics.seedTMartBanners = async function() {
  const banners = [
    {
      title: 'Fresh Groceries',
      subtitle: 'Up to 50% off',
      description: 'Get fresh groceries delivered to your doorstep',
      imageUrl: 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=800&h=400&fit=crop',
      backgroundColor: '#4CAF50',
      textColor: '#FFFFFF',
      buttonText: 'Shop Now',
      buttonColor: '#FF6B35',
      actionType: 'category',
      actionValue: 'fruits-vegetables',
      isActive: true,
      isFeatured: true,
      sortOrder: 1,
      tags: ['groceries', 'fresh', 'discount'],
    },
    {
      title: 'Quick Delivery',
      subtitle: '10 minutes or free',
      description: 'Super fast delivery guaranteed',
      imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800&h=400&fit=crop',
      backgroundColor: '#2196F3',
      textColor: '#FFFFFF',
      buttonText: 'Order Now',
      buttonColor: '#FF6B35',
      actionType: 'deals',
      actionValue: 'quick-delivery',
      isActive: true,
      isFeatured: true,
      sortOrder: 2,
      tags: ['delivery', 'fast', 'quick'],
    },
    {
      title: 'Premium Quality',
      subtitle: 'Best products guaranteed',
      description: 'Only the finest quality products',
      imageUrl: 'https://images.unsplash.com/photo-1534723452862-4c874018d66d?w=800&h=400&fit=crop',
      backgroundColor: '#FF9800',
      textColor: '#FFFFFF',
      buttonText: 'Explore',
      buttonColor: '#2E7D32',
      actionType: 'category',
      actionValue: 'premium',
      isActive: true,
      isFeatured: true,
      sortOrder: 3,
      tags: ['premium', 'quality', 'best'],
    },
  ];

  await this.deleteMany({});
  await this.insertMany(banners);
};

module.exports = mongoose.model('TMartBanner', tmartBannerSchema); 