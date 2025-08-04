const todayDealsService = require('../services/todayDealsService');

// ✅ Get all active today's deals
exports.getTodayDeals = async (req, res) => {
  try {
    console.log('🔍 Backend: Getting today\'s deals');
    const deals = await todayDealsService.getActiveDeals();
    console.log(`🔍 Backend: Found ${deals.length} active deals`);
    
    // Transform deals to match frontend expectations
    console.log('🔍 Backend: Original deal structure:', JSON.stringify(deals[0], null, 2));
    
    const transformedDeals = deals.map(deal => {
      const transformed = {
        _id: deal._id,
        name: deal.name || deal.productName,
        imageUrl: deal.imageUrl || deal.productImage,
        originalPrice: deal.originalPrice,
        price: deal.price || deal.dealPrice,
        discount: deal.discount || deal.discountPercentage,
        description: deal.description,
        dealType: deal.dealType,
        category: deal.category,
        featured: deal.featured,
        remainingQuantity: deal.remainingQuantity,
        soldQuantity: deal.soldQuantity,
        maxQuantity: deal.maxQuantity,
        startDate: deal.startDate,
        endDate: deal.endDate,
        isExpired: deal.isExpired,
        isValid: deal.isValid,
        tags: deal.tags || []
      };
      console.log('🔍 Backend: Transformed deal:', JSON.stringify(transformed, null, 2));
      return transformed;
    });
    
    res.json({
      success: true,
      data: transformedDeals,
      message: 'Today\'s deals fetched successfully'
    });
  } catch (error) {
    console.error('❌ Backend: Error fetching today\'s deals:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch today\'s deals',
      error: error.message
    });
  }
};

// ✅ Get featured deals
exports.getFeaturedDeals = async (req, res) => {
  try {
    console.log('🔍 Backend: Getting featured deals');
    const deals = await todayDealsService.getFeaturedDeals();
    console.log(`🔍 Backend: Found ${deals.length} featured deals`);
    
    const transformedDeals = deals.map(deal => ({
      _id: deal._id,
      name: deal.name || deal.productName,
      imageUrl: deal.imageUrl || deal.productImage,
      originalPrice: deal.originalPrice,
      price: deal.price || deal.dealPrice,
      discount: deal.discount || deal.discountPercentage,
      description: deal.description,
      dealType: deal.dealType,
      category: deal.category,
      featured: deal.featured,
      remainingQuantity: deal.remainingQuantity,
      soldQuantity: deal.soldQuantity,
      maxQuantity: deal.maxQuantity,
      startDate: deal.startDate,
      endDate: deal.endDate,
      isExpired: deal.isExpired,
      isValid: deal.isValid,
      tags: deal.tags || []
    }));
    
    res.json({
      success: true,
      data: transformedDeals,
      message: 'Featured deals fetched successfully'
    });
  } catch (error) {
    console.error('❌ Backend: Error fetching featured deals:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch featured deals',
      error: error.message
    });
  }
};

// ✅ Get deals by category
exports.getDealsByCategory = async (req, res) => {
  try {
    const { category } = req.params;
    console.log(`🔍 Backend: Getting deals for category: ${category}`);
    
    const deals = await todayDealsService.getDealsByCategory(category);
    console.log(`🔍 Backend: Found ${deals.length} deals for category ${category}`);
    
    const transformedDeals = deals.map(deal => ({
      _id: deal._id,
      name: deal.name || deal.productName,
      imageUrl: deal.imageUrl || deal.productImage,
      originalPrice: deal.originalPrice,
      price: deal.price || deal.dealPrice,
      discount: deal.discount || deal.discountPercentage,
      description: deal.description,
      dealType: deal.dealType,
      category: deal.category,
      featured: deal.featured,
      remainingQuantity: deal.remainingQuantity,
      soldQuantity: deal.soldQuantity,
      maxQuantity: deal.maxQuantity,
      startDate: deal.startDate,
      endDate: deal.endDate,
      isExpired: deal.isExpired,
      isValid: deal.isValid,
      tags: deal.tags || []
    }));
    
    res.json({
      success: true,
      data: transformedDeals,
      message: `Deals for ${category} fetched successfully`
    });
  } catch (error) {
    console.error('❌ Backend: Error fetching deals by category:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch deals by category',
      error: error.message
    });
  }
};

