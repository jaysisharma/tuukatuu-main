const express = require('express');
const router = express.Router();
const ordersController = require('../controllers/ordersController');
const { authenticateToken, authorizeRoles } = require('../middleware/auth');

// Order placement and management
router.post('/', authenticateToken, authorizeRoles('customer'), ordersController.placeOrder);
router.post('/tmart', authenticateToken, authorizeRoles('customer'), ordersController.placeTmartOrder);
router.get('/', authenticateToken, ordersController.getOrders);
router.get('/vendor/my', authenticateToken, authorizeRoles('vendor'), ordersController.getVendorOrders);
router.get('/customer/my', authenticateToken, authorizeRoles('customer'), ordersController.getCustomerOrders);
router.get('/search', authenticateToken, ordersController.searchOrders);

// Order details and status
router.get('/:id', authenticateToken, ordersController.getOrderDetails);
router.put('/:id/status', authenticateToken, authorizeRoles('vendor', 'rider', 'admin'), ordersController.updateOrderStatus);

// Rider assignment and management
router.post('/:id/assign-rider', authenticateToken, authorizeRoles('admin', 'vendor'), ordersController.assignRider);
router.post('/:id/accept', authenticateToken, authorizeRoles('rider'), ordersController.acceptOrder);
router.post('/:id/reject', authenticateToken, authorizeRoles('rider'), ordersController.rejectOrder);
router.put('/:id/rider-location', authenticateToken, authorizeRoles('rider'), ordersController.updateRiderLocation);

// Order cancellation and rating
router.post('/:id/cancel', authenticateToken, ordersController.cancelOrder);
router.post('/:id/rate', authenticateToken, authorizeRoles('customer'), ordersController.rateOrder);

// Analytics and reporting
router.get('/analytics/dashboard', authenticateToken, authorizeRoles('admin', 'vendor'), ordersController.getOrderAnalytics);
router.get('/analytics/earnings', authenticateToken, authorizeRoles('rider'), ordersController.getRiderEarnings);

// Rider-specific endpoints
router.get('/nearby/orders', authenticateToken, authorizeRoles('rider'), ordersController.getNearbyOrders);

// Order timeline and history
router.get('/:id/timeline', authenticateToken, ordersController.getOrderTimeline);

module.exports = router; 