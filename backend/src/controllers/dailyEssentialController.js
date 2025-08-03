const Product = require('../models/Product');



exports.getDailyEssentials = async (req, res) => {
  try {
    const dailyEssentials = await Product.find({ dailyEssential: true });
    console.log(dailyEssentials);
    res.status(200).json({
      success: true,
      data: dailyEssentials
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching daily essentials',
      error: error.message
    });
  }
}

exports.addDailyEssential = async (req, res) => {
  try{
    const { productId, isFeatured = false } = req.body;
    const product = await Product.findById(productId);
    if(!product){
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }
    product.dailyEssential = true;
    product.isFeaturedDailyEssential = isFeatured;
    await product.save(); 
    res.status(200).json({
      success: true,
      message: 'Product added to daily essentials',
      data: product
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error adding product to daily essentials',
      error: error.message
    });
  }
}

exports.removeDailyEssential = async (req, res) => {
  try{
    const { productId } = req.body;
    const product = await Product.findById(productId);
    if(!product){
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }
    product.dailyEssential = false;
    product.isFeaturedDailyEssential = false;
    await product.save();
    res.status(200).json({
      success: true,
      message: 'Product removed from daily essentials',
      data: product
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error removing product from daily essentials',
      error: error.message
    });
  }
}

exports.toggleFeaturedDailyEssential = async (req, res) => {
  try{
    const { productId } = req.body;
    const product = await Product.findById(productId);
    if(!product){
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }
    
    if (!product.dailyEssential) {
      return res.status(400).json({
        success: false,
        message: 'Product must be a daily essential to be featured'
      });
    }
    
    product.isFeaturedDailyEssential = !product.isFeaturedDailyEssential;
    await product.save();
    
    const message = product.isFeaturedDailyEssential 
      ? 'Product marked as featured daily essential'
      : 'Product unmarked as featured daily essential';
      
    res.status(200).json({
      success: true,
      message: message,
      data: product
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error toggling featured status',
      error: error.message
    });
  }
}