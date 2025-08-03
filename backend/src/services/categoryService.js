const Category = require('../models/Category');
const Product = require('../models/Product');
const { uploadToCloudinary } = require('../utils/cloudinary');

class CategoryService {
  // Get all categories with pagination and filters
  static async getAllCategories(filters = {}, pagination = {}) {
    try {
      const { page = 1, limit = 20, search, isActive, isFeatured } = filters;
      const query = {};
      
      // Apply filters
      if (search) {
        query.$or = [
          { name: { $regex: search, $options: 'i' } },
          { displayName: { $regex: search, $options: 'i' } },
          { description: { $regex: search, $options: 'i' } }
        ];
      }
      
      if (isActive !== undefined) {
        query.isActive = isActive;
      }
      
      if (isFeatured !== undefined) {
        query.isFeatured = isFeatured;
      }
      
      const skip = (page - 1) * limit;
      
      const categories = await Category.find(query)
        .populate('createdBy', 'name email')
        .populate('updatedBy', 'name email')
        .populate('parentCategory', 'name displayName')
        .sort({ sortOrder: 1, name: 1 })
        .skip(skip)
        .limit(limit)
        .lean(); // Use lean() to get plain objects instead of mongoose documents
      
      // Ensure displayName exists and calculate product counts for all categories
      const Product = require('../models/Product');
      for (let category of categories) {
        if (!category.displayName) {
          category.displayName = category.name;
        }
        
        // Calculate product count
        if (category.combinedCategories && category.combinedCategories.length > 0) {
          category.productCount = await Product.countDocuments({
            category: { $in: category.combinedCategories }
          });
        } else {
          category.productCount = await Product.countDocuments({ category: category.name });
        }
      }
      
      const total = await Category.countDocuments(query);
      
      return {
        success: true,
        data: categories,
        pagination: {
          page,
          limit,
          total,
          pages: Math.ceil(total / limit)
        }
      };
    } catch (error) {
      throw error;
    }
  }

  // Get featured categories
  static async getFeaturedCategories(limit = 8) {
    try {
      const categories = await Category.getFeatured(limit);
      return {
        success: true,
        data: categories,
        total: categories.length
      };
    } catch (error) {
      throw error;
    }
  }

  // Get category by ID
  static async getCategoryById(categoryId) {
    try {
      const category = await Category.findById(categoryId)
        .populate('createdBy', 'name email')
        .populate('updatedBy', 'name email')
        .populate('parentCategory', 'name displayName')
        .populate('childCategories', 'name displayName');
      
      if (!category) {
        throw new Error('Category not found');
      }
      
      return {
        success: true,
        data: category
      };
    } catch (error) {
      throw error;
    }
  }

  // Create new category
  static async createCategory(categoryData, userId) {
    try {
      // Check if category with same name already exists
      const existingCategory = await Category.findOne({
        name: { $regex: new RegExp(`^${categoryData.name}$`, 'i') }
      });
      
      if (existingCategory) {
        throw new Error('Category with this name already exists');
      }
      
      const category = new Category({
        ...categoryData,
        createdBy: userId
      });
      
      await category.save();
      
      // Update product count
      await category.updateProductCount();
      
      return {
        success: true,
        data: category,
        message: 'Category created successfully'
      };
    } catch (error) {
      throw error;
    }
  }

  // Update category
  static async updateCategory(categoryId, updateData, userId) {
    try {
      const category = await Category.findById(categoryId);
      
      if (!category) {
        throw new Error('Category not found');
      }
      
      // Check if name is being changed and if it conflicts with existing category
      if (updateData.name && updateData.name !== category.name) {
        const existingCategory = await Category.findOne({
          name: { $regex: new RegExp(`^${updateData.name}$`, 'i') },
          _id: { $ne: categoryId }
        });
        
        if (existingCategory) {
          throw new Error('Category with this name already exists');
        }
      }
      
      // Update category
      Object.assign(category, updateData, { updatedBy: userId });
      await category.save();
      
      // Update product count
      await category.updateProductCount();
      
      return {
        success: true,
        data: category,
        message: 'Category updated successfully'
      };
    } catch (error) {
      throw error;
    }
  }

  // Delete category (soft delete)
  static async deleteCategory(categoryId, userId) {
    try {
      const category = await Category.findById(categoryId);
      
      if (!category) {
        throw new Error('Category not found');
      }
      
      // Check if category has products
      const productCount = await Product.countDocuments({ category: category.name });
      if (productCount > 0) {
        throw new Error(`Cannot delete category. It has ${productCount} products associated with it.`);
      }
      
      // Soft delete
      category.isActive = false;
      category.updatedBy = userId;
      await category.save();
      
      return {
        success: true,
        message: 'Category deleted successfully'
      };
    } catch (error) {
      throw error;
    }
  }

  // Create combined category
  static async createCombinedCategory(combinedCategoryData, userId) {
    try {
      console.log('📝 Creating combined category in service:', combinedCategoryData);
      
      const { name, displayName, description, color, combinedCategories, imageUrl } = combinedCategoryData;
      
      const categoryData = {
        name,
        displayName: displayName || name,
        description,
        color,
        combinedCategories,
        imageUrl,
        isActive: true,
        isFeatured: false,
        createdBy: userId
      };
      
      console.log('📝 Final category data:', categoryData);
      
      const combinedCategory = await Category.createCombinedCategory(categoryData, userId);
      
      console.log('✅ Combined category created:', combinedCategory);
      
      return {
        success: true,
        data: combinedCategory,
        message: `Successfully created combined category "${combinedCategory.name}"`
      };
    } catch (error) {
      console.error('❌ Error creating combined category:', error);
      throw error;
    }
  }

