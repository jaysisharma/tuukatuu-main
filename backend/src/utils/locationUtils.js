/**
 * Location utilities for distance calculations and geospatial operations
 */

/**
 * Calculate distance between two points using Haversine formula
 * @param {number} lat1 - Latitude of first point
 * @param {number} lon1 - Longitude of first point
 * @param {number} lat2 - Latitude of second point
 * @param {number} lon2 - Longitude of second point
 * @returns {number} Distance in kilometers
 */
function calculateDistance(lat1, lon1, lat2, lon2) {
  const R = 6371; // Radius of the Earth in kilometers
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const a = 
    Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) * 
    Math.sin(dLon/2) * Math.sin(dLon/2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
  const distance = R * c; // Distance in kilometers
  return distance;
}

/**
 * Calculate estimated time of arrival
 * @param {number} distance - Distance in kilometers
 * @param {number} averageSpeed - Average speed in km/h (default: 20)
 * @returns {number} Estimated time in minutes
 */
function calculateETA(distance, averageSpeed = 20) {
  return Math.round((distance / averageSpeed) * 60);
}

/**
 * Calculate delivery fee based on distance
 * @param {number} distance - Distance in kilometers
 * @param {Object} feeStructure - Fee structure configuration
 * @returns {number} Delivery fee
 */
function calculateDeliveryFee(distance, feeStructure = {
  baseFee: 50,
  perKmFee: 10,
  freeDeliveryThreshold: 3
}) {
  const { baseFee, perKmFee, freeDeliveryThreshold } = feeStructure;
  
  if (distance <= freeDeliveryThreshold) {
    return baseFee;
  }
  
  const extraDistance = distance - freeDeliveryThreshold;
  return baseFee + (extraDistance * perKmFee);
}

/**
 * Check if a point is within a certain radius of another point
 * @param {number} centerLat - Center latitude
 * @param {number} centerLon - Center longitude
 * @param {number} pointLat - Point latitude
 * @param {number} pointLon - Point longitude
 * @param {number} radiusKm - Radius in kilometers
 * @returns {boolean} True if point is within radius
 */
function isWithinRadius(centerLat, centerLon, pointLat, pointLon, radiusKm) {
  const distance = calculateDistance(centerLat, centerLon, pointLat, pointLon);
  return distance <= radiusKm;
}

/**
 * Create a bounding box for geospatial queries
 * @param {number} latitude - Center latitude
 * @param {number} longitude - Center longitude
 * @param {number} radiusKm - Radius in kilometers
 * @returns {Object} Bounding box coordinates
 */
function createBoundingBox(latitude, longitude, radiusKm) {
  const latDelta = radiusKm / 111; // Rough conversion to degrees
  const lonDelta = radiusKm / (111 * Math.cos(latitude * Math.PI / 180));
  
  return {
    minLat: latitude - latDelta,
    maxLat: latitude + latDelta,
    minLon: longitude - lonDelta,
    maxLon: longitude + lonDelta
  };
}

/**
 * Calculate optimal route distance using multiple waypoints
 * @param {Array} waypoints - Array of {lat, lng} coordinates
 * @returns {number} Total route distance in kilometers
 */
function calculateRouteDistance(waypoints) {
  if (waypoints.length < 2) return 0;
  
  let totalDistance = 0;
  for (let i = 0; i < waypoints.length - 1; i++) {
    const current = waypoints[i];
    const next = waypoints[i + 1];
    totalDistance += calculateDistance(current.lat, current.lng, next.lat, next.lng);
  }
  
  return totalDistance;
}

/**
 * Find the nearest point from a list of points
 * @param {number} targetLat - Target latitude
 * @param {number} targetLon - Target longitude
 * @param {Array} points - Array of points with lat/lng properties
 * @returns {Object} Nearest point and distance
 */
