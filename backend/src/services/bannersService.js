const Banner = require('../models/Banner');
const { uploadToCloudinary } = require('../utils/cloudinary');
const mongoose = require('mongoose');

class BannerService {
  /**
   * Get active banners with optional filtering
   */
  async getActiveBanners(options = {}) {
    try {
      const { type, category, featured, limit = 10 } = options;
      
      if (featured) {
        return await Banner.getFeatured({ category, limit });
      }
      
      if (type) {
        return await Banner.getByType(type, { category, limit });
      }
      
      return await Banner.getActive({ category, limit });
    } catch (error) {
      throw new Error(`Failed to fetch active banners: ${error.message}`);
    }
  }

  /**
   * Get banner by ID with analytics tracking
   */
  async getBannerById(id, trackImpression = false) {
    try {
      // Validate ObjectId format
      if (!mongoose.Types.ObjectId.isValid(id)) {
        throw new Error('Invalid banner ID format');
      }

      const banner = await Banner.findById(id);
      
      if (!banner) {
        throw new Error('Banner not found');
      }

      if (trackImpression) {
        await banner.incrementImpression();
      }

      return banner;
    } catch (error) {
      throw new Error(`Failed to fetch banner: ${error.message}`);
    }
  }

  /**
   * Create a new banner
   */
  async createBanner(bannerData, userId, imageFile = null) {
    try {
      // Validate userId format
      if (!mongoose.Types.ObjectId.isValid(userId)) {
        throw new Error('Invalid user ID format');
      }

      // Handle image upload if provided
      let imageUrl = null;
      if (imageFile) {
        try {
          const folder = this._getCloudinaryFolder(bannerData.bannerType);
          const result = await uploadToCloudinary(imageFile, folder);
          imageUrl = result.secure_url;
        } catch (uploadError) {
          console.error('Image upload failed:', uploadError);
          throw new Error(`Image upload failed: ${uploadError.message}`);
        }
      }

      // Validate required fields
      if (!bannerData.title || !imageUrl) {
        throw new Error('Title and image are required');
      }

      // Prepare banner data with proper validation
      const bannerFields = {
        ...bannerData,
        image: imageUrl,
        createdBy: userId,
        updatedBy: userId
      };

      // Validate and convert specific fields
      if (bannerFields.startDate) {
        bannerFields.startDate = new Date(bannerFields.startDate);
      }
      if (bannerFields.endDate) {
        bannerFields.endDate = new Date(bannerFields.endDate);
      }
      if (bannerFields.sortOrder !== undefined) {
        bannerFields.sortOrder = parseInt(bannerFields.sortOrder) || 0;
      }
      if (bannerFields.priority !== undefined) {
        bannerFields.priority = parseInt(bannerFields.priority) || 1;
      }
      if (bannerFields.isActive !== undefined) {
        bannerFields.isActive = Boolean(bannerFields.isActive);
      }
      if (bannerFields.isFeatured !== undefined) {
        bannerFields.isFeatured = Boolean(bannerFields.isFeatured);
      }

      const banner = new Banner(bannerFields);

      await banner.save();
      return banner;
    } catch (error) {
      console.error('Banner creation error:', error);
      throw new Error(`Failed to create banner: ${error.message}`);
    }
  }

  /**
   * Update an existing banner
   */
  async updateBanner(id, updateData, userId, imageFile = null) {
    try {
      // Validate ObjectId format
      if (!mongoose.Types.ObjectId.isValid(id)) {
        throw new Error('Invalid banner ID format');
      }

      // Validate userId format
      if (!mongoose.Types.ObjectId.isValid(userId)) {
        throw new Error('Invalid user ID format');
      }

      const banner = await Banner.findById(id);
      
      if (!banner) {
        throw new Error('Banner not found');
      }

      // Handle image upload if provided
      if (imageFile) {
        try {
          const folder = this._getCloudinaryFolder(banner.bannerType);
          const result = await uploadToCloudinary(imageFile, folder);
          updateData.image = result.secure_url;
        } catch (uploadError) {
          console.error('Image upload failed:', uploadError);
          throw new Error(`Image upload failed: ${uploadError.message}`);
        }
      }

      // Update fields with proper validation
      Object.keys(updateData).forEach(key => {
        if (updateData[key] !== undefined && updateData[key] !== '') {
          try {
            if (['startDate', 'endDate'].includes(key)) {
              banner[key] = updateData[key] ? new Date(updateData[key]) : null;
            } else if (['sortOrder', 'priority'].includes(key)) {
              banner[key] = parseInt(updateData[key]) || 0;
            } else if (['isActive', 'isFeatured'].includes(key)) {
              banner[key] = Boolean(updateData[key]);
            } else if (key === 'targetAudience' && Array.isArray(updateData[key])) {
              banner[key] = updateData[key];
            } else {
              banner[key] = updateData[key];
            }
          } catch (fieldError) {
            console.error(`Error updating field ${key}:`, fieldError);
            throw new Error(`Invalid value for field ${key}: ${updateData[key]}`);
          }
        }
      });

      banner.updatedBy = userId;
      banner.updatedAt = new Date();

      await banner.save();
      return banner;
    } catch (error) {
      console.error('Banner update error:', error);
      throw new Error(`Failed to update banner: ${error.message}`);
    }
  }

  /**
   * Delete a banner
   */
  async deleteBanner(id) {
    try {
      // Validate ObjectId format
      if (!mongoose.Types.ObjectId.isValid(id)) {
        throw new Error('Invalid banner ID format');
      }

      const banner = await Banner.findByIdAndDelete(id);
      
      if (!banner) {
        throw new Error('Banner not found');
      }

      return banner;
    } catch (error) {
      throw new Error(`Failed to delete banner: ${error.message}`);
    }
  }

