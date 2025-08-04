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

// Create geospatial index for location-based queries
vendorSchema.index({ storeCoordinates: '2dsphere' });

// Virtual for average rating
vendorSchema.virtual('averageRating').get(function() {
  return this.totalRatings > 0 ? this.storeRating / this.totalRatings : 0;
});

// Method to update rating
vendorSchema.methods.updateRating = function(newRating) {
  const totalRating = this.storeRating + newRating;
  this.totalRatings += 1;
  this.storeRating = totalRating;
  return this.save();
};

// Method to check if store is open
vendorSchema.methods.isOpen = function() {
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
vendorSchema.statics.findNearby = function(coordinates, maxDistance = 10000) {
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

// Static method to get all vendors with coordinates for map display
vendorSchema.statics.getVendorsForMap = function() {
  return this.find({
    isApproved: true,
    isActive: true,
    'storeCoordinates.coordinates': { $exists: true, $ne: null }
  }).select('storeName storeDescription storeImage storeAddress storeCoordinates categories storeRating deliveryTime minimumOrder deliveryFee');
};

// Static method to get vendors within a bounding box
vendorSchema.statics.getVendorsInBounds = function(bounds) {
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

// Static method to seed vendors
vendorSchema.statics.seedVendors = async function() {
  const vendors = [
    {
      storeName: 'Fresh Grocery Store',
      storeDescription: 'Your one-stop shop for fresh groceries and household items',
      storeImage: 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136',
      storeAddress: '123 Main Street, Downtown',
      storePhone: '+1234567890',
      storeEmail: 'freshgrocery@example.com',
      storeCoordinates: {
        type: 'Point',
        coordinates: [-73.935242, 40.730610] // New York Downtown
      },
      categories: ['Grocery', 'Fresh Produce', 'Dairy'],
      storeRating: 4.5,
      totalRatings: 120,
      isApproved: true,
      isFeatured: true,
      deliveryTime: '30-45 min',
      minimumOrder: 20,
      deliveryFee: 5
    },
    {
      storeName: 'Quick Mart Express',
      storeDescription: 'Fast delivery of essential items',
      storeImage: 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43',
      storeAddress: '456 Oak Avenue, Midtown',
      storePhone: '+1234567891',
      storeEmail: 'quickmart@example.com',
      storeCoordinates: {
        type: 'Point',
        coordinates: [-73.985428, 40.748817] // New York Midtown
      },
      categories: ['Convenience', 'Snacks', 'Beverages'],
      storeRating: 4.2,
      totalRatings: 85,
      isApproved: true,
      isFeatured: false,
      deliveryTime: '15-30 min',
      minimumOrder: 15,
      deliveryFee: 3
    },
    {
      storeName: 'Organic Health Market',
      storeDescription: 'Premium organic and health foods',
      storeImage: 'https://images.unsplash.com/photo-1542838132-92c53300491e',
      storeAddress: '789 Health Lane, Uptown',
      storePhone: '+1234567892',
      storeEmail: 'organichealth@example.com',
      storeCoordinates: {
        type: 'Point',
        coordinates: [-73.958099, 40.800296] // New York Uptown
      },
      categories: ['Organic', 'Health Foods', 'Supplements'],
      storeRating: 4.8,
      totalRatings: 95,
      isApproved: true,
      isFeatured: true,
      deliveryTime: '45-60 min',
      minimumOrder: 30,
      deliveryFee: 7
    },
    {
      storeName: 'Pizza Palace',
      storeDescription: 'Authentic Italian pizza and pasta',
      storeImage: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b',
      storeAddress: '321 Pizza Street, Little Italy',
      storePhone: '+1234567893',
      storeEmail: 'pizzapalace@example.com',
      storeCoordinates: {
        type: 'Point',
        coordinates: [-73.997429, 40.718162] // New York Little Italy
      },
      categories: ['Pizza', 'Italian', 'Fast Food'],
      storeRating: 4.6,
      totalRatings: 200,
      isApproved: true,
      isFeatured: true,
      deliveryTime: '25-35 min',
      minimumOrder: 25,
      deliveryFee: 4
    },
    {
      storeName: 'Sushi Express',
      storeDescription: 'Fresh sushi and Japanese cuisine',
      storeImage: 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351',
      storeAddress: '654 Sushi Road, Chinatown',
      storePhone: '+1234567894',
      storeEmail: 'sushiexpress@example.com',
      storeCoordinates: {
        type: 'Point',
        coordinates: [-73.996139, 40.715751] // New York Chinatown
      },
      categories: ['Sushi', 'Japanese', 'Asian'],
      storeRating: 4.4,
      totalRatings: 150,
      isApproved: true,
      isFeatured: false,
      deliveryTime: '35-50 min',
      minimumOrder: 30,
      deliveryFee: 6
    },
    {
      storeName: 'Burger Joint',
      storeDescription: 'Gourmet burgers and American classics',
      storeImage: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd',
      storeAddress: '987 Burger Avenue, Meatpacking',
      storePhone: '+1234567895',
      storeEmail: 'burgerjoint@example.com',
      storeCoordinates: {
        type: 'Point',
        coordinates: [-74.006015, 40.741776] // New York Meatpacking
      },
      categories: ['Burgers', 'American', 'Fast Food'],
      storeRating: 4.3,
      totalRatings: 180,
      isApproved: true,
      isFeatured: false,
      deliveryTime: '20-30 min',
      minimumOrder: 20,
      deliveryFee: 3
    },
    {
      storeName: 'Taco Fiesta',
      storeDescription: 'Authentic Mexican tacos and street food',
      storeImage: 'https://images.unsplash.com/photo-1565299585323-38d6b0865b47',
      storeAddress: '555 Taco Lane, East Village',
      storePhone: '+1234567896',
      storeEmail: 'tacofiesta@example.com',
      storeCoordinates: {
        type: 'Point',
        coordinates: [-73.988129, 40.726478] // New York East Village
      },
      categories: ['Mexican', 'Tacos', 'Street Food'],
      storeRating: 4.7,
      totalRatings: 165,
      isApproved: true,
      isFeatured: true,
      deliveryTime: '20-30 min',
      minimumOrder: 18,
      deliveryFee: 4
    },
    {
      storeName: 'Coffee Corner',
      storeDescription: 'Artisanal coffee and pastries',
      storeImage: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb',
      storeAddress: '777 Coffee Street, West Village',
      storePhone: '+1234567897',
      storeEmail: 'coffeecorner@example.com',
      storeCoordinates: {
        type: 'Point',
        coordinates: [-74.003834, 40.732253] // New York West Village
      },
      categories: ['Coffee', 'Pastries', 'Beverages'],
      storeRating: 4.9,
      totalRatings: 220,
      isApproved: true,
      isFeatured: true,
      deliveryTime: '15-25 min',
      minimumOrder: 12,
      deliveryFee: 2
    },
    {
      storeName: 'Indian Spice',
      storeDescription: 'Authentic Indian cuisine and spices',
      storeImage: 'https://images.unsplash.com/photo-1565557623262-b51c2513a641',
      storeAddress: '888 Curry Road, Murray Hill',
      storePhone: '+1234567898',
      storeEmail: 'indianspice@example.com',
      storeCoordinates: {
        type: 'Point',
        coordinates: [-73.975433, 40.748817] // New York Murray Hill
      },
      categories: ['Indian', 'Curry', 'Spices'],
      storeRating: 4.5,
      totalRatings: 140,
      isApproved: true,
      isFeatured: false,
      deliveryTime: '40-55 min',
      minimumOrder: 25,
      deliveryFee: 5
    },
    {
      storeName: 'Thai Delight',
      storeDescription: 'Fresh Thai cuisine and noodles',
      storeImage: 'https://images.unsplash.com/photo-1559314809-0d155014e29e',
      storeAddress: '999 Thai Street, Hell\'s Kitchen',
      storePhone: '+1234567899',
      storeEmail: 'thaidelight@example.com',
      storeCoordinates: {
        type: 'Point',
        coordinates: [-73.992248, 40.758896] // New York Hell's Kitchen
      },
      categories: ['Thai', 'Noodles', 'Asian'],
      storeRating: 4.6,
      totalRatings: 175,
      isApproved: true,
      isFeatured: true,
      deliveryTime: '30-45 min',
      minimumOrder: 22,
      deliveryFee: 4
    },
    {
      storeName: 'Mediterranean Grill',
      storeDescription: 'Fresh Mediterranean and Greek cuisine',
      storeImage: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1',
      storeAddress: '111 Olive Street, Upper East Side',
      storePhone: '+1234567900',
      storeEmail: 'medgrill@example.com',
      storeCoordinates: {
        type: 'Point',
        coordinates: [-73.971321, 40.764501] // New York Upper East Side
      },
      categories: ['Mediterranean', 'Greek', 'Healthy'],
      storeRating: 4.8,
      totalRatings: 130,
      isApproved: true,
      isFeatured: true,
      deliveryTime: '35-50 min',
      minimumOrder: 28,
      deliveryFee: 6
    },
    {
      storeName: 'BBQ Smokehouse',
      storeDescription: 'Authentic BBQ and smoked meats',
      storeImage: 'https://images.unsplash.com/photo-1544025162-d76694265947',
      storeAddress: '222 Smoke Street, Brooklyn Heights',
      storePhone: '+1234567901',
      storeEmail: 'bbqsmokehouse@example.com',
      storeCoordinates: {
        type: 'Point',
        coordinates: [-73.996864, 40.700226] // Brooklyn Heights
      },
      categories: ['BBQ', 'Smoked Meats', 'American'],
      storeRating: 4.4,
      totalRatings: 190,
      isApproved: true,
      isFeatured: false,
      deliveryTime: '45-60 min',
      minimumOrder: 35,
      deliveryFee: 8
    },
    {
      storeName: 'Vegan Paradise',
      storeDescription: 'Plant-based vegan and vegetarian cuisine',
      storeImage: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd',
      storeAddress: '333 Green Street, Williamsburg',
      storePhone: '+1234567902',
      storeEmail: 'veganparadise@example.com',
      storeCoordinates: {
        type: 'Point',
        coordinates: [-73.953918, 40.718092] // Brooklyn Williamsburg
      },
      categories: ['Vegan', 'Vegetarian', 'Healthy'],
      storeRating: 4.7,
      totalRatings: 110,
      isApproved: true,
      isFeatured: true,
      deliveryTime: '40-55 min',
      minimumOrder: 24,
      deliveryFee: 5
    },
    {
      storeName: 'Dessert Heaven',
      storeDescription: 'Gourmet desserts and sweet treats',
      storeImage: 'https://images.unsplash.com/photo-1565958011703-44f9829ba187',
      storeAddress: '444 Sweet Street, Astoria',
      storePhone: '+1234567903',
      storeEmail: 'dessertheaven@example.com',
      storeCoordinates: {
        type: 'Point',
        coordinates: [-73.921906, 40.764501] // Queens Astoria
      },
      categories: ['Desserts', 'Bakery', 'Sweet Treats'],
      storeRating: 4.9,
      totalRatings: 95,
      isApproved: true,
      isFeatured: false,
      deliveryTime: '25-35 min',
      minimumOrder: 15,
      deliveryFee: 3
    },
    {
      storeName: 'Seafood Harbor',
      storeDescription: 'Fresh seafood and coastal cuisine',
      storeImage: 'https://images.unsplash.com/photo-1559339352-11d035aa65de',
      storeAddress: '555 Harbor Street, Battery Park',
      storePhone: '+1234567904',
      storeEmail: 'seafoodharbor@example.com',
      storeCoordinates: {
        type: 'Point',
        coordinates: [-74.015941, 40.703312] // New York Battery Park
      },
      categories: ['Seafood', 'Coastal', 'Fresh Fish'],
      storeRating: 4.6,
      totalRatings: 155,
      isApproved: true,
      isFeatured: true,
      deliveryTime: '50-65 min',
      minimumOrder: 40,
      deliveryFee: 9
    }
  ];

  try {
    await this.deleteMany({});
    await this.insertMany(vendors);
    console.log('✅ Vendors seeded successfully');
  } catch (error) {
    console.error('❌ Error seeding vendors:', error);
    throw error;
  }
};

module.exports = mongoose.model('Vendor', vendorSchema); 