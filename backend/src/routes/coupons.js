const express = require('express');
const router = express.Router();
const couponsController = require('../controllers/couponsController');
const { authenticateToken, authorizeRoles } = require('../middleware/auth');

router.get('/', couponsController.getCoupons);
router.post('/', authenticateToken, authorizeRoles('admin'), couponsController.createCoupon);
router.put('/:id', authenticateToken, authorizeRoles('admin'), couponsController.updateCoupon);
router.delete('/:id', authenticateToken, authorizeRoles('admin'), couponsController.deleteCoupon);

module.exports = router; 