  /**
   * Toggle banner status (active/featured)
   */
  async toggleBannerStatus(id, field, userId) {
    try {
      // Validate ObjectId format
      if (!mongoose.Types.ObjectId.isValid(id)) {
        throw new Error('Invalid banner ID format');
      }

      // Validate userId format
      if (!mongoose.Types.ObjectId.isValid(userId)) {
        throw new Error('Invalid user ID format');
      }

      if (!['active', 'featured'].includes(field)) {
        throw new Error('Invalid field. Use "active" or "featured"');
      }

      const banner = await Banner.findById(id);
      
      if (!banner) {
        throw new Error('Banner not found');
      }

      const fieldName = field === 'active' ? 'isActive' : 'isFeatured';
      banner[fieldName] = !banner[fieldName];
      banner.updatedBy = userId;
      banner.updatedAt = new Date();

      await banner.save();
      return banner;
    } catch (error) {
      console.error('Banner status toggle error:', error);
      throw new Error(`Failed to toggle banner status: ${error.message}`);
    }
  }

  /**
   * Get banners for admin with pagination and filtering
   */
  async getBannersForAdmin(options = {}) {
    try {
      const { page = 1, limit = 20, search = '', filter = 'all', type = '', category = '' } = options;
      
      const query = {};
      
      // Apply search filter
      if (search) {
        query.$or = [
          { title: { $regex: search, $options: 'i' } },
          { description: { $regex: search, $options: 'i' } },
          { subtitle: { $regex: search, $options: 'i' } }
        ];
      }
      
      // Apply status filter
      if (filter === 'active') {
        query.isActive = true;
      } else if (filter === 'inactive') {
        query.isActive = false;
      } else if (filter === 'featured') {
        query.isFeatured = true;
      } else if (filter === 'expired') {
        query.endDate = { $lt: new Date() };
      }
      
      // Apply type filter
      if (type) {
        query.bannerType = type;
      }

      // Apply category filter
      if (category) {
        query.category = category;
      }

      const skip = (page - 1) * limit;
      
      const [banners, total] = await Promise.all([
        Banner.find(query)
          .sort({ sortOrder: 1, priority: 1, createdAt: -1 })
          .skip(skip)
          .limit(parseInt(limit)),
        Banner.countDocuments(query)
      ]);

      const totalPages = Math.ceil(total / limit);

      return {
        banners,
        pagination: {
          current: parseInt(page),
          pages: totalPages,
          total,
          limit: parseInt(limit)
        }
      };
    } catch (error) {
      throw new Error(`Failed to fetch banners for admin: ${error.message}`);
    }
  }

  /**
   * Get banner analytics
   */
  async getBannerAnalytics(id) {
    try {
      // Validate ObjectId format
      if (!mongoose.Types.ObjectId.isValid(id)) {
        throw new Error('Invalid banner ID format');
      }

      const banner = await Banner.findById(id);
      
      if (!banner) {
        throw new Error('Banner not found');
      }

      return {
        id: banner._id,
        title: banner.title,
        impressions: banner.impressions,
        clicks: banner.clicks,
        ctr: banner.ctr,
        status: banner.status,
        createdAt: banner.createdAt,
        updatedAt: banner.updatedAt
      };
    } catch (error) {
      throw new Error(`Failed to fetch banner analytics: ${error.message}`);
    }
  }

  /**
   * Record banner click
   */
  async recordBannerClick(id) {
    try {
      // Validate ObjectId format
      if (!mongoose.Types.ObjectId.isValid(id)) {
        throw new Error('Invalid banner ID format');
      }

      const banner = await Banner.findById(id);
      
      if (!banner) {
        throw new Error('Banner not found');
      }

      await banner.incrementClick();
      return banner;
    } catch (error) {
      throw new Error(`Failed to record banner click: ${error.message}`);
    }
  }

  /**
   * Bulk update banners
   */
  async bulkUpdateBanners(bannerIds, updates, userId) {
    try {
      if (!bannerIds || !Array.isArray(bannerIds) || bannerIds.length === 0) {
        throw new Error('Banner IDs array is required');
      }

      // Validate all ObjectIds
      for (const id of bannerIds) {
        if (!mongoose.Types.ObjectId.isValid(id)) {
          throw new Error(`Invalid banner ID format: ${id}`);
        }
      }

      const result = await Banner.updateMany(
        { _id: { $in: bannerIds } },
        { 
          ...updates,
          updatedBy: userId,
          updatedAt: new Date()
        }
      );

      return { modifiedCount: result.modifiedCount };
    } catch (error) {
      throw new Error(`Failed to bulk update banners: ${error.message}`);
    }
  }

  /**
   * Get banner statistics
   */
  async getBannerStatistics() {
    try {
      const stats = await Banner.aggregate([
        {
          $group: {
            _id: '$bannerType',
            total: { $sum: 1 },
            active: { $sum: { $cond: ['$isActive', 1, 0] } },
            featured: { $sum: { $cond: ['$isFeatured', 1, 0] } },
            totalImpressions: { $sum: '$impressions' },
            totalClicks: { $sum: '$clicks' }
          }
        }
      ]);

      return stats;
    } catch (error) {
      throw new Error(`Failed to fetch banner statistics: ${error.message}`);
    }
  }

  /**
   * Get cloudinary folder based on banner type
   */
  _getCloudinaryFolder(bannerType) {
    const folders = {
      'tmart': 'tmart-banners',
      'regular': 'banners',
      'hero': 'hero-banners',
      'category': 'category-banners',
      'promotional': 'promotional-banners',
      'deal': 'deal-banners'
    };
    
    return folders[bannerType] || 'banners';
  }
}

module.exports = new BannerService(); 