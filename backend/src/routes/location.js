const express = require('express');
const router = express.Router();
const locationController = require('../controllers/locationController');
const { authenticateToken } = require('../middleware/auth');

// Apply authentication to all routes
router.use(authenticateToken);

// Geocoding and reverse geocoding
router.post('/geocode', locationController.geocodeAddress);
router.post('/reverse-geocode', locationController.reverseGeocode);
router.post('/validate', locationController.validateAddress);

// Distance and location calculations
router.post('/distance', locationController.calculateDistance);
router.post('/nearest', locationController.findNearestLocation);
router.post('/delivery-range', locationController.checkDeliveryRange);

// Location statistics
router.post('/stats', locationController.getLocationStats);

// Place search and details
router.get('/search', locationController.searchPlaces);
router.get('/places/:placeId', locationController.getPlaceDetails);

module.exports = router; 