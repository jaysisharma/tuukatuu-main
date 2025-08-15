const bannerService = require('../services/bannersService');

// Base Banner Controller Class
class BaseBannerController {
  /**
   * Get all active banners (public)
   */
  async getAllBanners(req, res) {
    try {
      const { type, category, featured, limit } = req.query;
      
      const banners = await bannerService.getActiveBanners({
        type,
        category,
        featured: featured === 'true',
        limit: parseInt(limit) || 10
      });

      res.json({
        success: true,
        data: banners
      });
    } catch (error) {
      console.error('❌ Error fetching banners:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to fetch banners'
      });
    }
  }

  /**
   * Get banner by ID (public)
   */
  async getBannerById(req, res) {
    try {
      const { id } = req.params;
      const trackImpression = req.query.track === 'true';
      
      const banner = await bannerService.getBannerById(id, trackImpression);

      res.json({
        success: true,
        data: banner
      });
    } catch (error) {
      console.error('❌ Error fetching banner:', error);
      
      // Return appropriate status codes based on error type
      if (error.message.includes('Invalid banner ID format')) {
        return res.status(400).json({
          success: false,
          message: error.message || 'Invalid banner ID format'
        });
      }
      
      if (error.message.includes('Banner not found')) {
        return res.status(404).json({
          success: false,
          message: error.message || 'Banner not found'
        });
      }
      
      res.status(500).json({
        success: false,
        message: error.message || 'Failed to fetch banner'
      });
    }
  }

  /**
   * Record banner click (public)
   */
  async recordBannerClick(req, res) {
    try {
      const { id } = req.params;
      
      await bannerService.recordBannerClick(id);

      res.json({
        success: true,
        message: 'Click recorded successfully'
      });
    } catch (error) {
      console.error('❌ Error recording banner click:', error);
      res.status(404).json({
        success: false,
        message: error.message || 'Failed to record click'
      });
    }
  }

  /**
   * Create new banner (admin only)
   */
  async createBanner(req, res) {
    try {
      const userId = req.user.id;
      const bannerData = req.body;
      const imageFile = req.file;

      console.log('🔍 Create Banner Debug:', {
        userId,
        bannerDataKeys: Object.keys(bannerData),
        hasImageFile: !!imageFile,
        user: req.user
      });

      const banner = await bannerService.createBanner(bannerData, userId, imageFile);

      console.log(`✅ Banner created: ${banner.title} (${banner.bannerType})`);
      res.status(201).json({
        success: true,
        message: 'Banner created successfully',
        data: banner
      });
    } catch (error) {
      console.error('❌ Error creating banner:', error);
      console.error('❌ Error stack:', error.stack);
      
      // Return appropriate status codes based on error type
      if (error.message.includes('Invalid user ID format')) {
        return res.status(400).json({
          success: false,
          message: error.message || 'Invalid user ID format'
        });
      }
      
      if (error.message.includes('Image upload failed')) {
        return res.status(400).json({
          success: false,
          message: error.message || 'Image upload failed'
        });
      }
      
      res.status(400).json({
        success: false,
        message: error.message || 'Failed to create banner'
      });
    }
  }

  /**
   * Update banner (admin only)
   */
  async updateBanner(req, res) {
    try {
      const { id } = req.params;
      const userId = req.user.id;
      const updateData = req.body;
      const imageFile = req.file;

      console.log('🔍 Update Banner Debug:', {
        id,
        userId,
        updateDataKeys: Object.keys(updateData),
        hasImageFile: !!imageFile,
        user: req.user
      });

      const banner = await bannerService.updateBanner(id, updateData, userId, imageFile);

      console.log(`✅ Banner updated: ${banner.title}`);
      res.json({
        success: true,
        message: 'Banner updated successfully',
        data: banner
      });
    } catch (error) {
      console.error('❌ Error updating banner:', error);
      console.error('❌ Error stack:', error.stack);
      
      // Return appropriate status codes based on error type
      if (error.message.includes('Invalid banner ID format')) {
        return res.status(400).json({
          success: false,
          message: error.message || 'Invalid banner ID format'
        });
      }
      
      if (error.message.includes('Invalid user ID format')) {
        return res.status(400).json({
          success: false,
          message: error.message || 'Invalid user ID format'
        });
      }
      
      if (error.message.includes('Banner not found')) {
        return res.status(404).json({
          success: false,
          message: error.message || 'Banner not found'
        });
      }
      
      if (error.message.includes('Image upload failed')) {
        return res.status(400).json({
          success: false,
          message: error.message || 'Image upload failed'
        });
      }
      
      res.status(500).json({
        success: false,
        message: error.message || 'Failed to update banner'
      });
    }
  }

  /**
   * Delete banner (admin only)
   */
  async deleteBanner(req, res) {
    try {
      const { id } = req.params;
      
      const banner = await bannerService.deleteBanner(id);

      console.log(`✅ Banner deleted: ${banner.title}`);
      res.json({
        success: true,
        message: 'Banner deleted successfully'
      });
    } catch (error) {
      console.error('❌ Error deleting banner:', error);
      
      // Return appropriate status codes based on error type
      if (error.message.includes('Invalid banner ID format')) {
        return res.status(400).json({
          success: false,
          message: error.message || 'Invalid banner ID format'
        });
      }
      
      if (error.message.includes('Banner not found')) {
        return res.status(404).json({
          success: false,
          message: error.message || 'Banner not found'
        });
      }
      
      res.status(500).json({
        success: false,
        message: error.message || 'Failed to delete banner'
      });
    }
  }

  /**
   * Toggle banner status (admin only)
   */
  async toggleBannerStatus(req, res) {
    try {
      const { id } = req.params;
      const { field } = req.query; // 'active' or 'featured'
      const userId = req.user.id;

      const banner = await bannerService.toggleBannerStatus(id, field, userId);

      const fieldName = field === 'active' ? 'isActive' : 'isFeatured';
      console.log(`✅ Banner ${field} toggled: ${banner.title} - ${banner[fieldName]}`);
      
      res.json({
        success: true,
        message: `Banner ${field} ${banner[fieldName] ? 'enabled' : 'disabled'} successfully`,
        data: { [fieldName]: banner[fieldName] }
      });
    } catch (error) {
      console.error('❌ Error toggling banner status:', error);
      
      // Return appropriate status codes based on error type
      if (error.message.includes('Invalid banner ID format')) {
        return res.status(400).json({
          success: false,
          message: error.message || 'Invalid banner ID format'
        });
      }
      
      if (error.message.includes('Banner not found')) {
        return res.status(404).json({
          success: false,
          message: error.message || 'Banner not found'
        });
      }
      
      if (error.message.includes('Invalid field')) {
        return res.status(400).json({
          success: false,
          message: error.message || 'Invalid field. Use "active" or "featured"'
        });
      }
      
      res.status(500).json({
        success: false,
        message: error.message || 'Failed to toggle banner status'
      });
    }
  }

  /**
   * Get all banners for admin (admin only)
   */
  async getAllBannersAdmin(req, res) {
    try {
      const { page, limit, search, filter, type, category } = req.query;
      
      const result = await bannerService.getBannersForAdmin({
        page,
        limit,
        search,
        filter,
        type,
        category
      });

      res.json({
        success: true,
        data: result.banners,
        pagination: result.pagination
      });
    } catch (error) {
      console.error('❌ Error fetching banners for admin:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to fetch banners'
      });
    }
  }

  /**
   * Get banner analytics (admin only)
   */
  async getBannerAnalytics(req, res) {
    try {
      const { id } = req.params;
      
      const analytics = await bannerService.getBannerAnalytics(id);

      res.json({
        success: true,
        data: analytics
      });
    } catch (error) {
      console.error('❌ Error fetching banner analytics:', error);
      
      // Return appropriate status codes based on error type
      if (error.message.includes('Invalid banner ID format')) {
        return res.status(400).json({
          success: false,
          message: error.message || 'Invalid banner ID format'
        });
      }
      
      if (error.message.includes('Banner not found')) {
        return res.status(404).json({
          success: false,
          message: error.message || 'Banner not found'
        });
      }
      
      res.status(500).json({
        success: false,
        message: error.message || 'Failed to fetch banner analytics'
      });
    }
  }

  /**
   * Bulk update banners (admin only)
   */
  async bulkUpdateBanners(req, res) {
    try {
      const { bannerIds, updates } = req.body;
      const userId = req.user.id;

      const result = await bannerService.bulkUpdateBanners(bannerIds, updates, userId);

      console.log(`✅ Bulk updated ${result.modifiedCount} banners`);
      res.json({
        success: true,
        message: `Successfully updated ${result.modifiedCount} banners`,
        data: result
      });
    } catch (error) {
      console.error('❌ Error bulk updating banners:', error);
      res.status(400).json({
        success: false,
        message: error.message || 'Failed to bulk update banners'
      });
    }
  }

  /**
   * Get banner statistics (admin only)
   */
  async getBannerStatistics(req, res) {
    try {
      const stats = await bannerService.getBannerStatistics();

      res.json({
        success: true,
        data: stats
      });
    } catch (error) {
      console.error('❌ Error fetching banner statistics:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to fetch banner statistics'
      });
    }
  }
}

// Create controller instance
const bannerController = new BaseBannerController();

// Export controller methods
module.exports = {
  // Public routes
  getAllBanners: bannerController.getAllBanners.bind(bannerController),
  getBannerById: bannerController.getBannerById.bind(bannerController),
  recordBannerClick: bannerController.recordBannerClick.bind(bannerController),
  
  // Admin routes
  createBanner: bannerController.createBanner.bind(bannerController),
  updateBanner: bannerController.updateBanner.bind(bannerController),
  deleteBanner: bannerController.deleteBanner.bind(bannerController),
  toggleBannerStatus: bannerController.toggleBannerStatus.bind(bannerController),
  getAllBannersAdmin: bannerController.getAllBannersAdmin.bind(bannerController),
  getBannerAnalytics: bannerController.getBannerAnalytics.bind(bannerController),
  bulkUpdateBanners: bannerController.bulkUpdateBanners.bind(bannerController),
  getBannerStatistics: bannerController.getBannerStatistics.bind(bannerController)
}; 