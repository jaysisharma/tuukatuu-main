const axios = require('axios');
const { validateCoordinates, calculateDistance } = require('../utils/locationUtils');

class LocationService {
  constructor() {
    // You can configure different geocoding services here
    this.geocodingService = process.env.GEOCODING_SERVICE || 'baato';
    this.apiKey = process.env.BAATO_API_KEY || 'bpk.c4NQriUA4yoDwdocKtxMB4dwZyoR7uA2jLAo43fTIa4z';
  }

  /**
   * Geocode an address to get coordinates
   * @param {string} address - The address to geocode
   * @returns {Object} - { latitude, longitude, formattedAddress }
   */
  async geocodeAddress(address) {
    try {
      if (!address || address.trim().length === 0) {
        throw new Error('Address is required');
      }

      if (this.geocodingService === 'baato') {
        return await this.geocodeWithBaato(address);
      } else {
        throw new Error('Unsupported geocoding service');
      }
    } catch (error) {
      console.error('Error geocoding address:', error);
      throw new Error(`Failed to geocode address: ${error.message}`);
    }
  }

  /**
   * Reverse geocode coordinates to get address
   * @param {number} latitude - Latitude
   * @param {number} longitude - Longitude
   * @returns {Object} - Address information
   */
  async reverseGeocode(latitude, longitude) {
    try {
      if (!validateCoordinates(latitude, longitude)) {
        throw new Error('Invalid coordinates provided');
      }

      if (this.geocodingService === 'baato') {
        return await this.reverseGeocodeWithBaato(latitude, longitude);
      } else {
        throw new Error('Unsupported geocoding service');
      }
    } catch (error) {
      console.error('Error reverse geocoding:', error);
      throw new Error(`Failed to reverse geocode: ${error.message}`);
    }
  }

  /**
   * Geocode using Baato API
   * @param {string} address - Address to geocode
   * @returns {Object} - Geocoded result
   */
  async geocodeWithBaato(address) {
    try {
      const response = await axios.get('https://api.baato.io/api/v1/search', {
        params: {
          key: this.apiKey,
          q: address,
          limit: 1
        }
      });

      if (response.data && response.data.data && response.data.data.length > 0) {
        const result = response.data.data[0];
        return {
          latitude: result.centroid.lat,
          longitude: result.centroid.lon,
          formattedAddress: result.address,
          placeId: result.placeId,
          name: result.name
        };
      } else {
        throw new Error('No results found for this address');
      }
    } catch (error) {
      console.error('Baato geocoding error:', error);
      throw new Error('Failed to geocode with Baato API');
    }
  }

  /**
   * Reverse geocode using Baato API
   * @param {number} latitude - Latitude
   * @param {number} longitude - Longitude
   * @returns {Object} - Address information
   */
  async reverseGeocodeWithBaato(latitude, longitude) {
    try {
      const response = await axios.get('https://api.baato.io/api/v1/reverse', {
        params: {
          key: this.apiKey,
          lat: latitude,
          lon: longitude
        }
      });

      if (response.data && response.data.data) {
        const data = response.data.data;
        return {
          address: data.address,
          latitude: latitude,
          longitude: longitude,
          placeId: data.placeId,
          name: data.name
        };
      } else {
        throw new Error('No address found for these coordinates');
      }
    } catch (error) {
      console.error('Baato reverse geocoding error:', error);
      throw new Error('Failed to reverse geocode with Baato API');
    }
  }

  /**
   * Validate and format an address
   * @param {Object} addressData - Address data to validate
   * @returns {Object} - Validated and formatted address
   */
  async validateAndFormatAddress(addressData) {
    try {
      const { address, coordinates } = addressData;

      // If coordinates are provided, validate them
      if (coordinates) {
        if (!validateCoordinates(coordinates.latitude, coordinates.longitude)) {
          throw new Error('Invalid coordinates provided');
        }
      }

      // If address is provided but no coordinates, geocode it
      if (address && !coordinates) {
        const geocoded = await this.geocodeAddress(address);
        return {
          ...addressData,
          coordinates: {
            latitude: geocoded.latitude,
            longitude: geocoded.longitude
          },
          formattedAddress: geocoded.formattedAddress,
          isVerified: true,
          validatedAt: new Date()
        };
      }

      // If coordinates are provided but no formatted address, reverse geocode
      if (coordinates && !address) {
        const reverseGeocoded = await this.reverseGeocode(coordinates.latitude, coordinates.longitude);
        return {
          ...addressData,
          address: reverseGeocoded.address,
          formattedAddress: reverseGeocoded.address,
          isVerified: true,
          validatedAt: new Date()
        };
      }

      // If both are provided, validate and return
      return {
        ...addressData,
        isVerified: true,
        validatedAt: new Date()
      };
    } catch (error) {
      console.error('Error validating address:', error);
      throw error;
    }
  }

  /**
   * Calculate distance between two points
   * @param {Object} point1 - { latitude, longitude }
   * @param {Object} point2 - { latitude, longitude }
   * @returns {number} - Distance in kilometers
   */
  calculateDistance(point1, point2) {
    return calculateDistance(point1.latitude, point1.longitude, point2.latitude, point2.longitude);
  }

  /**
   * Find the nearest location from a list of locations
   * @param {Object} targetPoint - { latitude, longitude }
   * @param {Array} locations - Array of location objects with coordinates
   * @returns {Object} - Nearest location with distance
   */
  findNearestLocation(targetPoint, locations) {
    try {
      if (!locations || locations.length === 0) {
        throw new Error('No locations provided');
      }

      let nearest = null;
      let minDistance = Infinity;

      for (const location of locations) {
        if (location.coordinates) {
          const distance = this.calculateDistance(targetPoint, location.coordinates);
          if (distance < minDistance) {
            minDistance = distance;
            nearest = { ...location, distance };
          }
        }
      }

      return nearest;
    } catch (error) {
      console.error('Error finding nearest location:', error);
      throw error;
    }
  }

  /**
   * Check if a location is within delivery range
   * @param {Object} customerLocation - Customer location
   * @param {Object} vendorLocation - Vendor location
   * @param {number} maxDistance - Maximum delivery distance in km
   * @returns {Object} - { isWithinRange, distance }
   */
  isWithinDeliveryRange(customerLocation, vendorLocation, maxDistance = 10) {
    try {
      const distance = this.calculateDistance(customerLocation, vendorLocation);
      return {
        isWithinRange: distance <= maxDistance,
        distance: distance,
        maxDistance: maxDistance
      };
    } catch (error) {
      console.error('Error checking delivery range:', error);
      throw error;
    }
  }

  /**
   * Get location statistics
   * @param {Array} locations - Array of location objects
   * @returns {Object} - Location statistics
   */
  getLocationStats(locations) {
    try {
      if (!locations || locations.length === 0) {
        return {
          total: 0,
          verified: 0,
          averageDistance: 0
        };
      }

      const verified = locations.filter(loc => loc.isVerified).length;
      const total = locations.length;

      return {
        total,
        verified,
        verificationRate: total > 0 ? (verified / total) * 100 : 0
      };
    } catch (error) {
      console.error('Error getting location stats:', error);
      throw error;
    }
  }
}

module.exports = new LocationService(); 