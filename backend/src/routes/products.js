const express = require('express');
const router = express.Router();
const productsController = require('../controllers/productsController');
const { authenticateToken, authorizeRoles } = require('../middleware/auth');

router.get('/', productsController.getAllProducts);
router.get('/by-category', productsController.getProductsByCategory);
router.get('/my', authenticateToken, authorizeRoles('vendor'), productsController.getMyProducts);
router.post('/', authenticateToken, authorizeRoles('admin', 'vendor'), productsController.createProduct);
router.put('/:id', authenticateToken, authorizeRoles('admin', 'vendor'), productsController.updateProduct);
router.delete('/:id', authenticateToken, authorizeRoles('admin', 'vendor'), productsController.deleteProduct);

module.exports = router; 