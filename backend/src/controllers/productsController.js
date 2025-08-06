const Product = require('../models/Product');

exports.getAllProducts = async (req, res) => {
  try {
    const { vendorId, search, page = 1, limit = 20, isPopular, isFeatured } = req.query;
    const query = { isAvailable: true };
    
    if (vendorId) query.vendorId = vendorId;
    if (isPopular === 'true') query.isPopular = true;
    if (isFeatured === 'true') query.isFeatured = true;
    
    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { category: { $regex: search, $options: 'i' } },
      ];
    }
    
    const skip = (parseInt(page) - 1) * parseInt(limit);
    const [products, total] = await Promise.all([
      Product.find(query)
        .populate({ 
          path: 'vendorId', 
          select: 'storeName storeDescription storeImage storeBanner storeRating storeReviews storeAddress vendorType vendorSubType storeTags storeCategories' 
        })
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(parseInt(limit)),
      Product.countDocuments(query)
    ]);
    
    const totalPages = Math.ceil(total / parseInt(limit));
    
    res.json({ 
      data: products, 
      total,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        totalPages
      }
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getProductsByVendorType = async (req, res) => {
  try {
    const { vendorType, vendorSubType, page = 1, limit = 20 } = req.query;
    
    if (!vendorType) {
      return res.status(400).json({ message: 'vendorType parameter is required' });
    }

    const query = {
      isAvailable: true,
      vendorId: { $exists: true, $ne: null }
    };

    if (vendorType) {
      query.vendorType = vendorType;
    }

    if (vendorSubType) {
      query.vendorSubType = vendorSubType;
    }

    const skip = (parseInt(page) - 1) * parseInt(limit);

    // Get products with vendor details
    const products = await Product.find(query)
      .populate({
        path: 'vendorId',
        select: 'storeName storeDescription storeImage storeRating storeReviews storeAddress vendorType vendorSubType'
      })
      .sort({ rating: -1, reviews: -1 })
      .skip(skip)
      .limit(parseInt(limit));

    // Group products by vendor
    const vendorsWithProducts = {};
    
    products.forEach(product => {
      if (!product.vendorId || !product.vendorId._id) {
        console.log('Skipping product without valid vendorId:', product._id);
        return;
      }

      const vendorId = product.vendorId._id.toString();
      
      if (!vendorsWithProducts[vendorId]) {
        vendorsWithProducts[vendorId] = {
          vendor: {
            _id: product.vendorId._id,
            storeName: product.vendorId.storeName || 'Unknown Store',
            storeDescription: product.vendorId.storeDescription || '',
            storeImage: product.vendorId.storeImage || '',
            storeRating: product.vendorId.storeRating || 0,
            storeReviews: product.vendorId.storeReviews || 0,
            storeAddress: product.vendorId.storeAddress || '',
            vendorType: product.vendorId.vendorType || 'store',
            vendorSubType: product.vendorId.vendorSubType || ''
          },
          products: []
        };
      }
      
      vendorsWithProducts[vendorId].products.push({
        _id: product._id,
        name: product.name,
        price: product.price,
        imageUrl: product.imageUrl,
        description: product.description,
        unit: product.unit,
        rating: product.rating,
        reviews: product.reviews,
        isPopular: product.isPopular,
        isFeatured: product.isFeatured,
        vendorType: product.vendorType,
        vendorSubType: product.vendorSubType
      });
    });

    const total = await Product.countDocuments(query);
    const totalPages = Math.ceil(total / parseInt(limit));

    console.log(`🔍 Found ${products.length} products for vendorType: ${vendorType}, vendorSubType: ${vendorSubType}`);

    res.json({
      success: true,
      data: Object.values(vendorsWithProducts),
      total,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        totalPages
      },
      filters: { vendorType, vendorSubType }
    });
  } catch (err) {
    console.error('Error getting products by vendor type:', err);
    res.status(500).json({ message: err.message });
  }
};

