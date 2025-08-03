const express = require('express');
const router = express.Router();
const addressesController = require('../controllers/addressesController');
const { authenticateToken } = require('../middleware/auth');

// Apply authentication to all routes
router.use(authenticateToken);

// Basic CRUD operations
router.get('/', addressesController.getAddresses);
router.get('/default', addressesController.getDefaultAddress);
router.post('/', addressesController.createAddress);
router.put('/:id', addressesController.updateAddress);
router.delete('/:id', addressesController.deleteAddress);

// Address management
router.patch('/:id/default', addressesController.setDefaultAddress);

// Search and discovery
router.get('/search', addressesController.searchAddresses);
router.get('/nearby', addressesController.findNearbyAddresses);

// Validation and geocoding
router.post('/validate', addressesController.validateAddress);

// Analytics and statistics
router.get('/stats', addressesController.getAddressStats);

// Bulk operations
router.put('/bulk/update', addressesController.bulkUpdateAddresses);
router.post('/import', addressesController.importAddresses);
router.get('/export', addressesController.exportAddresses);

module.exports = router;
