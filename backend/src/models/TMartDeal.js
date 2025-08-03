const mongoose = require('mongoose');

const tmartDealSchema = new mongoose.Schema({
  name: { type: String, required: true },
  description: { type: String },
  shortDescription: { type: String },
  imageUrl: { type: String, required: true },
  dealType: {
    type: String,
    enum: ['percentage', 'fixed', 'buy_one_get_one', 'combo', 'free_delivery'],
    required: true
  },
  discountValue: { type: Number }, // percentage or fixed amount
  minimumOrderAmount: { type: Number, default: 0 },
  maximumDiscount: { type: Number },
  applicableCategories: [{ type: String }],
  applicableProducts: [{ type: mongoose.Schema.Types.ObjectId, ref: 'TMartProduct' }],
  excludedProducts: [{ type: mongoose.Schema.Types.ObjectId, ref: 'TMartProduct' }],
  isActive: { type: Boolean, default: true },
  isFeatured: { type: Boolean, default: false },
  startDate: { type: Date, required: true },
  endDate: { type: Date, required: true },
  usageLimit: { type: Number }, // total usage limit
  userUsageLimit: { type: Number, default: 1 }, // per user usage limit
  usedCount: { type: Number, default: 0 },
  code: { type: String, unique: true, sparse: true }, // optional coupon code
  backgroundColor: { type: String, default: '#FF6B35' },
  textColor: { type: String, default: '#FFFFFF' },
  buttonText: { type: String, default: 'Shop Now' },
  targetAudience: {
    type: String,
    enum: ['all', 'new_users', 'existing_users', 'premium_users'],
    default: 'all'
  },
  tags: [{ type: String }],
}, { timestamps: true });

// Add indexes
tmartDealSchema.index({ isActive: 1, startDate: 1, endDate: 1 });
tmartDealSchema.index({ isFeatured: 1, isActive: 1 });
tmartDealSchema.index({ code: 1 });

// Virtual for checking if deal is currently active
tmartDealSchema.virtual('isCurrentlyActive').get(function() {
  const now = new Date();
  if (!this.isActive) return false;
  if (now < this.startDate) return false;
  if (now > this.endDate) return false;
  if (this.usageLimit && this.usedCount >= this.usageLimit) return false;
  return true;
});

// Virtual for remaining usage
tmartDealSchema.virtual('remainingUsage').get(function() {
  if (!this.usageLimit) return null;
  return Math.max(0, this.usageLimit - this.usedCount);
});

// Static method for seeding T-Mart deals
tmartDealSchema.statics.seedTMartDeals = async function() {
  const deals = [
    {
      name: 'Buy 1 Get 1 Free',
      description: 'Buy 1 Get 1 Free on selected fruits',
      shortDescription: 'On selected fruits',
      imageUrl: 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=400&h=400&fit=crop',
      dealType: 'buy_one_get_one',
      applicableCategories: ['fruits-vegetables'],
      isActive: true,
      isFeatured: true,
      startDate: new Date(),
      endDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // 30 days from now
      usageLimit: 1000,
      userUsageLimit: 2,
      backgroundColor: '#4CAF50',
      textColor: '#FFFFFF',
      buttonText: 'Shop Fruits',
      tags: ['fruits', 'bogo', 'fresh'],
    },
    {
      name: '₹99 Store',
      description: 'Everything at ₹99 - Limited time offer',
      shortDescription: 'Everything at ₹99',
      imageUrl: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&h=400&fit=crop',
      dealType: 'fixed',
      discountValue: 99,
      minimumOrderAmount: 200,
      isActive: true,
      isFeatured: true,
      startDate: new Date(),
      endDate: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 days from now
      usageLimit: 500,
      userUsageLimit: 1,
      backgroundColor: '#FF9800',
      textColor: '#FFFFFF',
      buttonText: 'Shop Now',
      tags: ['99', 'store', 'limited'],
    },
    {
      name: '50% Off on Dairy',
      description: 'Get 50% off on all dairy products',
      shortDescription: 'On dairy products',
      imageUrl: 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400&h=400&fit=crop',
      dealType: 'percentage',
      discountValue: 50,
      maximumDiscount: 200,
      applicableCategories: ['dairy-eggs'],
      isActive: true,
      isFeatured: true,
      startDate: new Date(),
      endDate: new Date(Date.now() + 14 * 24 * 60 * 60 * 1000), // 14 days from now
      usageLimit: 800,
      userUsageLimit: 3,
      backgroundColor: '#2196F3',
      textColor: '#FFFFFF',
      buttonText: 'Shop Dairy',
      tags: ['dairy', '50%', 'fresh'],
    },
    {
      name: 'Free Delivery',
      description: 'Free delivery on orders above ₹500',
      shortDescription: 'On orders above ₹500',
      imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=400&h=400&fit=crop',
      dealType: 'free_delivery',
      minimumOrderAmount: 500,
      isActive: true,
      isFeatured: false,
      startDate: new Date(),
      endDate: new Date(Date.now() + 60 * 24 * 60 * 60 * 1000), // 60 days from now
      usageLimit: null, // unlimited
      userUsageLimit: 5,
      backgroundColor: '#9C27B0',
      textColor: '#FFFFFF',
      buttonText: 'Order Now',
      tags: ['delivery', 'free', '500'],
    },
  ];

  await this.deleteMany({});
  await this.insertMany(deals);
};

module.exports = mongoose.model('TMartDeal', tmartDealSchema); 