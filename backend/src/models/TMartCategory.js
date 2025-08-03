const mongoose = require('mongoose');

const tmartCategorySchema = new mongoose.Schema({
  name: { type: String, required: true, unique: true },
  displayName: { type: String, required: true },
  description: { type: String },
  iconUrl: { type: String },
  imageUrl: { type: String },
  color: { type: String, default: '#2E7D32' },
  parentCategory: { type: mongoose.Schema.Types.ObjectId, ref: 'TMartCategory' },
  subCategories: [{ type: mongoose.Schema.Types.ObjectId, ref: 'TMartCategory' }],
  isActive: { type: Boolean, default: true },
  isFeatured: { type: Boolean, default: false },
  sortOrder: { type: Number, default: 0 },
  productCount: { type: Number, default: 0 },
  tags: [{ type: String }], // for search and filtering
}, { timestamps: true });

// Add indexes
tmartCategorySchema.index({ isActive: 1, sortOrder: 1 });
tmartCategorySchema.index({ isFeatured: 1, isActive: 1 });
tmartCategorySchema.index({ parentCategory: 1 });

// Static method for seeding T-Mart categories
tmartCategorySchema.statics.seedTMartCategories = async function() {
  const categories = [
    {
      name: 'fruits-vegetables',
      displayName: 'Fruits & Vegetables',
      description: 'Fresh fruits and vegetables',
      iconUrl: 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=200&h=200&fit=crop',
      color: '#4CAF50',
      isFeatured: true,
      sortOrder: 1,
      tags: ['fruits', 'vegetables', 'fresh', 'organic'],
    },
    {
      name: 'dairy-eggs',
      displayName: 'Dairy & Eggs',
      description: 'Fresh dairy products and eggs',
      iconUrl: 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=200&h=200&fit=crop',
      color: '#2196F3',
      isFeatured: true,
      sortOrder: 2,
      tags: ['dairy', 'eggs', 'milk', 'cheese'],
    },
    {
      name: 'bakery',
      displayName: 'Bakery',
      description: 'Fresh baked goods',
      iconUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=200&h=200&fit=crop',
      color: '#FF9800',
      isFeatured: true,
      sortOrder: 3,
      tags: ['bakery', 'bread', 'cakes', 'pastries'],
    },
    {
      name: 'meat-fish',
      displayName: 'Meat & Fish',
      description: 'Fresh meat and seafood',
      iconUrl: 'https://images.unsplash.com/photo-1516594798947-e65505dbb29d?w=200&h=200&fit=crop',
      color: '#F44336',
      isFeatured: true,
      sortOrder: 4,
      tags: ['meat', 'fish', 'chicken', 'seafood'],
    },
    {
      name: 'snacks',
      displayName: 'Snacks',
      description: 'Delicious snacks and treats',
      iconUrl: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=200&h=200&fit=crop',
      color: '#9C27B0',
      isFeatured: true,
      sortOrder: 5,
      tags: ['snacks', 'chips', 'cookies', 'nuts'],
    },
    {
      name: 'beverages',
      displayName: 'Beverages',
      description: 'Refreshing drinks',
      iconUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=200&h=200&fit=crop',
      color: '#00BCD4',
      isFeatured: true,
      sortOrder: 6,
      tags: ['beverages', 'juice', 'soda', 'tea'],
    },
    {
      name: 'household',
      displayName: 'Household',
      description: 'Household essentials',
      iconUrl: 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=200&h=200&fit=crop',
      color: '#3F51B5',
      isFeatured: false,
      sortOrder: 7,
      tags: ['household', 'cleaning', 'detergents'],
    },
    {
      name: 'personal-care',
      displayName: 'Personal Care',
      description: 'Personal care products',
      iconUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=200&h=200&fit=crop',
      color: '#E91E63',
      isFeatured: false,
      sortOrder: 8,
      tags: ['personal care', 'hygiene', 'beauty'],
    },
    {
      name: 'wine-beer',
      displayName: 'Wine & Beer',
      description: 'Premium wines, beers, and spirits',
      iconUrl: 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3?w=200&h=200&fit=crop',
      color: '#8D6E63',
      isFeatured: true,
      sortOrder: 9,
      tags: ['wine', 'beer', 'spirits', 'alcohol', 'premium'],
    },
  ];

  await this.deleteMany({});
  await this.insertMany(categories);
};

module.exports = mongoose.model('TMartCategory', tmartCategorySchema); 