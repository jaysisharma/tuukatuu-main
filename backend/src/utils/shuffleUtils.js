/**
 * Utility functions for shuffling arrays to provide variety in listings
 * Following industry standards for e-commerce and food delivery platforms
 */

/**
 * Fisher-Yates shuffle algorithm for unbiased random shuffling
 * @param {Array} array - The array to shuffle
 * @returns {Array} - A new shuffled array
 */
const fisherYatesShuffle = (array) => {
  const shuffled = [...array];
  for (let i = shuffled.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
  }
  return shuffled;
};

/**
 * Calculate distance between two points using Haversine formula
 * @param {number} lat1 - Latitude of first point
 * @param {number} lon1 - Longitude of first point
 * @param {number} lat2 - Latitude of second point
 * @param {number} lon2 - Longitude of second point
 * @returns {number} Distance in kilometers
 */
const calculateDistance = (lat1, lon1, lat2, lon2) => {
  const R = 6371; // Radius of the Earth in kilometers
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const a = 
    Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) * 
    Math.sin(dLon/2) * Math.sin(dLon/2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
  return R * c;
};

/**
 * Sort vendors by distance from user coordinates and then shuffle within distance groups
 * @param {Array} vendors - Array of vendor objects with storeCoordinates
 * @param {number} userLat - User's latitude
 * @param {number} userLon - User's longitude
 * @param {Object} options - Sorting and shuffling options
 * @returns {Array} - Sorted and shuffled vendors
 */
const sortAndShuffleByDistance = (vendors, userLat, userLon, options = {}) => {
  const { 
    distanceGroups = [1, 3, 5, 10], // Distance groups in km: 0-1km, 1-3km, 3-5km, 5-10km, 10+km
    shuffleWithinGroups = true,
    prioritizeFeatured = true 
  } = options;

  if (!vendors || vendors.length === 0) return vendors;
  if (!userLat || !userLon) return fisherYatesShuffle(vendors);

  // Calculate distances and add to vendors
  const vendorsWithDistance = vendors.map(vendor => {
    if (vendor.storeCoordinates && vendor.storeCoordinates.coordinates) {
      const [vendorLon, vendorLat] = vendor.storeCoordinates.coordinates;
      const distance = calculateDistance(userLat, userLon, vendorLat, vendorLon);
      return { ...vendor, distance };
    }
    return { ...vendor, distance: Infinity }; // Vendors without coordinates go to the end
  });

  // Sort by distance first
  vendorsWithDistance.sort((a, b) => a.distance - b.distance);

  // Group by distance ranges
  const groupedVendors = {};
  distanceGroups.forEach((maxDistance, index) => {
    const minDistance = index === 0 ? 0 : distanceGroups[index - 1];
    groupedVendors[`${minDistance}-${maxDistance}`] = vendorsWithDistance.filter(
      vendor => vendor.distance >= minDistance && vendor.distance < maxDistance
    );
  });

  // Add vendors beyond the last distance group
  const lastMaxDistance = distanceGroups[distanceGroups.length - 1];
  groupedVendors[`${lastMaxDistance}+`] = vendorsWithDistance.filter(
    vendor => vendor.distance >= lastMaxDistance
  );

  // Shuffle within each group and combine
  let result = [];
  Object.keys(groupedVendors).forEach(distanceRange => {
    let groupVendors = groupedVendors[distanceRange];
    
    if (shuffleWithinGroups && groupVendors.length > 0) {
      // Apply featured priority within each distance group
      if (prioritizeFeatured) {
        groupVendors = shuffleWithFeaturedPriority(groupVendors);
      } else {
        groupVendors = fisherYatesShuffle(groupVendors);
      }
    }
    
    result = result.concat(groupVendors);
  });

  return result;
};

/**
 * Smart shuffle that considers business logic while maintaining randomness
 * @param {Array} array - The array to shuffle
 * @param {Object} options - Shuffle options
 * @param {boolean} options.prioritizeFeatured - Whether to prioritize featured items
 * @param {boolean} options.maintainQualityOrder - Whether to maintain quality-based ordering
 * @returns {Array} - A smartly shuffled array
 */
