const locationService = require('../services/locationService');
const { validateCoordinates } = require('../utils/locationUtils');

// ✅ Geocode an address
exports.geocodeAddress = async (req, res) => {
  try {
    const { address } = req.body;

    if (!address || address.trim().length === 0) {
      return res.status(400).json({ message: 'Address is required' });
    }

    const result = await locationService.geocodeAddress(address);
    res.json(result);
  } catch (error) {
    console.error('Error geocoding address:', error);
    res.status(400).json({ message: error.message });
  }
};

// ✅ Reverse geocode coordinates
exports.reverseGeocode = async (req, res) => {
  try {
    const { latitude, longitude } = req.body;

    if (!latitude || !longitude) {
      return res.status(400).json({ message: 'Latitude and longitude are required' });
    }

    if (!validateCoordinates(latitude, longitude)) {
      return res.status(400).json({ message: 'Invalid coordinates provided' });
    }

    const result = await locationService.reverseGeocode(latitude, longitude);
    res.json(result);
  } catch (error) {
    console.error('Error reverse geocoding:', error);
    res.status(400).json({ message: error.message });
  }
};

// ✅ Validate and format address
exports.validateAddress = async (req, res) => {
  try {
    const addressData = req.body;

    if (!addressData) {
      return res.status(400).json({ message: 'Address data is required' });
    }

    const result = await locationService.validateAndFormatAddress(addressData);
    res.json(result);
  } catch (error) {
    console.error('Error validating address:', error);
    res.status(400).json({ message: error.message });
  }
};

// ✅ Calculate distance between two points
exports.calculateDistance = async (req, res) => {
  try {
    const { point1, point2 } = req.body;

    if (!point1 || !point2) {
      return res.status(400).json({ message: 'Two points are required' });
    }

    if (!point1.latitude || !point1.longitude || !point2.latitude || !point2.longitude) {
      return res.status(400).json({ message: 'Both points must have latitude and longitude' });
    }

    if (!validateCoordinates(point1.latitude, point1.longitude) || 
        !validateCoordinates(point2.latitude, point2.longitude)) {
      return res.status(400).json({ message: 'Invalid coordinates provided' });
    }

    const distance = locationService.calculateDistance(point1, point2);
    res.json({ distance, unit: 'kilometers' });
  } catch (error) {
    console.error('Error calculating distance:', error);
    res.status(400).json({ message: error.message });
  }
};

// ✅ Find nearest location
exports.findNearestLocation = async (req, res) => {
  try {
    const { targetPoint, locations } = req.body;

    if (!targetPoint || !locations) {
      return res.status(400).json({ message: 'Target point and locations array are required' });
    }

    if (!targetPoint.latitude || !targetPoint.longitude) {
      return res.status(400).json({ message: 'Target point must have latitude and longitude' });
    }

    if (!validateCoordinates(targetPoint.latitude, targetPoint.longitude)) {
      return res.status(400).json({ message: 'Invalid target coordinates provided' });
    }

    if (!Array.isArray(locations) || locations.length === 0) {
      return res.status(400).json({ message: 'Locations must be a non-empty array' });
    }

    const nearest = locationService.findNearestLocation(targetPoint, locations);
    res.json(nearest);
  } catch (error) {
    console.error('Error finding nearest location:', error);
    res.status(400).json({ message: error.message });
  }
};

// ✅ Check delivery range
exports.checkDeliveryRange = async (req, res) => {
  try {
    const { customerLocation, vendorLocation, maxDistance = 10 } = req.body;

    if (!customerLocation || !vendorLocation) {
      return res.status(400).json({ message: 'Customer and vendor locations are required' });
    }

    if (!customerLocation.latitude || !customerLocation.longitude || 
        !vendorLocation.latitude || !vendorLocation.longitude) {
      return res.status(400).json({ message: 'Both locations must have latitude and longitude' });
    }

    if (!validateCoordinates(customerLocation.latitude, customerLocation.longitude) || 
        !validateCoordinates(vendorLocation.latitude, vendorLocation.longitude)) {
      return res.status(400).json({ message: 'Invalid coordinates provided' });
    }

    const result = locationService.isWithinDeliveryRange(customerLocation, vendorLocation, maxDistance);
    res.json(result);
  } catch (error) {
    console.error('Error checking delivery range:', error);
    res.status(400).json({ message: error.message });
  }
};

// ✅ Get location statistics
exports.getLocationStats = async (req, res) => {
  try {
    const { locations } = req.body;

    if (!Array.isArray(locations)) {
      return res.status(400).json({ message: 'Locations must be an array' });
    }

    const stats = locationService.getLocationStats(locations);
    res.json(stats);
  } catch (error) {
    console.error('Error getting location stats:', error);
    res.status(400).json({ message: error.message });
  }
};

// ✅ Search places (using Baato API)
exports.searchPlaces = async (req, res) => {
  try {
    const { query, limit = 10, latitude, longitude } = req.query;

    if (!query || query.trim().length === 0) {
      return res.status(400).json({ message: 'Search query is required' });
    }

    // This would typically call the Baato search API
    // For now, we'll return a mock response
    const mockResults = [
      {
        placeId: 'mock_1',
        name: query,
        address: `${query}, Kathmandu, Nepal`,
        coordinates: {
          latitude: latitude ? parseFloat(latitude) : 27.7172,
          longitude: longitude ? parseFloat(longitude) : 85.3240
        }
      }
    ];

    res.json({
      query,
      results: mockResults.slice(0, parseInt(limit)),
      total: mockResults.length
    });
  } catch (error) {
    console.error('Error searching places:', error);
    res.status(400).json({ message: error.message });
  }
};

// ✅ Get place details
exports.getPlaceDetails = async (req, res) => {
  try {
    const { placeId } = req.params;

    if (!placeId) {
      return res.status(400).json({ message: 'Place ID is required' });
    }

    // This would typically call the Baato places API
    // For now, we'll return a mock response
    const mockPlace = {
      placeId,
      name: 'Sample Place',
      address: 'Sample Address, Kathmandu, Nepal',
      coordinates: {
        latitude: 27.7172,
        longitude: 85.3240
      },
      type: 'establishment',
      phone: '+977-1-1234567',
      website: 'https://example.com'
    };

    res.json(mockPlace);
  } catch (error) {
    console.error('Error getting place details:', error);
    res.status(400).json({ message: error.message });
  }
}; 