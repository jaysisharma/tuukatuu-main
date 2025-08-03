const express = require('express');
const router = express.Router();
const bannersController = require('../controllers/bannersController');
const { authenticateToken, authorizeRoles } = require('../middleware/auth');

router.get('/', bannersController.getBanners);
router.post('/', authenticateToken, authorizeRoles('admin'), bannersController.createBanner);
router.put('/:id', authenticateToken, authorizeRoles('admin'), bannersController.updateBanner);
router.delete('/:id', authenticateToken, authorizeRoles('admin'), bannersController.deleteBanner);

module.exports = router; 