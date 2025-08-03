const mongoose = require('mongoose');

const addressSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  
  // Address Details
  label: { type: String, required: true }, // e.g. Home, Work, Gym
  address: { type: String, required: true },
  
  // Coordinates for mapping and distance calculation
  coordinates: {
    latitude: { type: Number, required: true },
    longitude: { type: Number, required: true }
  },
  
  // Address Type and Preferences
  type: { 
    type: String, 
    enum: ['home', 'work', 'other'], 
    default: 'other' 
  },
  isDefault: { type: Boolean, default: false },
  isVerified: { type: Boolean, default: false },
  

  instructions: { type: String }, // Delivery instructions
  
  // Validation and Metadata
  validatedAt: { type: Date },
  validationSource: { type: String }, // 'google', 'manual', 'gps'
  
}, { 
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Indexes for better performance
addressSchema.index({ userId: 1, isDefault: 1 });
addressSchema.index({ 'coordinates.latitude': 1, 'coordinates.longitude': 1 });
addressSchema.index({ userId: 1, type: 1 });



// Pre-save middleware to ensure only one default address per user
addressSchema.pre('save', async function(next) {
  if (this.isDefault) {
    // Remove default flag from other addresses of the same user
    await this.constructor.updateMany(
      { userId: this.userId, _id: { $ne: this._id } },
      { isDefault: false }
    );
  }
  next();
});

// Static method to get default address for a user
addressSchema.statics.getDefaultAddress = function(userId) {
  return this.findOne({ userId, isDefault: true });
};

// Static method to find nearby addresses
addressSchema.statics.findNearby = function(latitude, longitude, maxDistance = 5) {
  return this.find({
    'coordinates.latitude': {
      $gte: latitude - (maxDistance / 111),
      $lte: latitude + (maxDistance / 111)
    },
    'coordinates.longitude': {
      $gte: longitude - (maxDistance / 111),
      $lte: longitude + (maxDistance / 111)
    }
  });
};

// Instance method to calculate distance from another point
addressSchema.methods.calculateDistance = function(latitude, longitude) {
  const R = 6371; // Earth's radius in kilometers
  const dLat = (latitude - this.coordinates.latitude) * Math.PI / 180;
  const dLon = (longitude - this.coordinates.longitude) * Math.PI / 180;
  const a =
    Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.cos(this.coordinates.latitude * Math.PI / 180) * Math.cos(latitude * Math.PI / 180) *
    Math.sin(dLon/2) * Math.sin(dLon/2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
  return R * c;
};

// Static method to seed vendor addresses
addressSchema.statics.seedVendorAddresses = async function(vendors) {
  const addresses = [];
  
  for (const vendor of vendors) {
    if (vendor.storeCoordinates && vendor.storeAddress) {
      const address = new this({
        userId: vendor._id,
        label: 'Store Location',
        address: vendor.storeAddress,
        coordinates: {
          latitude: vendor.storeCoordinates.latitude,
          longitude: vendor.storeCoordinates.longitude
        },
        type: 'other',
        isDefault: true,
        isVerified: true,
        instructions: 'Main store location',
        validatedAt: new Date(),
        validationSource: 'manual'
      });
      
      addresses.push(address);
    }
  }
  
  // Clear existing addresses for vendors
  const vendorIds = vendors.map(v => v._id);
  await this.deleteMany({ userId: { $in: vendorIds } });
  
  // Insert new addresses
  if (addresses.length > 0) {
    await this.insertMany(addresses);
  }
  
  return addresses;
};


module.exports = mongoose.model('Address', addressSchema);