// ✅ Create a new deal (Admin only)
exports.createDeal = async (req, res) => {
  try {
    console.log('🔍 Backend: Creating new deal');
    const dealData = req.body;
    
    const deal = await todayDealsService.createDeal(dealData);
    console.log(`🔍 Backend: Deal created with ID: ${deal._id}`);
    
    res.status(201).json({
      success: true,
      data: deal,
      message: 'Deal created successfully'
    });
  } catch (error) {
    console.error('❌ Backend: Error creating deal:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create deal',
      error: error.message
    });
  }
};

// ✅ Update deal (Admin only)
exports.updateDeal = async (req, res) => {
  try {
    const { dealId } = req.params;
    const updateData = req.body;
    
    console.log(`🔍 Backend: Updating deal with ID: ${dealId}`);
    const deal = await todayDealsService.updateDeal(dealId, updateData);
    
    if (!deal) {
      return res.status(404).json({
        success: false,
        message: 'Deal not found'
      });
    }
    
    console.log(`🔍 Backend: Deal updated successfully`);
    res.json({
      success: true,
      data: deal,
      message: 'Deal updated successfully'
    });
  } catch (error) {
    console.error('❌ Backend: Error updating deal:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update deal',
      error: error.message
    });
  }
};

// ✅ Delete deal (Admin only)
exports.deleteDeal = async (req, res) => {
  try {
    const { dealId } = req.params;
    
    console.log(`🔍 Backend: Deleting deal with ID: ${dealId}`);
    await todayDealsService.deleteDeal(dealId);
    
    console.log(`🔍 Backend: Deal deleted successfully`);
    res.json({
      success: true,
      message: 'Deal deleted successfully'
    });
  } catch (error) {
    console.error('❌ Backend: Error deleting deal:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete deal',
      error: error.message
    });
  }
};

// ✅ Get deal by ID
exports.getDealById = async (req, res) => {
  try {
    const { dealId } = req.params;
    
    console.log(`🔍 Backend: Getting deal with ID: ${dealId}`);
    const deal = await todayDealsService.getDealById(dealId);
    
    if (!deal) {
      return res.status(404).json({
        success: false,
        message: 'Deal not found'
      });
    }
    
    console.log(`🔍 Backend: Deal found`);
    res.json({
      success: true,
      data: deal,
      message: 'Deal fetched successfully'
    });
  } catch (error) {
    console.error('❌ Backend: Error fetching deal by ID:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch deal',
      error: error.message
    });
  }
};

// Get today's deals statistics
exports.getTodayDealsStats = async (req, res) => {
  try {
    console.log('🔍 Backend: Getting today\'s deals statistics');
    const stats = await todayDealsService.getStats();
    
    console.log('🔍 Backend: Statistics fetched successfully');
    res.json({
      success: true,
      data: stats,
      message: 'Statistics fetched successfully'
    });
  } catch (error) {
    console.error('❌ Backend: Error fetching today\'s deals stats:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch statistics',
      error: error.message
    });
  }
};

// Create a new deal
exports.createDeal = async (req, res) => {
  try {
    console.log('🔍 Backend: Creating new deal');
    const dealData = req.body;
    
    // Add validation here if needed
    const deal = await todayDealsService.createDeal(dealData);
    
    console.log('🔍 Backend: Deal created successfully');
    res.status(201).json({
      success: true,
      data: deal,
      message: 'Deal created successfully'
    });
  } catch (error) {
    console.error('❌ Backend: Error creating deal:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create deal',
      error: error.message
    });
  }
};

// Update a deal
exports.updateDeal = async (req, res) => {
  try {
    console.log('🔍 Backend: Updating deal');
    const { dealId } = req.params;
    const updateData = req.body;
    
    const deal = await todayDealsService.updateDeal(dealId, updateData);
    
    if (!deal) {
      return res.status(404).json({
        success: false,
        message: 'Deal not found'
      });
    }
    
    console.log('🔍 Backend: Deal updated successfully');
    res.json({
      success: true,
      data: deal,
      message: 'Deal updated successfully'
    });
  } catch (error) {
    console.error('❌ Backend: Error updating deal:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update deal',
      error: error.message
    });
  }
};

// Delete a deal
exports.deleteDeal = async (req, res) => {
  try {
    console.log('🔍 Backend: Deleting deal');
    const { dealId } = req.params;
    
    const result = await todayDealsService.deleteDeal(dealId);
    
    console.log('🔍 Backend: Deal deleted successfully');
    res.json({
      success: true,
      data: result,
      message: 'Deal deleted successfully'
    });
  } catch (error) {
    console.error('❌ Backend: Error deleting deal:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete deal',
      error: error.message
    });
  }
}; 