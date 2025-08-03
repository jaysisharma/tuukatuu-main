const CategoryService = require('../services/categoryService');
const { validateCategoryData } = require('../utils/validation');

// Get all categories with pagination and filters
exports.getAllCategories = async (req, res) => {
  try {
    const { page, limit, search, isActive, isFeatured } = req.query;
    
    const filters = {
      search,
      isActive: isActive === 'true' ? true : isActive === 'false' ? false : undefined,
      isFeatured: isFeatured === 'true' ? true : isFeatured === 'false' ? false : undefined
    };
    
    const pagination = { page: parseInt(page) || 1, limit: parseInt(limit) || 20 };
    
    const result = await CategoryService.getAllCategories(filters, pagination);
    
    res.json(result);
  } catch (error) {
    console.error('❌ Error in getAllCategories:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// Get featured categories
exports.getFeaturedCategories = async (req, res) => {
  try {
    const { limit } = req.query;
    const result = await CategoryService.getFeaturedCategories(parseInt(limit) || 8);
    
    res.json(result);
  } catch (error) {
    console.error('❌ Error in getFeaturedCategories:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// Get category by ID
exports.getCategoryById = async (req, res) => {
  try {
    const { categoryId } = req.params;
    const result = await CategoryService.getCategoryById(categoryId);
    
    res.json(result);
  } catch (error) {
    console.error('❌ Error in getCategoryById:', error);
    res.status(404).json({
      success: false,
      message: error.message
    });
  }
};

// Create new category
exports.createCategory = async (req, res) => {
  try {
    const categoryData = req.body;
    const userId = req.user.id;
    
    // Validate category data
    const validation = validateCategoryData(categoryData);
    if (!validation.isValid) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: validation.errors
      });
    }
    
    const result = await CategoryService.createCategory(categoryData, userId);
    
    res.status(201).json(result);
  } catch (error) {
    console.error('❌ Error in createCategory:', error);
    res.status(400).json({
      success: false,
      message: error.message
    });
  }
};

// Update category
exports.updateCategory = async (req, res) => {
  try {
    const { categoryId } = req.params;
    const updateData = req.body;
    const userId = req.user.id;
    
    // Validate update data
    const validation = validateCategoryData(updateData, true);
    if (!validation.isValid) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: validation.errors
      });
    }
    
    const result = await CategoryService.updateCategory(categoryId, updateData, userId);
    
    res.json(result);
  } catch (error) {
    console.error('❌ Error in updateCategory:', error);
    res.status(400).json({
      success: false,
      message: error.message
    });
  }
};

// Delete category
exports.deleteCategory = async (req, res) => {
  try {
    const { categoryId } = req.params;
    const userId = req.user.id;
    
    const result = await CategoryService.deleteCategory(categoryId, userId);
    
    res.json(result);
  } catch (error) {
    console.error('❌ Error in deleteCategory:', error);
    res.status(400).json({
      success: false,
      message: error.message
    });
  }
};

// Create combined category
exports.createCombinedCategory = async (req, res) => {
  try {
    console.log('📝 Creating combined category:', req.body);
    
    const { name, displayName, description, color, combinedCategories, imageUrl } = req.body;
    const userId = req.user.id;
    
    if (!name) {
      return res.status(400).json({
        success: false,
        message: 'Name is required'
      });
    }
    
    if (!combinedCategories || !Array.isArray(combinedCategories) || combinedCategories.length < 2) {
      return res.status(400).json({
        success: false,
        message: 'At least 2 individual categories are required for combined category'
      });
    }
    
    // Validate color
    const validColors = ['green', 'blue', 'orange', 'red', 'purple', 'cyan', 'indigo', 'pink', 'teal', 'amber', 'deepPurple', 'lightBlue', 'yellow', 'brown'];
    if (color && !validColors.includes(color)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid color value'
      });
    }
    
    const combinedCategoryData = {
      name: name.trim(),
      displayName: displayName ? displayName.trim() : name.trim(),
      description: description ? description.trim() : '',
      color: color || 'green',
      combinedCategories,
      imageUrl: imageUrl || ''
    };
    
    console.log('📝 Processed category data:', combinedCategoryData);
    
    const result = await CategoryService.createCombinedCategory(combinedCategoryData, userId);
    
    res.json(result);
  } catch (error) {
    console.error('❌ Error in createCombinedCategory:', error);
    
    // Handle specific error cases
    if (error.message.includes('already exists')) {
      res.status(409).json({
        success: false,
        message: 'A category with this name already exists. Please choose a different name.'
      });
    } else {
      res.status(500).json({
        success: false,
        message: error.message || 'Failed to create combined category'
      });
    }
  }
};