const smartShuffle = (array, options = {}) => {
  const { prioritizeFeatured = true, maintainQualityOrder = false } = options;
  
  if (!array || array.length === 0) return array;
  
  // If we want to maintain quality order, we'll shuffle within quality tiers
  if (maintainQualityOrder) {
    return shuffleWithinQualityTiers(array);
  }
  
  // If we want to prioritize featured items, we'll shuffle them separately
  if (prioritizeFeatured) {
    return shuffleWithFeaturedPriority(array);
  }
  
  // Default: simple Fisher-Yates shuffle
  return fisherYatesShuffle(array);
};

/**
 * Shuffle within quality tiers to maintain some ordering while adding variety
 * @param {Array} array - The array to shuffle
 * @returns {Array} - Array shuffled within quality tiers
 */
const shuffleWithinQualityTiers = (array) => {
  // Group by quality tiers (e.g., rating ranges)
  const highQuality = array.filter(item => 
    (item.storeRating && item.storeRating >= 4.5) || 
    (item.rating && item.rating >= 4.5) ||
    item.isFeatured
  );
  
  const mediumQuality = array.filter(item => 
    (item.storeRating && item.storeRating >= 4.0 && item.storeRating < 4.5) ||
    (item.rating && item.rating >= 4.0 && item.rating < 4.5)
  );
  
  const standardQuality = array.filter(item => 
    (item.storeRating && item.storeRating < 4.0) ||
    (item.rating && item.rating < 4.0)
  );
  
  // Shuffle each tier separately
  const shuffledHigh = fisherYatesShuffle(highQuality);
  const shuffledMedium = fisherYatesShuffle(mediumQuality);
  const shuffledStandard = fisherYatesShuffle(standardQuality);
  
  // Combine tiers with high quality first
  return [...shuffledHigh, ...shuffledMedium, ...shuffledStandard];
};

/**
 * Shuffle with featured items getting priority placement
 * @param {Array} array - The array to shuffle
 * @returns {Array} - Array with featured items prioritized
 */
const shuffleWithFeaturedPriority = (array) => {
  const featured = array.filter(item => item.isFeatured);
  const nonFeatured = array.filter(item => !item.isFeatured);
  
  // Shuffle each group separately
  const shuffledFeatured = fisherYatesShuffle(featured);
  const shuffledNonFeatured = fisherYatesShuffle(nonFeatured);
  
  // Place featured items at the beginning, then non-featured
  return [...shuffledFeatured, ...shuffledNonFeatured];
};

/**
 * Shuffle vendors with business logic considerations
 * @param {Array} vendors - Array of vendor objects
 * @param {Object} options - Shuffle options
 * @returns {Array} - Shuffled vendors
 */
const shuffleVendors = (vendors, options = {}) => {
  const { 
    prioritizeFeatured = true, 
    maintainQualityOrder = true,
    considerRating = true 
  } = options;
  
  if (!vendors || vendors.length === 0) return vendors;
  
  // Apply smart shuffle with vendor-specific logic
  return smartShuffle(vendors, {
    prioritizeFeatured,
    maintainQualityOrder: considerRating && maintainQualityOrder
  });
};

/**
 * Shuffle products with business logic considerations
 * @param {Array} products - Array of product objects
 * @param {Object} options - Shuffle options
 * @returns {Array} - Shuffled products
 */
const shuffleProducts = (products, options = {}) => {
  const { 
    prioritizeFeatured = true, 
    maintainQualityOrder = true,
    considerRating = true 
  } = options;
  
  if (!products || products.length === 0) return products;
  
  // Apply smart shuffle with product-specific logic
  return smartShuffle(products, {
    prioritizeFeatured,
    maintainQualityOrder: considerRating && maintainQualityOrder
  });
};

module.exports = {
  fisherYatesShuffle,
  smartShuffle,
  shuffleVendors,
  shuffleProducts,
  shuffleWithinQualityTiers,
  shuffleWithFeaturedPriority,
  calculateDistance,
  sortAndShuffleByDistance
};
