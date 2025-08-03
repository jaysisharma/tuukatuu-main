const Joi = require('joi');

exports.validateBody = (schema, body) => {
  // TODO: Implement validation logic (e.g., using Joi or custom)
  return { valid: true, errors: [] };
};

// Rider profile validation
exports.validateRiderProfile = (req, res, next) => {
  const schema = Joi.object({
    profile: Joi.object({
      fullName: Joi.string().min(2).max(50).required(),
      email: Joi.string().email().required(),
      phone: Joi.string().pattern(/^[0-9]{10}$/).required(),
      profileImage: Joi.string().uri().optional(),
      dateOfBirth: Joi.date().max('now').optional(),
      gender: Joi.string().valid('male', 'female', 'other').optional(),
      emergencyContact: Joi.object({
        name: Joi.string().min(2).max(50).required(),
        phone: Joi.string().pattern(/^[0-9]{10}$/).required(),
        relationship: Joi.string().min(2).max(20).required()
      }).optional()
    }).required(),
    
    vehicle: Joi.object({
      type: Joi.string().valid('bike', 'scooter', 'car', 'bicycle').required(),
      brand: Joi.string().min(2).max(30).optional(),
      model: Joi.string().min(2).max(30).optional(),
      year: Joi.number().integer().min(1990).max(new Date().getFullYear()).optional(),
      color: Joi.string().min(2).max(20).optional(),
      licensePlate: Joi.string().pattern(/^[A-Z]{2}[0-9]{1,2}[A-Z]{1,2}[0-9]{4}$/).optional(),
      insuranceNumber: Joi.string().optional(),
      registrationNumber: Joi.string().optional()
    }).required(),
    
    documents: Joi.object({
      drivingLicense: Joi.object({
        number: Joi.string().pattern(/^[A-Z]{2}[0-9]{13}$/).required(),
        expiryDate: Joi.date().min('now').required(),
        image: Joi.string().uri().optional()
      }).required(),
      vehicleRegistration: Joi.object({
        number: Joi.string().optional(),
        expiryDate: Joi.date().min('now').optional(),
        image: Joi.string().uri().optional()
      }).optional(),
      insurance: Joi.object({
        number: Joi.string().optional(),
        expiryDate: Joi.date().min('now').optional(),
        image: Joi.string().uri().optional()
      }).optional(),
      addressProof: Joi.object({
        type: Joi.string().valid('aadhar', 'pan', 'passport', 'driving_license').optional(),
        number: Joi.string().optional(),
        image: Joi.string().uri().optional()
      }).optional()
    }).required(),
    
    workPreferences: Joi.object({
      isAvailable: Joi.boolean().default(false),
      workingHours: Joi.object({
        start: Joi.string().pattern(/^([01]?[0-9]|2[0-3]):[0-5][0-9]$/).default('09:00'),
        end: Joi.string().pattern(/^([01]?[0-9]|2[0-3]):[0-5][0-9]$/).default('18:00')
      }).optional(),
      preferredAreas: Joi.array().items(Joi.string().min(2).max(50)).max(10).optional(),
      maxDistance: Joi.number().min(1).max(50).default(10),
      vehicleCapacity: Joi.number().min(1).max(10).default(5)
    }).optional(),
    
    bankDetails: Joi.object({
      accountHolderName: Joi.string().min(2).max(50).optional(),
      accountNumber: Joi.string().pattern(/^[0-9]{9,18}$/).optional(),
      ifscCode: Joi.string().pattern(/^[A-Z]{4}0[A-Z0-9]{6}$/).optional(),
      bankName: Joi.string().min(2).max(50).optional(),
      branch: Joi.string().min(2).max(50).optional()
    }).optional()
  });

  const { error } = schema.validate(req.body);
  if (error) {
    return res.status(400).json({
      message: 'Validation error',
      errors: error.details.map(detail => detail.message)
    });
  }
  next();
};

// Location validation
exports.validateLocation = (req, res, next) => {
  const schema = Joi.object({
    latitude: Joi.number().min(-90).max(90).required(),
    longitude: Joi.number().min(-180).max(180).required(),
    address: Joi.string().min(5).max(200).optional()
  });

  const { error } = schema.validate(req.body);
  if (error) {
    return res.status(400).json({
      message: 'Validation error',
      errors: error.details.map(detail => detail.message)
    });
  }
  next();
};

// Order status validation
exports.validateOrderStatus = (req, res, next) => {
  const schema = Joi.object({
    orderId: Joi.string().required(),
    status: Joi.string().valid('picked_up', 'on_the_way', 'delivered').required()
  });

  const { error } = schema.validate(req.body);
  if (error) {
    return res.status(400).json({
      message: 'Validation error',
      errors: error.details.map(detail => detail.message)
    });
  }
  next();
};

// Status update validation
exports.validateStatusUpdate = (req, res, next) => {
  const schema = Joi.object({
    status: Joi.string().valid('offline', 'online', 'busy', 'on_delivery').required()
  });

  const { error } = schema.validate(req.body);
  if (error) {
    return res.status(400).json({
      message: 'Validation error',
      errors: error.details.map(detail => detail.message)
    });
  }
  next();
};

// Earnings period validation
exports.validateEarningsPeriod = (req, res, next) => {
  const schema = Joi.object({
    period: Joi.string().valid('today', 'week', 'month', 'all').default('all'),
    startDate: Joi.date().optional(),
    endDate: Joi.date().optional()
  });

  const { error } = schema.validate(req.query);
  if (error) {
    return res.status(400).json({
      message: 'Validation error',
      errors: error.details.map(detail => detail.message)
    });
  }
  next();
};

// Admin approval validation
exports.validateRiderApproval = (req, res, next) => {
  const schema = Joi.object({
    isApproved: Joi.boolean().required(),
    rejectionReason: Joi.string().min(10).max(500).when('isApproved', {
      is: false,
      then: Joi.required(),
      otherwise: Joi.optional()
    })
  });

  const { error } = schema.validate(req.body);
  if (error) {
    return res.status(400).json({
      message: 'Validation error',
      errors: error.details.map(detail => detail.message)
    });
  }
  next();
}; 