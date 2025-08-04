const express = require('express');
const router = express.Router();
const { authenticateToken: auth } = require('../middleware/auth');
const adminController = require('../controllers/adminController');

// Get all vendors
router.get('/', auth, adminController.getVendors);

// Get vendor by ID
router.get('/:id', auth, (req, res) => res.json({ message: 'Get vendor by ID - to be implemented' }));

// Update vendor
router.put('/:id', auth, adminController.editVendor);

// Delete vendor
router.delete('/:id', auth, (req, res) => res.json({ message: 'Delete vendor - to be implemented' }));

// Approve vendor
router.patch('/:id/approve', auth, adminController.approveVendor);

// Reject vendor
router.patch('/:id/reject', auth, adminController.rejectVendor);

// Get vendor performance
router.get('/:id/performance', auth, adminController.getVendorPerformance);

// Get vendor products
router.get('/:id/products', auth, adminController.getVendorProducts);

// Get vendor sales
router.get('/:id/sales', auth, adminController.getVendorSales);

// Get vendor analytics
router.get('/:id/analytics', auth, (req, res) => res.json({ message: 'Get vendor analytics - to be implemented' }));

module.exports = router; 