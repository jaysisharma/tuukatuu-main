const mongoose = require('mongoose');

const categorySchema = new mongoose.Schema({
  name: { 
    type: String, 
    required: true, 
    unique: true,
    trim: true 
  },
  displayName: { 
    type: String, 
    required: false,
    trim: true 
  },
  description: { 
    type: String,
    default: '' 
  },
  imageUrl: { 
    type: String,
    default: '' 
  },
  iconUrl: { 
    type: String,
    default: '' 
  },
  color: { 
    type: String,
    default: 'green',
    enum: ['green', 'blue', 'orange', 'red', 'purple', 'cyan', 'indigo', 'pink', 'teal', 'amber', 'deepPurple', 'lightBlue', 'yellow', 'brown']
  },
  isActive: { 
    type: Boolean, 
    default: true 
  },
  isFeatured: { 
    type: Boolean, 
    default: false 
  },
  sortOrder: { 
    type: Number, 
    default: 0 
  },
  parentCategory: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'Category',
    default: null 
  },
  childCategories: [{ 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'Category' 
  }],
  combinedCategories: [{ 
    type: String 
  }], // Array of individual category names that this combined category represents
  productCount: { 
    type: Number, 
    default: 0 
  },
  createdBy: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'User',
    required: false 
  },
  updatedBy: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'User' 
  },
  metadata: {
    seoTitle: { type: String },
    seoDescription: { type: String },
    keywords: [{ type: String }]
  }
}, { 
  timestamps: true 
});

// Indexes for better performance
categorySchema.index({ name: 1 });
categorySchema.index({ isActive: 1 });
categorySchema.index({ isFeatured: 1 });
categorySchema.index({ sortOrder: 1 });
categorySchema.index({ parentCategory: 1 });

// Virtual for full category path
categorySchema.virtual('fullPath').get(function() {
  if (this.parentCategory) {
    return `${this.parentCategory.name} > ${this.name}`;
  }
  return this.name;
});

// Pre-save middleware to update displayName if not provided
categorySchema.pre('save', function(next) {
  if (!this.displayName) {
    this.displayName = this.name;
  }
  next();
});

// Pre-find middleware to ensure displayName exists
categorySchema.pre('find', function() {
  // This will be handled by the pre-save middleware for new documents
});

categorySchema.pre('findOne', function() {
  // This will be handled by the pre-save middleware for new documents
});

// Static method to find or create category
categorySchema.statics.findOrCreate = async function(categoryData, userId) {
  try {
    let category = await this.findOne({ 
      name: { $regex: new RegExp(`^${categoryData.name}$`, 'i') } 
    });
    
    if (!category) {
      category = new this({
        ...categoryData,
        createdBy: userId
      });
      await category.save();
    }
    
    return category;
  } catch (error) {
    throw error;
  }
};

// Static method to create combined categories
categorySchema.statics.createCombinedCategory = async function(combinedCategoryData, userId) {
  try {
    console.log('📝 Creating combined category in model:', combinedCategoryData);
    
    const { name, displayName, description, color, combinedCategories, imageUrl } = combinedCategoryData;
    
    // Check if combined category already exists
    const existingCategory = await this.findOne({
      name: { $regex: new RegExp(`^${name}$`, 'i') }
    });
    
    if (existingCategory) {
      throw new Error('Combined category with this name already exists');
    }
    
    // Create new combined category
    const combinedCategory = new this({
      name,
      displayName,
      description,
      color,
      combinedCategories,
      imageUrl: imageUrl || '',
      isActive: true,
      isFeatured: false,
      createdBy: userId
    });
    
    console.log('📝 Saving combined category:', combinedCategory);
    await combinedCategory.save();
    
    // Calculate product count from all combined categories
    const Product = require('./Product');
    const productCount = await Product.countDocuments({
      category: { $in: combinedCategories }
    });
    
    console.log(`📊 Found ${productCount} products for combined category`);
    combinedCategory.productCount = productCount;
    await combinedCategory.save();
    
    console.log('✅ Combined category created successfully:', combinedCategory.name);
    return combinedCategory;
  } catch (error) {
    console.error('❌ Error in createCombinedCategory:', error);
    throw error;
  }
};

// Instance method to update product count
categorySchema.methods.updateProductCount = async function() {
  const Product = require('./Product');
  
  if (this.combinedCategories && this.combinedCategories.length > 0) {
    // For combined categories, count products from all combined categories
    this.productCount = await Product.countDocuments({
      category: { $in: this.combinedCategories }
    });
  } else {
    // For regular categories, count products with exact category match
    this.productCount = await Product.countDocuments({ category: this.name });
  }
  
  return this.save();
};

// Static method to get featured categories
categorySchema.statics.getFeatured = async function(limit = 8) {
  const categories = await this.find({ 
    isActive: true, 
    isFeatured: true 
  })
  .sort({ sortOrder: 1, name: 1 })
  .limit(limit)
  .lean();
  
  // Ensure displayName exists and calculate product counts
  const Product = require('./Product');
  const result = [];
  
  for (let cat of categories) {
    const category = {
      ...cat,
      displayName: cat.displayName || cat.name
    };
    
    // Calculate product count
    if (category.combinedCategories && category.combinedCategories.length > 0) {
      category.productCount = await Product.countDocuments({
        category: { $in: category.combinedCategories }
      });
    } else {
      category.productCount = await Product.countDocuments({ category: category.name });
    }
    
    result.push(category);
  }
  
  return result;
};

// Static method to get all active categories
categorySchema.statics.getAllActive = async function() {
  const categories = await this.find({ isActive: true })
  .sort({ sortOrder: 1, name: 1 })
  .lean();
  
  // Ensure displayName exists and calculate product counts
  const Product = require('./Product');
  const result = [];
  
  for (let cat of categories) {
    const category = {
      ...cat,
      displayName: cat.displayName || cat.name
    };
    
    // Calculate product count
    if (category.combinedCategories && category.combinedCategories.length > 0) {
      category.productCount = await Product.countDocuments({
        category: { $in: category.combinedCategories }
      });
    } else {
      category.productCount = await Product.countDocuments({ category: category.name });
    }
    
    result.push(category);
  }
  
  return result;
};

// Static method to get category hierarchy
categorySchema.statics.getHierarchy = async function() {
  const categories = await this.find({ isActive: true })
    .populate('parentCategory')
    .populate('childCategories')
    .sort({ sortOrder: 1, name: 1 });
  
  const rootCategories = categories.filter(cat => !cat.parentCategory);
  
  return rootCategories;
};

module.exports = mongoose.model('Category', categorySchema);
