const express = require('express');
const router = express.Router();
const categoryController = require('../controllers/categoryController');
const { authenticateToken, requireAdmin } = require('../middleware/auth');
const upload = require('../middleware/upload');

// Apply admin middleware to all routes
router.use(authenticateToken, requireAdmin);

// Get all categories with pagination and filters
router.get('/', categoryController.getAllCategories);

// Get category statistics
router.get('/stats', categoryController.getCategoryStats);

// Get category by ID
router.get('/:id', categoryController.getCategoryById);

// Create new category
router.post('/', categoryController.createCategory);

// Update category
router.put('/:id', categoryController.updateCategory);

// Delete category
router.delete('/:id', categoryController.deleteCategory);

// Toggle category featured status
router.patch('/:id/toggle-featured', categoryController.toggleFeatured);

// Update category sort order
router.patch('/:id/sort-order', categoryController.updateSortOrder);

// Create combined category
router.post('/combined', categoryController.createCombinedCategory);

// Bulk update categories
router.post('/bulk-update', categoryController.bulkUpdateCategories);

// Upload category image
router.post('/upload-image', upload.single('image'), categoryController.uploadImage);

// Upload image for specific category
router.post('/:id/upload-image', upload.single('image'), categoryController.uploadCategoryImage);

// Auto-create category from product
router.post('/auto-create', categoryController.autoCreateFromProduct);

module.exports = router; 