  // Upload image (for new categories)
  static async uploadImage(imageFile) {
    try {
      console.log('📁 Uploading image to Cloudinary:', imageFile.originalname);
      
      // Check if Cloudinary is configured
      if (!process.env.CLOUDINARY_CLOUD_NAME) {
        console.log('⚠️ Cloudinary not configured, using placeholder image');
        return {
          success: true,
          data: {
            imageUrl: 'https://via.placeholder.com/400x400?text=Category+Image',
            publicId: null
          },
          message: 'Image upload skipped (Cloudinary not configured)'
        };
      }
      
      // Upload image to Cloudinary
      const uploadResult = await uploadToCloudinary(imageFile, 'categories');
      
      console.log('✅ Image uploaded successfully:', uploadResult.secure_url);
      
      return {
        success: true,
        data: {
          imageUrl: uploadResult.secure_url,
          publicId: uploadResult.public_id
        },
        message: 'Image uploaded successfully'
      };
    } catch (error) {
      console.error('❌ Error uploading image:', error);
      
      // Fallback to placeholder image
      console.log('⚠️ Using fallback placeholder image');
      return {
        success: true,
        data: {
          imageUrl: 'https://via.placeholder.com/400x400?text=Category+Image',
          publicId: null
        },
        message: 'Image upload failed, using placeholder'
      };
    }
  }

  // Upload category image
  static async uploadCategoryImage(categoryId, imageFile, userId) {
    try {
      const category = await Category.findById(categoryId);
      
      if (!category) {
        throw new Error('Category not found');
      }
      
      // Upload image to Cloudinary
      const uploadResult = await uploadToCloudinary(imageFile, 'categories');
      
      // Update category with new image URL
      category.imageUrl = uploadResult.secure_url;
      category.updatedBy = userId;
      await category.save();
      
      return {
        success: true,
        data: {
          imageUrl: uploadResult.secure_url,
          publicId: uploadResult.public_id
        },
        message: 'Category image uploaded successfully'
      };
    } catch (error) {
      throw error;
    }
  }

  // Toggle featured status
  static async toggleFeatured(categoryId, userId) {
    try {
      const category = await Category.findById(categoryId);
      
      if (!category) {
        throw new Error('Category not found');
      }
      
      category.isFeatured = !category.isFeatured;
      category.updatedBy = userId;
      await category.save();
      
      return {
        success: true,
        data: category,
        message: `Category ${category.isFeatured ? 'marked as' : 'removed from'} featured`
      };
    } catch (error) {
      throw error;
    }
  }

  // Update sort order
  static async updateSortOrder(categoryId, sortOrder, userId) {
    try {
      const category = await Category.findById(categoryId);
      
      if (!category) {
        throw new Error('Category not found');
      }
      
      category.sortOrder = sortOrder;
      category.updatedBy = userId;
      await category.save();
      
      return {
        success: true,
        data: category,
        message: 'Category sort order updated successfully'
      };
    } catch (error) {
      throw error;
    }
  }

  // Get category statistics
  static async getCategoryStats() {
    try {
      const stats = await Category.aggregate([
        {
          $group: {
            _id: null,
            totalCategories: { $sum: 1 },
            activeCategories: {
              $sum: { $cond: ['$isActive', 1, 0] }
            },
            featuredCategories: {
              $sum: { $cond: ['$isFeatured', 1, 0] }
            },
            totalProducts: { $sum: '$productCount' }
          }
        }
      ]);
      
      return {
        success: true,
        data: stats[0] || {
          totalCategories: 0,
          activeCategories: 0,
          featuredCategories: 0,
          totalProducts: 0
        }
      };
    } catch (error) {
      throw error;
    }
  }

  // Auto-create category from product
  static async autoCreateFromProduct(productData, userId) {
    try {
      if (!productData.category) {
        throw new Error('Product category is required');
      }
      
      const categoryData = {
        name: productData.category,
        displayName: productData.category,
        description: `Auto-generated category for ${productData.category}`,
        isActive: true,
        isFeatured: false
      };
      
      const category = await Category.findOrCreate(categoryData, userId);
      
      return category;
    } catch (error) {
      throw error;
    }
  }

  // Get category hierarchy
  static async getCategoryHierarchy() {
    try {
      const categories = await Category.getHierarchy();
      
      return {
        success: true,
        data: categories
      };
    } catch (error) {
      throw error;
    }
  }

  // Bulk update categories
  static async bulkUpdateCategories(updates, userId) {
    try {
      const results = [];
      
      for (const update of updates) {
        try {
          const result = await this.updateCategory(update.id, update.data, userId);
          results.push({ id: update.id, success: true, data: result.data });
        } catch (error) {
          results.push({ id: update.id, success: false, error: error.message });
        }
      }
      
      return {
        success: true,
        data: results,
        message: `Processed ${results.length} category updates`
      };
    } catch (error) {
      throw error;
    }
  }
}

module.exports = CategoryService; 