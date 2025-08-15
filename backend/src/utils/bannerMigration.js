const mongoose = require('mongoose');
const TMartBanner = require('../models/TMartBanner');
const Banner = require('../models/Banner');

/**
 * Migration utility to move T-Mart banners to unified banner system
 * This should be run once to migrate existing data
 */
class BannerMigration {
  /**
   * Migrate all T-Mart banners to the unified banner system
   */
  static async migrateTMartBanners() {
    try {
      console.log('🔄 Starting T-Mart banner migration...');
      
      // Get all T-Mart banners
      const tmartBanners = await TMartBanner.find({});
      console.log(`📊 Found ${tmartBanners.length} T-Mart banners to migrate`);
      
      let migratedCount = 0;
      let skippedCount = 0;
      
      for (const tmartBanner of tmartBanners) {
        try {
          // Check if banner already exists in unified system
          const existingBanner = await Banner.findOne({
            title: tmartBanner.title,
            'bannerType': 'tmart',
            createdAt: tmartBanner.createdAt
          });
          
          if (existingBanner) {
            console.log(`⏭️  Skipping existing banner: ${tmartBanner.title}`);
            skippedCount++;
            continue;
          }
          
          // Create new unified banner
          const newBanner = new Banner({
            title: tmartBanner.title,
            subtitle: tmartBanner.description || '',
            description: tmartBanner.description || '',
            image: tmartBanner.image,
            imageAlt: tmartBanner.imageAlt || '',
            link: tmartBanner.link || '',
            linkType: tmartBanner.linkType || 'none',
            linkTarget: tmartBanner.linkTarget || '',
            bannerType: 'tmart',
            category: 'general', // Default category for T-Mart banners
            sortOrder: tmartBanner.sortOrder || 0,
            priority: 1,
            backgroundColor: '#FF6B35', // Default T-Mart color
            textColor: '#FFFFFF',
            isActive: tmartBanner.isActive,
            isFeatured: tmartBanner.isFeatured,
            startDate: tmartBanner.startDate,
            endDate: tmartBanner.endDate,
            targetAudience: tmartBanner.targetAudience || [],
            clicks: tmartBanner.clicks || 0,
            impressions: tmartBanner.impressions || 0,
            createdBy: tmartBanner.createdBy,
            updatedBy: tmartBanner.updatedBy
          });
          
          await newBanner.save();
          migratedCount++;
          console.log(`✅ Migrated: ${tmartBanner.title}`);
          
        } catch (error) {
          console.error(`❌ Failed to migrate banner ${tmartBanner.title}:`, error.message);
        }
      }
      
      console.log(`\n🎉 Migration completed!`);
      console.log(`✅ Successfully migrated: ${migratedCount} banners`);
      console.log(`⏭️  Skipped (already exists): ${skippedCount} banners`);
      console.log(`📊 Total processed: ${tmartBanners.length} banners`);
      
      return { migratedCount, skippedCount, total: tmartBanners.length };
      
    } catch (error) {
      console.error('❌ Migration failed:', error);
      throw error;
    }
  }
  
  /**
   * Rollback migration (remove migrated T-Mart banners)
   */
  static async rollbackMigration() {
    try {
      console.log('🔄 Starting rollback of T-Mart banner migration...');
      
      const result = await Banner.deleteMany({ bannerType: 'tmart' });
      
      console.log(`✅ Rollback completed! Removed ${result.deletedCount} migrated T-Mart banners`);
      
      return result;
      
    } catch (error) {
      console.error('❌ Rollback failed:', error);
      throw error;
    }
  }
  
  /**
   * Verify migration integrity
   */
  static async verifyMigration() {
    try {
      console.log('🔍 Verifying migration integrity...');
      
      const tmartBannerCount = await TMartBanner.countDocuments();
      const unifiedTMartCount = await Banner.countDocuments({ bannerType: 'tmart' });
      
      console.log(`📊 T-Mart Banner model count: ${tmartBannerCount}`);
      console.log(`📊 Unified Banner model (tmart type) count: ${unifiedTMartCount}`);
      
      if (tmartBannerCount === unifiedTMartCount) {
        console.log('✅ Migration verification passed! Counts match.');
      } else {
        console.log('⚠️  Migration verification failed! Counts do not match.');
      }
      
      return { tmartBannerCount, unifiedTMartCount, verified: tmartBannerCount === unifiedTMartCount };
      
    } catch (error) {
      console.error('❌ Verification failed:', error);
      throw error;
    }
  }
}

module.exports = BannerMigration;