function findNearestPoint(targetLat, targetLon, points) {
  let nearest = null;
  let minDistance = Infinity;
  
  for (const point of points) {
    const distance = calculateDistance(targetLat, targetLon, point.lat, point.lng);
    if (distance < minDistance) {
      minDistance = distance;
      nearest = point;
    }
  }
  
  return { point: nearest, distance: minDistance };
}

/**
 * Validate coordinates
 * @param {number} latitude - Latitude to validate
 * @param {number} longitude - Longitude to validate
 * @returns {boolean} True if coordinates are valid
 */
function validateCoordinates(latitude, longitude) {
  return (
    typeof latitude === 'number' &&
    typeof longitude === 'number' &&
    latitude >= -90 && latitude <= 90 &&
    longitude >= -180 && longitude <= 180
  );
}

/**
 * Format coordinates for display
 * @param {number} latitude - Latitude
 * @param {number} longitude - Longitude
 * @param {number} precision - Decimal places (default: 6)
 * @returns {string} Formatted coordinates
 */
function formatCoordinates(latitude, longitude, precision = 6) {
  const lat = latitude.toFixed(precision);
  const lng = longitude.toFixed(precision);
  return `${lat}, ${lng}`;
}

/**
 * Calculate bearing between two points
 * @param {number} lat1 - Starting latitude
 * @param {number} lon1 - Starting longitude
 * @param {number} lat2 - Ending latitude
 * @param {number} lon2 - Ending longitude
 * @returns {number} Bearing in degrees
 */
function calculateBearing(lat1, lon1, lat2, lon2) {
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const lat1Rad = lat1 * Math.PI / 180;
  const lat2Rad = lat2 * Math.PI / 180;
  
  const y = Math.sin(dLon) * Math.cos(lat2Rad);
  const x = Math.cos(lat1Rad) * Math.sin(lat2Rad) - 
            Math.sin(lat1Rad) * Math.cos(lat2Rad) * Math.cos(dLon);
  
  let bearing = Math.atan2(y, x) * 180 / Math.PI;
  bearing = (bearing + 360) % 360;
  
  return bearing;
}

/**
 * Estimate travel time considering traffic conditions
 * @param {number} distance - Distance in kilometers
 * @param {string} timeOfDay - Time of day ('peak', 'off-peak', 'night')
 * @param {string} dayOfWeek - Day of week (0-6, where 0 is Sunday)
 * @returns {number} Estimated travel time in minutes
 */
function estimateTravelTime(distance, timeOfDay = 'off-peak', dayOfWeek = 1) {
  const baseSpeed = 20; // km/h
  
  // Speed multipliers based on time and day
  const speedMultipliers = {
    peak: { weekday: 0.6, weekend: 0.8 },
    'off-peak': { weekday: 1.0, weekend: 1.0 },
    night: { weekday: 1.2, weekend: 1.1 }
  };
  
  const isWeekend = dayOfWeek === 0 || dayOfWeek === 6;
  const multiplier = isWeekend ? 
    speedMultipliers[timeOfDay].weekend : 
    speedMultipliers[timeOfDay].weekday;
  
  const adjustedSpeed = baseSpeed * multiplier;
  return Math.round((distance / adjustedSpeed) * 60);
}

/**
 * Create a geospatial index query for MongoDB
 * @param {number} latitude - Center latitude
 * @param {number} longitude - Center longitude
 * @param {number} maxDistance - Maximum distance in meters
 * @returns {Object} MongoDB geospatial query
 */
function createGeospatialQuery(latitude, longitude, maxDistance) {
  return {
    $near: {
      $geometry: {
        type: 'Point',
        coordinates: [longitude, latitude]
      },
      $maxDistance: maxDistance
    }
  };
}

module.exports = {
  calculateDistance,
  calculateETA,
  calculateDeliveryFee,
  isWithinRadius,
  createBoundingBox,
  calculateRouteDistance,
  findNearestPoint,
  validateCoordinates,
  formatCoordinates,
  calculateBearing,
  estimateTravelTime,
  createGeospatialQuery
}; 