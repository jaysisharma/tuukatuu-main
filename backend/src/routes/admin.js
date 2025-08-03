const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');
const { authenticateToken, authorizeRoles } = require('../middleware/auth');

router.use(authenticateToken, authorizeRoles('admin'));

// User management
router.get('/users', adminController.getUsers);
router.post('/users', adminController.createUser);
router.patch('/users/:id/block', adminController.blockUser);
router.patch('/users/:id/activate', adminController.activateUser);
router.patch('/users/:id/role', adminController.updateUserRole);
router.delete('/users/:id', adminController.deleteUser);

// Vendor management
router.get('/vendors', adminController.getVendors);
router.patch('/vendors/:id/approve', adminController.approveVendor);
router.patch('/vendors/:id/reject', adminController.rejectVendor);
router.patch('/vendors/:id', adminController.editVendor);
router.get('/vendors/:id/performance', adminController.getVendorPerformance);
router.get('/vendors/:id/products', adminController.getVendorProducts);
router.get('/vendors/:id/sales', adminController.getVendorSales);

// Rider management
router.get('/riders', adminController.getRiders);
router.get('/riders/analytics', adminController.getRiderAnalytics);
router.get('/riders/:riderId', adminController.getRiderById);
router.post('/riders', adminController.createRider);
router.put('/riders/:riderId', adminController.updateRider);
router.patch('/riders/:riderId/approve', adminController.approveRider);
router.patch('/riders/:riderId/block', adminController.blockRider);
router.delete('/riders/:riderId', adminController.deleteRider);
router.get('/riders/:riderId/performance', adminController.getRiderPerformance);

// Dashboard and analytics
router.get('/dashboard', adminController.getDashboardStats);
router.get('/sales-analytics', adminController.getSalesAnalytics);

module.exports = router; 