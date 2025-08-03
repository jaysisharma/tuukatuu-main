const express = require('express');
const router = express.Router();
const categoryController = require('../controllers/categoryController');
const { authenticateToken, requireAdmin } = require('../middleware/auth');
const upload = require('../middleware/upload');

// Public routes (for TMart)
router.get('/featured', categoryController.getFeaturedCategories);
router.get('/hierarchy', categoryController.getCategoryHierarchy);

// Admin routes (require authentication and admin role)
router.use(authenticateToken, requireAdmin);

// CRUD operations
router.get('/', categoryController.getAllCategories);
router.get('/stats', categoryController.getCategoryStats);
router.get('/:categoryId', categoryController.getCategoryById);
router.post('/', categoryController.createCategory);
router.put('/:categoryId', categoryController.updateCategory);
router.delete('/:categoryId', categoryController.deleteCategory);

// Category management
router.post('/combined', categoryController.createCombinedCategory);
router.patch('/:categoryId/toggle-featured', categoryController.toggleFeatured);
router.patch('/:categoryId/sort-order', categoryController.updateSortOrder);
router.post('/bulk-update', categoryController.bulkUpdateCategories);

// Image upload
router.post('/upload-image', upload.single('image'), categoryController.uploadImage);
router.post('/:categoryId/upload-image', upload.single('image'), categoryController.uploadCategoryImage);

// Auto-create from product
router.post('/auto-create', categoryController.autoCreateFromProduct);

module.exports = router; 