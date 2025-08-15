const mongoose = require('mongoose');

const vendorSchema = new mongoose.Schema({
  storeName: {
    type: String,
    required: true,
    trim: true
  },
  storeDescription: {
    type: String,
    trim: true
  },
  storeImage: {
    type: String
  },
  storeAddress: {
    type: String,
    required: true
  },
  storePhone: {
    type: String,
    required: true
  },
  storeEmail: {
    type: String,
    required: true,
    unique: true
  },
  storeCoordinates: {
    type: {
      type: String,
      enum: ['Point'],
      default: 'Point'
    },
    coordinates: {
      type: [Number],
      required: true
    }
  },
  categories: [{
    type: String,
    trim: true
  }],
  storeRating: {
    type: Number,
    default: 0,
    min: 0,
    max: 5
  },
  totalRatings: {
    type: Number,
    default: 0
  },
  isApproved: {
    type: Boolean,
    default: false
  },
  isFeatured: {
    type: Boolean,
    default: false
  },
  isActive: {
    type: Boolean,
    default: true
  },
  openingHours: {
    monday: { open: String, close: String },
    tuesday: { open: String, close: String },
    wednesday: { open: String, close: String },
    thursday: { open: String, close: String },
    friday: { open: String, close: String },
    saturday: { open: String, close: String },
    sunday: { open: String, close: String }
  },
  deliveryTime: {
    type: String,
    default: '30-45 min'
  },
  minimumOrder: {
    type: Number,
    default: 0
  },
  deliveryFee: {
    type: Number,
    default: 0
  },
  owner: {
    name: String,
    phone: String,
    email: String
  },
  documents: {
    businessLicense: String,
    taxCertificate: String,
    idProof: String
  },
  bankDetails: {
    accountNumber: String,
    accountHolder: String,
    bankName: String,
    ifscCode: String
  },
  commission: {
    type: Number,
    default: 10 // Percentage
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

// Create geospatial index
vendorSchema.index({ storeCoordinates: '2dsphere' });

// Virtual for average rating
vendorSchema.virtual('averageRating').get(function () {
  return this.totalRatings > 0 ? this.storeRating / this.totalRatings : 0;
});

// Method to update rating
vendorSchema.methods.updateRating = function (newRating) {
  const totalRating = this.storeRating + newRating;
  this.totalRatings += 1;
  this.storeRating = totalRating;
  return this.save();
};

// Method to check if store is open
vendorSchema.methods.isOpen = function () {
  const now = new Date();
  const day = now.toLocaleLowerCase().slice(0, 3);
  const currentTime = now.toTimeString().slice(0, 5);

  const todayHours = this.openingHours[day];
  if (!todayHours || !todayHours.open || !todayHours.close) {
    return false;
  }

  return currentTime >= todayHours.open && currentTime <= todayHours.close;
};

// Static method to find nearby vendors
vendorSchema.statics.findNearby = function (coordinates, maxDistance = 10000) {
  return this.find({
    storeCoordinates: {
      $near: {
        $geometry: {
          type: 'Point',
          coordinates: coordinates
        },
        $maxDistance: maxDistance
      }
    },
    isApproved: true,
    isActive: true
  });
};

// Static method to get all vendors for map
vendorSchema.statics.getVendorsForMap = function () {
  return this.find({
    isApproved: true,
    isActive: true,
    'storeCoordinates.coordinates': { $exists: true, $ne: null }
  }).select('storeName storeDescription storeImage storeAddress storeCoordinates categories storeRating deliveryTime minimumOrder deliveryFee');
};

// Static method to get vendors within bounds
vendorSchema.statics.getVendorsInBounds = function (bounds) {
  return this.find({
    isApproved: true,
    isActive: true,
    storeCoordinates: {
      $geoWithin: {
        $box: [
          [bounds.southwest.lng, bounds.southwest.lat],
          [bounds.northeast.lng, bounds.northeast.lat]
        ]
      }
    }
  }).select('storeName storeDescription storeImage storeAddress storeCoordinates categories storeRating deliveryTime minimumOrder deliveryFee');
};



module.exports = mongoose.model('Vendor', vendorSchema);