exports.getProductsByCategory = async (req, res) => {
  try {
    const { category, page = 1, limit = 20 } = req.query;
    
    if (!category) {
      return res.status(400).json({ message: 'Category parameter is required' });
    }

    let query = {
      isAvailable: true,
      vendorId: { $exists: true, $ne: null }
    };

    // Special handling for Pharmacy category
    if (category.toLowerCase() === 'pharmacy') {
      query.vendorSubType = 'pharmacy';
    } else {
      query.category = { $regex: category, $options: 'i' };
    }

    const skip = (parseInt(page) - 1) * parseInt(limit);

    // Get products with vendor details
    const products = await Product.find(query)
      .populate({
        path: 'vendorId',
        select: 'storeName storeDescription storeImage storeRating storeReviews storeAddress'
      })
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(parseInt(limit));

    // Group products by vendor
    const vendorsWithProducts = {};
    
    products.forEach(product => {
      // Check if vendorId exists and is populated
      if (!product.vendorId || !product.vendorId._id) {
        console.log('Skipping product without valid vendorId:', product._id);
        return;
      }

      const vendorId = product.vendorId._id.toString();
      
      if (!vendorsWithProducts[vendorId]) {
        vendorsWithProducts[vendorId] = {
          vendor: {
            _id: product.vendorId._id,
            storeName: product.vendorId.storeName || 'Unknown Store',
            storeDescription: product.vendorId.storeDescription || '',
            storeImage: product.vendorId.storeImage || '',
            storeRating: product.vendorId.storeRating || 0,
            storeReviews: product.vendorId.storeReviews || 0,
            storeAddress: product.vendorId.storeAddress || ''
          },
          products: []
        };
      }
      
      vendorsWithProducts[vendorId].products.push({
        _id: product._id,
        name: product.name,
        price: product.price,
        imageUrl: product.imageUrl,
        description: product.description,
        unit: product.unit,
        deliveryTime: product.deliveryTime,
        deliveryFee: product.deliveryFee,
        rating: product.rating,
        reviews: product.reviews
      });
    });

    // Convert to array format
    const result = Object.values(vendorsWithProducts);

    // Get total count for pagination
    const total = await Product.countDocuments(query);

    res.json({
      vendors: result,
      total,
      page: parseInt(page),
      limit: parseInt(limit),
      totalPages: Math.ceil(total / parseInt(limit))
    });

  } catch (err) {
    console.error('Error in getProductsByCategory:', err);
    res.status(500).json({ message: err.message });
  }
};

exports.createProduct = async (req, res) => {
  try {
    const product = new Product({ ...req.body, vendorId: req.user.id });
    await product.save();
    res.status(201).json(product);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

exports.getMyProducts = async (req, res) => {
  try {
    const products = await Product.find({ vendorId: req.user.id });
    res.json(products);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.updateProduct = async (req, res) => {
  try {
    let product;
    if (req.user.role === 'vendor') {
      product = await Product.findOneAndUpdate({ _id: req.params.id, vendorId: req.user.id }, req.body, { new: true });
    } else {
      product = await Product.findByIdAndUpdate(req.params.id, req.body, { new: true });
    }
    if (!product) return res.status(404).json({ message: 'Product not found or not authorized' });
    res.json(product);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

exports.deleteProduct = async (req, res) => {
  try {
    const product = await Product.findByIdAndDelete(req.params.id);
    if (!product) {
      return res.status(404).json({ message: 'Product not found' });
    }
    res.json({ message: 'Product deleted successfully' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Get similar products
exports.getSimilarProducts = async (req, res) => {
  try {
    const { productId, limit = 6 } = req.query;
    
    if (!productId) {
      return res.status(400).json({
        success: false,
        message: 'Product ID is required'
      });
    }

    // First get the current product to find its category
    const currentProduct = await Product.findById(productId);
    if (!currentProduct) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    // Find similar products based on category and other criteria
    const similarProducts = await Product.find({
      _id: { $ne: productId }, // Exclude current product
      isAvailable: true,
      $or: [
        { category: currentProduct.category }, // Same category
        { tags: { $in: currentProduct.tags || [] } }, // Similar tags
        { brand: currentProduct.brand }, // Same brand
        { vendorId: currentProduct.vendorId }, // Same vendor
        { 
          price: { 
            $gte: currentProduct.price * 0.7, 
            $lte: currentProduct.price * 1.3 
          } 
        }, // Similar price range
      ]
    })
    .limit(parseInt(limit))
    .sort({ 
      rating: -1, 
      reviews: -1, 
      isPopular: 1, 
      isFeatured: 1 
    });

    res.json({
      success: true,
      data: similarProducts,
      total: similarProducts.length
    });
  } catch (err) {
    console.error('❌ Error in getSimilarProducts:', err);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch similar products'
    });
  }
}; 