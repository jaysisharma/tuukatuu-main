const mongoose = require('mongoose');

const riderSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    unique: true // Ensures one user corresponds to one rider profile
  },

  // Personal Information
  profile: {
    fullName: { type: String, required: true, trim: true }, // Added trim
    email: {
      type: String,
      required: true,
      unique: true, // IMPORTANT: Ensure email is unique across riders
      lowercase: true,
      trim: true,
      match: [/^\S+@\S+\.\S+$/, 'Please use a valid email address.'] // Basic email format validation
    },
    phone: {
      type: String,
      required: true,
      unique: true, // IMPORTANT: Ensure phone is unique across riders
      trim: true,
      match: [/^\d{10,}$/, 'Phone number must be at least 10 digits.'] // Basic phone number validation
    },
    profileImage: { type: String },
    dateOfBirth: { type: Date },
    gender: { type: String, enum: ['male', 'female', 'other'] },
    emergencyContact: {
      name: { type: String, trim: true },
      phone: { type: String, trim: true },
      relationship: { type: String, trim: true }
    }
  },

  // Vehicle Information
  vehicle: {
    type: { type: String, enum: ['bike', 'scooter', 'car', 'bicycle'], required: true },
    brand: { type: String, required: true, trim: true }, // Marked as required
    model: { type: String, required: true, trim: true }, // Marked as required
    year: { type: Number, required: true }, // Marked as required
    color: { type: String, trim: true },
    licensePlate: {
      type: String,
      required: true,
      unique: true, // IMPORTANT: Ensure license plate is unique
      trim: true,
      uppercase: true // Store in uppercase for consistency
    },
    insuranceNumber: { type: String, trim: true },
    registrationNumber: { type: String, trim: true }
  },

  // Documents
  documents: {
    drivingLicense: {
      number: {
        type: String,
        required: true,
        trim: true,
        match: [/^DL\d{13}$/, 'Driving license number must be "DL" followed by 13 digits.'] // Added regex validation
      },
      expiryDate: {
        type: Date,
        required: true,
        validate: {
          validator: function(v) {
            return v > new Date(); // Ensure expiry date is in the future
          },
          message: props => `${props.value} is not a valid future expiry date for driving license!`
        }
      },
      image: { type: String }
    },
    vehicleRegistration: {
      number: { type: String, trim: true },
      expiryDate: { type: Date },
      image: { type: String }
    },
    insurance: {
      number: { type: String, trim: true },
      expiryDate: { type: Date },
      image: { type: String }
    },
    addressProof: {
      type: { type: String, trim: true },
      number: { type: String, trim: true },
      image: { type: String }
    }
  },

  // Location and Status
  currentLocation: {
    type: { type: String, default: 'Point' },
    coordinates: { type: [Number], default: [0, 0] }, // [longitude, latitude], added default
    address: { type: String, trim: true },
    lastUpdated: { type: Date, default: Date.now }
  },

  status: {
    type: String,
    enum: ['offline', 'online', 'busy', 'on_delivery'], // Removed duplicate 'offline'
    default: 'offline'
  },

  // Work Preferences
  workPreferences: {
    isAvailable: { type: Boolean, default: false },
    workingHours: {
      start: { type: String, default: '09:00' },
      end: { type: String, default: '18:00' }
    },
    preferredAreas: [{ type: String, trim: true }],
    maxDistance: { type: Number, default: 10 }, // in km
    vehicleCapacity: { type: Number, default: 5 } // max orders at once
  },

  // Earnings and Performance
  earnings: {
    totalEarnings: { type: Number, default: 0 },
    thisWeek: { type: Number, default: 0 },
    thisMonth: { type: Number, default: 0 },
    pendingAmount: { type: Number, default: 0 },
    walletBalance: { type: Number, default: 0 }
  },

  performance: {
    totalDeliveries: { type: Number, default: 0 },
    completedDeliveries: { type: Number, default: 0 },
    cancelledDeliveries: { type: Number, default: 0 },
    averageRating: { type: Number, default: 0 },
    totalReviews: { type: Number, default: 0 },
    onTimeDeliveries: { type: Number, default: 0 },
    lateDeliveries: { type: Number, default: 0 }
  },

  // Bank Details for Payouts
  bankDetails: {
    accountHolderName: { type: String, trim: true },
    accountNumber: { type: String, trim: true },
    ifscCode: { type: String, trim: true },
    bankName: { type: String, trim: true },
    branch: { type: String, trim: true }
  },

  // Verification Status
  verification: {
    isVerified: { type: Boolean, default: false },
    isApproved: { type: Boolean, default: false },
    rejectionReason: { type: String, trim: true },
    submittedAt: { type: Date },
    approvedAt: { type: Date },
    approvedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' }
  },

  // Current Assignment
  currentAssignment: {
    orderId: { type: mongoose.Schema.Types.ObjectId, ref: 'Order' },
    assignedAt: { type: Date },
    estimatedPickupTime: { type: Date },
    estimatedDeliveryTime: { type: Date },
    pickupLocation: {
      address: { type: String, trim: true },
      coordinates: { type: [Number], default: [0, 0] } // Added default
    },
    deliveryLocation: {
      address: { type: String, trim: true },
      coordinates: { type: [Number], default: [0, 0] } // Added default
    }
  },

  // Settings
  settings: {
    notifications: {
      newOrders: { type: Boolean, default: true },
      orderUpdates: { type: Boolean, default: true },
      earnings: { type: Boolean, default: true },
      system: { type: Boolean, default: true }
    },
    autoAccept: { type: Boolean, default: false },
    maxOrdersAtOnce: { type: Number, default: 1 }
  }

}, {
  timestamps: true // Adds createdAt and updatedAt timestamps
});

