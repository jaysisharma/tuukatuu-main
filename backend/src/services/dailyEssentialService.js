const DailyEssential = require('../models/DailyEssential');
const Category = require('../models/Category');
const TMartProduct = require('../models/TMartProduct');

class DailyEssentialService {
  // Get all daily essentials
  static async getAllEssentials(page = 1, limit = 20) {
    try {
      const skip = (page - 1) * limit;
      
      const essentials = await DailyEssential.find()
        .populate('categoryId', 'name displayName imageUrl color combinedCategories')
        .populate('productId', 'name price imageUrl category brand isAvailable')
        .populate('createdBy', 'name email')
        .populate('updatedBy', 'name email')
        .sort({ sortOrder: 1, priority: 1, createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .lean();

      const total = await DailyEssential.countDocuments();
      const totalPages = Math.ceil(total / limit);

      const result = [];

      for (let essential of essentials) {
        if (essential.type === 'category' && essential.categoryId) {
          const category = essential.categoryId;
          let productCount = 0;
          
          if (category.combinedCategories && category.combinedCategories.length > 0) {
            productCount = await TMartProduct.countDocuments({
              category: { $in: category.combinedCategories }
            });
          } else {
            productCount = await TMartProduct.countDocuments({ category: category.name });
          }

          result.push({
            ...essential,
            category: category,
            productCount: productCount
          });
        } else if (essential.type === 'product' && essential.productId) {
          const product = essential.productId;
          result.push({
            ...essential,
            product: product,
            productCount: 1
          });
        }
      }

      return {
        success: true,
        data: result,
        pagination: {
          page,
          limit,
          total,
          totalPages
        }
      };
    } catch (error) {
      throw error;
    }
  }

  // Get active daily essentials (for public API)
  static async getActiveEssentials() {
    try {
      const essentials = await DailyEssential.getEssentialsWithProductCount();
      
      return {
        success: true,
        data: essentials
      };
    } catch (error) {
      throw error;
    }
  }

  // Get daily essentials by priority
  static async getByPriority(priority) {
    try {
      const essentials = await DailyEssential.getByPriority(priority);
      
      return {
        success: true,
        data: essentials
      };
    } catch (error) {
      throw error;
    }
  }

  // Add category or product as daily essential
  static async addEssential(essentialData, userId) {
    try {
      const { categoryId, productId, description, priority, tags, color, type } = essentialData;

      if (type === 'category') {
        // Check if category exists
        const category = await Category.findById(categoryId);
        if (!category) {
          throw new Error('Category not found');
        }

        // Check if category is already a daily essential
        const existingEssential = await DailyEssential.findOne({
          categoryId: categoryId,
          isActive: true
        });

        if (existingEssential) {
          throw new Error('Category is already marked as a daily essential');
        }

        // Create new daily essential
        const dailyEssential = new DailyEssential({
          categoryId,
          name: category.name,
          displayName: category.displayName || category.name,
          description: description || '',
          imageUrl: category.imageUrl || '',
          color: color || category.color || 'green',
          priority: priority || 'medium',
          type: 'category',
          tags: tags || [],
          createdBy: userId
        });

        await dailyEssential.save();

        return {
          success: true,
          data: dailyEssential,
          message: `"${category.displayName || category.name}" added as daily essential`
        };
      } else if (type === 'product') {
        // Check if product exists
        const product = await TMartProduct.findById(productId);
        if (!product) {
          throw new Error('Product not found');
        }

        // Check if product is already a daily essential
        const existingEssential = await DailyEssential.findOne({
          productId: productId,
          isActive: true
        });

        if (existingEssential) {
          throw new Error('Product is already marked as a daily essential');
        }

        // Create new daily essential
        const dailyEssential = new DailyEssential({
          productId,
          name: product.name,
          displayName: product.name,
          description: description || '',
          imageUrl: product.imageUrl || '',
          color: color || 'green',
          priority: priority || 'medium',
          type: 'product',
          tags: tags || [],
          createdBy: userId
        });

        await dailyEssential.save();

        return {
          success: true,
          data: dailyEssential,
          message: `"${product.name}" added as daily essential`
        };
      } else {
        throw new Error('Invalid type. Must be either "category" or "product"');
      }
    } catch (error) {
      throw error;
    }
  }

  // Update daily essential
  static async updateEssential(essentialId, updateData, userId) {
    try {
      const essential = await DailyEssential.findById(essentialId);
      if (!essential) {
        throw new Error('Daily essential not found');
      }

      // Update fields
      const allowedFields = ['description', 'priority', 'tags', 'color', 'sortOrder', 'isActive'];
      for (const field of allowedFields) {
        if (updateData[field] !== undefined) {
          essential[field] = updateData[field];
        }
      }

      essential.updatedBy = userId;
      essential.metadata = {
        ...essential.metadata,
        lastUpdated: new Date(),
        updateReason: updateData.updateReason || '',
        notes: updateData.notes || ''
      };

      await essential.save();

      return {
        success: true,
        data: essential,
        message: 'Daily essential updated successfully'
      };
    } catch (error) {
      throw error;
    }
  }

  // Remove category from daily essentials
  static async removeEssential(essentialId, userId) {
    try {
      const essential = await DailyEssential.findById(essentialId);
      if (!essential) {
        throw new Error('Daily essential not found');
      }

      // Soft delete by setting isActive to false
      essential.isActive = false;
      essential.updatedBy = userId;
      essential.metadata = {
        ...essential.metadata,
        lastUpdated: new Date(),
        updateReason: 'Removed from daily essentials',
        notes: 'Category removed from daily essentials'
      };

      await essential.save();

      return {
        success: true,
        message: `"${essential.displayName}" removed from daily essentials`
      };
    } catch (error) {
      throw error;
    }
  }

  // Bulk update daily essentials
  static async bulkUpdateEssentials(updates, userId) {
    try {
      const results = [];
      
      for (const update of updates) {
        try {
          const result = await this.updateEssential(update.essentialId, update.data, userId);
          results.push({ ...result, essentialId: update.essentialId });
        } catch (error) {
          results.push({ 
            success: false, 
            essentialId: update.essentialId, 
            error: error.message 
          });
        }
      }

      return {
        success: true,
        data: results,
        message: 'Bulk update completed'
      };
    } catch (error) {
      throw error;
    }
  }

  // Get daily essentials statistics
  static async getStats() {
    try {
      const totalEssentials = await DailyEssential.countDocuments();
      const activeEssentials = await DailyEssential.countDocuments({ isActive: true });
      const highPriority = await DailyEssential.countDocuments({ 
        isActive: true, 
        priority: 'high' 
      });
      const mediumPriority = await DailyEssential.countDocuments({ 
        isActive: true, 
        priority: 'medium' 
      });
      const lowPriority = await DailyEssential.countDocuments({ 
        isActive: true, 
        priority: 'low' 
      });

      return {
        success: true,
        data: {
          totalEssentials,
          activeEssentials,
          highPriority,
          mediumPriority,
          lowPriority
        }
      };
    } catch (error) {
      throw error;
    }
  }

  // Get available categories (not yet marked as essentials)
  static async getAvailableCategories() {
    try {
      const essentialCategoryIds = await DailyEssential.distinct('categoryId', { isActive: true });
      
      const availableCategories = await Category.find({
        _id: { $nin: essentialCategoryIds },
        isActive: true
      })
      .sort({ name: 1 })
      .lean();

      return {
        success: true,
        data: availableCategories
      };
    } catch (error) {
      throw error;
    }
  }

  // Get available products (not yet marked as essentials)
  static async getAvailableProducts(page = 1, limit = 50) {
    try {
      const essentialProductIds = await DailyEssential.distinct('productId', { isActive: true });
      const skip = (page - 1) * limit;
      
      const availableProducts = await TMartProduct.find({
        _id: { $nin: essentialProductIds },
        isAvailable: true
      })
      .sort({ name: 1 })
      .skip(skip)
      .limit(limit)
      .lean();

      const total = await TMartProduct.countDocuments({
        _id: { $nin: essentialProductIds },
        isAvailable: true
      });

      return {
        success: true,
        data: availableProducts,
        pagination: {
          page,
          limit,
          total,
          totalPages: Math.ceil(total / limit)
        }
      };
    } catch (error) {
      throw error;
    }
  }

  // Reorder daily essentials
  static async reorderEssentials(orderData, userId) {
    try {
      const updates = orderData.map((item, index) => ({
        essentialId: item.essentialId,
        data: { sortOrder: index + 1 }
      }));

      return await this.bulkUpdateEssentials(updates, userId);
    } catch (error) {
      throw error;
    }
  }
}

module.exports = DailyEssentialService; 