// Upload image (for new categories)
exports.uploadImage = async (req, res) => {
  try {
    console.log('📁 Upload request received:', req.file);
    
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'Image file is required'
      });
    }
    

    
    const result = await CategoryService.uploadImage(req.file);
    
    res.json(result);
  } catch (error) {
    console.error('❌ Error in uploadImage:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to upload image'
    });
  }
};

// Upload category image
exports.uploadCategoryImage = async (req, res) => {
  try {
    const { categoryId } = req.params;
    const userId = req.user.id;
    
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'Image file is required'
      });
    }
    
    const result = await CategoryService.uploadCategoryImage(categoryId, req.file, userId);
    
    res.json(result);
  } catch (error) {
    console.error('❌ Error in uploadCategoryImage:', error);
    res.status(400).json({
      success: false,
      message: error.message
    });
  }
};

// Toggle featured status
exports.toggleFeatured = async (req, res) => {
  try {
    const { categoryId } = req.params;
    const userId = req.user.id;
    
    const result = await CategoryService.toggleFeatured(categoryId, userId);
    
    res.json(result);
  } catch (error) {
    console.error('❌ Error in toggleFeatured:', error);
    res.status(400).json({
      success: false,
      message: error.message
    });
  }
};

// Update sort order
exports.updateSortOrder = async (req, res) => {
  try {
    const { categoryId } = req.params;
    const { sortOrder } = req.body;
    const userId = req.user.id;
    
    if (typeof sortOrder !== 'number') {
      return res.status(400).json({
        success: false,
        message: 'Sort order must be a number'
      });
    }
    
    const result = await CategoryService.updateSortOrder(categoryId, sortOrder, userId);
    
    res.json(result);
  } catch (error) {
    console.error('❌ Error in updateSortOrder:', error);
    res.status(400).json({
      success: false,
      message: error.message
    });
  }
};

// Get category statistics
exports.getCategoryStats = async (req, res) => {
  try {
    const result = await CategoryService.getCategoryStats();
    
    res.json(result);
  } catch (error) {
    console.error('❌ Error in getCategoryStats:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// Get category hierarchy
exports.getCategoryHierarchy = async (req, res) => {
  try {
    const result = await CategoryService.getCategoryHierarchy();
    
    res.json(result);
  } catch (error) {
    console.error('❌ Error in getCategoryHierarchy:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// Bulk update categories
exports.bulkUpdateCategories = async (req, res) => {
  try {
    const { updates } = req.body;
    const userId = req.user.id;
    
    if (!updates || !Array.isArray(updates)) {
      return res.status(400).json({
        success: false,
        message: 'Updates array is required'
      });
    }
    
    const result = await CategoryService.bulkUpdateCategories(updates, userId);
    
    res.json(result);
  } catch (error) {
    console.error('❌ Error in bulkUpdateCategories:', error);
    res.status(400).json({
      success: false,
      message: error.message
    });
  }
};

// Auto-create category from product
exports.autoCreateFromProduct = async (req, res) => {
  try {
    const productData = req.body;
    const userId = req.user.id;
    
    const result = await CategoryService.autoCreateFromProduct(productData, userId);
    
    res.json({
      success: true,
      data: result,
      message: 'Category auto-created successfully'
    });
  } catch (error) {
    console.error('❌ Error in autoCreateFromProduct:', error);
    res.status(400).json({
      success: false,
      message: error.message
    });
  }
}; 