// Index for geospatial queries
riderSchema.index({ "currentLocation": "2dsphere" });

// Virtual for full name (already good)
riderSchema.virtual('fullName').get(function() {
  return this.profile.fullName;
});

// Method to update location (already good)
riderSchema.methods.updateLocation = function(latitude, longitude, address) {
  this.currentLocation.coordinates = [longitude, latitude];
  this.currentLocation.address = address;
  this.currentLocation.lastUpdated = new Date();
  return this.save();
};

// Method to calculate earnings (already good)
riderSchema.methods.calculateEarnings = function() {
  return {
    total: this.earnings.totalEarnings,
    thisWeek: this.earnings.thisWeek,
    thisMonth: this.earnings.thisMonth,
    pending: this.earnings.pendingAmount,
    wallet: this.earnings.walletBalance
  };
};

// Method to update performance (already good)
riderSchema.methods.updatePerformance = function(deliverySuccess, rating, onTime) {
  this.performance.totalDeliveries += 1;

  if (deliverySuccess) {
    this.performance.completedDeliveries += 1;
    if (onTime) {
      this.performance.onTimeDeliveries += 1;
    } else {
      this.performance.lateDeliveries += 1;
    }
  } else {
    this.performance.cancelledDeliveries += 1;
  }

  if (rating) {
    const totalRating = this.performance.averageRating * this.performance.totalReviews + rating;
    this.performance.totalReviews += 1;
    this.performance.averageRating = totalRating / this.performance.totalReviews;
  }

  return this.save();
};

// Static method to find nearby riders (already good)
riderSchema.statics.findNearby = function(longitude, latitude, maxDistance = 5) {
  return this.find({
    'currentLocation.coordinates': {
      $near: {
        $geometry: {
          type: 'Point',
          coordinates: [longitude, latitude]
        },
        $maxDistance: maxDistance * 1000 // Convert km to meters
      }
    },
    'status': { $in: ['online', 'available'] }, // 'available' might be a separate status or implied by 'online'
    'workPreferences.isAvailable': true,
    'verification.isApproved': true
  });
};

// Static method to seed riders (already good, but remember userId needs to be populated from actual User IDs)
riderSchema.statics.seedRiders = async function() {
  const riders = [
    {
      userId: null, // Placeholder: This needs to be an actual User._id
      profile: {
        fullName: 'Rahul Kumar',
        email: 'rahul.rider@example.com',
        phone: '9876543210',
        gender: 'male',
        emergencyContact: {
          name: 'Priya Kumar',
          phone: '9876543211',
          relationship: 'Wife'
        }
      },
      vehicle: {
        type: 'bike',
        brand: 'Honda',
        model: 'Activa 6G',
        year: 2022,
        color: 'Black',
        licensePlate: 'DL01AB1234'
      },
      documents: {
        drivingLicense: {
          number: 'DL0120201234567',
          expiryDate: new Date('2025-12-31')
        }
      },
      currentLocation: {
        coordinates: [77.2090, 28.6139], // Delhi coordinates
        address: 'Connaught Place, New Delhi'
      },
      status: 'online',
      workPreferences: {
        isAvailable: true,
        workingHours: { start: '08:00', end: '20:00' },
        preferredAreas: ['Connaught Place', 'Khan Market', 'Lajpat Nagar'],
        maxDistance: 8
      },
      verification: {
        isVerified: true,
        isApproved: true,
        submittedAt: new Date('2024-01-01'),
        approvedAt: new Date('2024-01-02')
      }
    },
    {
      userId: null, // Placeholder: This needs to be an actual User._id
      profile: {
        fullName: 'Amit Singh',
        email: 'amit.rider@example.com',
        phone: '9876543212',
        gender: 'male',
        emergencyContact: {
          name: 'Sunita Singh',
          phone: '9876543213',
          relationship: 'Sister'
        }
      },
      vehicle: {
        type: 'scooter',
        brand: 'TVS',
        model: 'Jupiter',
        year: 2021,
        color: 'Blue',
        licensePlate: 'DL02CD5678'
      },
      documents: {
        drivingLicense: {
          number: 'DL0120207654321',
          expiryDate: new Date('2026-06-30')
        }
      },
      currentLocation: {
        coordinates: [77.2167, 28.7041], // Delhi coordinates
        address: 'Khan Market, New Delhi'
      },
      status: 'online',
      workPreferences: {
        isAvailable: true,
        workingHours: { start: '09:00', end: '21:00' },
        preferredAreas: ['Khan Market', 'South Extension', 'Greater Kailash'],
        maxDistance: 10
      },
      verification: {
        isVerified: true,
        isApproved: true,
        submittedAt: new Date('2024-01-01'),
        approvedAt: new Date('2024-01-02')
      }
    }
  ];

  return riders;
};

module.exports = mongoose.model('Rider', riderSchema);