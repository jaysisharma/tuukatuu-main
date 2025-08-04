const express = require('express');
const router = express.Router();
const todayDealsController = require('../controllers/todayDealsController');
const { authenticateToken } = require('../middleware/auth');
const upload = require('../middleware/upload');

// Public routes
router.get('/today-deals', todayDealsController.getTodayDeals);
router.get('/today-deals/stats', todayDealsController.getTodayDealsStats);
router.get('/featured-deals', todayDealsController.getFeaturedDeals);
router.get('/deals/category/:category', todayDealsController.getDealsByCategory);
router.get('/deals/:dealId', todayDealsController.getDealById);

// Admin routes (protected)
router.post('/deals', authenticateToken, todayDealsController.createDeal);
router.put('/deals/:dealId', authenticateToken, todayDealsController.updateDeal);
router.delete('/deals/:dealId', authenticateToken, todayDealsController.deleteDeal);

// Image upload route
router.post('/upload-image', authenticateToken, upload.single('image'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No image file provided'
      });
    }

    // Upload to cloudinary or save to local storage
    const imageUrl = req.file.path; // For local storage
    // const imageUrl = await uploadToCloudinary(req.file); // For cloudinary

    res.json({
      success: true,
      data: { imageUrl },
      message: 'Image uploaded successfully'
    });
  } catch (error) {
    console.error('Error uploading image:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to upload image',
      error: error.message
    });
  }
});

module.exports = router; 