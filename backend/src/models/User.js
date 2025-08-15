const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  name: { type: String, required: true, trim: true },
  email: { type: String, required: true, unique: true, trim: true },
  phone: { type: String, required: true, unique: true, trim: true },
  password: { type: String, required: true },
  role: {
    type: String,
    enum: ['admin', 'vendor', 'rider', 'customer'],
    default: 'customer',
    required: true,
  },
  isActive: { type: Boolean, default: true },

  // Vendor/store fields
  storeName: { type: String, trim: true },
  storeDescription: { type: String, trim: true },
  storeImage: { type: String }, // logo URL
  storeBanner: { type: String }, 
  storeTags: [{ type: String, trim: true }],
  // storeCategories: [{ type: String, trim: true }],

  vendorType: {
    type: String,
    enum: ['restaurant', 'store'],
    default: 'store'
  },
  // vendorSubType: { type: String, trim: true },

  storeRating: { type: Number, default: 0 },
  storeReviews: { type: Number, default: 0 },
  isFeatured: { type: Boolean, default: false },

  // GeoJSON format for geospatial queries
  storeCoordinates: {
    type: {
      type: String,
      enum: ['Point'],
      // default: 'Point',
    },
    coordinates: {
      type: [Number],  // [longitude, latitude]
      // required: true
    }
  },

  storeAddress: { type: String, trim: true },

  // Favorites field
  favorites: [{
    itemId: { type: String, required: true },
    itemType: { type: String, required: true, enum: ['restaurant', 'store', 'product'] },
    itemName: { type: String, required: true },
    itemImage: { type: String },
    rating: { type: Number },
    category: { type: String },
    addedAt: { type: Date, default: Date.now }
  }],
}, { timestamps: true });

// Create 2dsphere index on storeCoordinates for geo queries
userSchema.index({ storeCoordinates: '2dsphere' });

module.exports = mongoose.model('User', userSchema);
