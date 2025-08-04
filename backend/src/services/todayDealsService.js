const TodayDeal = require('../models/TodayDeal');
const Product = require('../models/Product');

// Get all active today's deals
exports.getActiveDeals = async () => {
  try {
    const currentDate = new Date();
    const deals = await TodayDeal.find({
      isActive: true,
      endDate: { $gte: currentDate },
      $expr: { $lt: ['$soldQuantity', '$maxQuantity'] }
    }).sort({ featured: -1, createdAt: -1 });
    
    return deals;
  } catch (error) {
    console.error('Error fetching active deals:', error);
    throw new Error('Failed to fetch today\'s deals');
  }
};

// Get featured deals
exports.getFeaturedDeals = async () => {
  try {
    const currentDate = new Date();
    const deals = await TodayDeal.find({
      isActive: true,
      featured: true,
      endDate: { $gte: currentDate },
      $expr: { $lt: ['$soldQuantity', '$maxQuantity'] }
    }).sort({ createdAt: -1 });
    
    return deals;
  } catch (error) {
    console.error('Error fetching featured deals:', error);
    throw new Error('Failed to fetch featured deals');
  }
};

// Get deals by category
exports.getDealsByCategory = async (category) => {
  try {
    const currentDate = new Date();
    const deals = await TodayDeal.find({
      isActive: true,
      category: category,
      endDate: { $gte: currentDate },
      $expr: { $lt: ['$soldQuantity', '$maxQuantity'] }
    }).sort({ createdAt: -1 });
    
    return deals;
  } catch (error) {
    console.error('Error fetching deals by category:', error);
    throw new Error('Failed to fetch deals by category');
  }
};

// Create a new deal
exports.createDeal = async (dealData) => {
  try {
    const deal = new TodayDeal(dealData);
    await deal.save();
    return deal;
  } catch (error) {
    console.error('Error creating deal:', error);
    throw new Error('Failed to create deal');
  }
};

// Update deal
exports.updateDeal = async (dealId, updateData) => {
  try {
    const deal = await TodayDeal.findByIdAndUpdate(
      dealId,
      updateData,
      { new: true, runValidators: true }
    );
    return deal;
  } catch (error) {
    console.error('Error updating deal:', error);
    throw new Error('Failed to update deal');
  }
};

// Delete deal
exports.deleteDeal = async (dealId) => {
  try {
    await TodayDeal.findByIdAndDelete(dealId);
    return { message: 'Deal deleted successfully' };
  } catch (error) {
    console.error('Error deleting deal:', error);
    throw new Error('Failed to delete deal');
  }
};

// Update sold quantity
exports.updateSoldQuantity = async (dealId, quantity) => {
  try {
    const deal = await TodayDeal.findById(dealId);
    if (!deal) {
      throw new Error('Deal not found');
    }
    
    if (deal.soldQuantity + quantity > deal.maxQuantity) {
      throw new Error('Insufficient stock for this deal');
    }
    
    deal.soldQuantity += quantity;
    await deal.save();
    return deal;
  } catch (error) {
    console.error('Error updating sold quantity:', error);
    throw error;
  }
};

// Get deal by ID
exports.getDealById = async (dealId) => {
  try {
    const deal = await TodayDeal.findById(dealId);
    return deal;
  } catch (error) {
    console.error('Error fetching deal by ID:', error);
    throw new Error('Failed to fetch deal');
  }
};

// Get statistics for today's deals
exports.getStats = async () => {
  try {
    const currentDate = new Date();
    
    const [
      totalDeals,
      activeDeals,
      featuredDeals,
      expiredDeals
    ] = await Promise.all([
      TodayDeal.countDocuments(),
      TodayDeal.countDocuments({
        isActive: true,
        endDate: { $gte: currentDate },
        $expr: { $lt: ['$soldQuantity', '$maxQuantity'] }
      }),
      TodayDeal.countDocuments({
        isActive: true,
        featured: true,
        endDate: { $gte: currentDate },
        $expr: { $lt: ['$soldQuantity', '$maxQuantity'] }
      }),
      TodayDeal.countDocuments({
        endDate: { $lt: currentDate }
      })
    ]);
    
    return {
      totalDeals,
      activeDeals,
      featuredDeals,
      expiredDeals
    };
  } catch (error) {
    console.error('Error fetching stats:', error);
    throw new Error('Failed to fetch statistics');
  }
}; 