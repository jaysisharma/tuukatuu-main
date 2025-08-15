const mongoose = require('mongoose');
const Category = require('../src/models/Category');

mongoose.connect('mongodb://localhost:27017/first_db', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

const enhanceFeaturedCategories = async () => {
  try {
    console.log('🎨 Enhancing featured categories...');

    // Define enhanced featured categories with proper icons, images, and colors
    const enhancedCategories = [
      {
        name: 'Fruits & Vegetables',
        displayName: 'Fruits & Vegetables',
        description: 'Fresh fruits and vegetables',
        iconUrl: 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=200&h=200&fit=crop',
        imageUrl: 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=400&h=200&fit=crop',
        color: 'green',
        sortOrder: 1,
        combinedCategories: ['apples', 'Fruits', 'Vegetables']
      },
      {
        name: 'Dairy & Eggs',
        displayName: 'Dairy & Eggs',
        description: 'Fresh dairy products and eggs',
        iconUrl: 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=200&h=200&fit=crop',
        imageUrl: 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400&h=200&fit=crop',
        color: 'blue',
        sortOrder: 2,
        combinedCategories: ['Eggs', 'cheese', 'milk', 'yogurt']
      },
      {
        name: 'Beverages',
        displayName: 'Beverages',
        description: 'Refreshing drinks and beverages',
        iconUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=200&h=200&fit=crop',
        imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=400&h=200&fit=crop',
        color: 'cyan',
        sortOrder: 3,
        combinedCategories: ['Beer', 'wine', 'juice', 'soda']
      },
      {
        name: 'Snacks & Chocolates',
        displayName: 'Snacks & Chocolates',
        description: 'Delicious snacks and chocolates',
        iconUrl: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=200&h=200&fit=crop',
        imageUrl: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&h=200&fit=crop',
        color: 'purple',
        sortOrder: 4,
        combinedCategories: ['Chocolate', 'snacks', 'cookies']
      },
      {
        name: 'Bakery',
        displayName: 'Bakery',
        description: 'Fresh baked goods',
        iconUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=200&h=200&fit=crop',
        imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&h=200&fit=crop',
        color: 'orange',
        sortOrder: 5,
        combinedCategories: ['bread', 'pastries', 'cakes']
      },
      {
        name: 'Meat & Fish',
        displayName: 'Meat & Fish',
        description: 'Fresh meat and fish',
        iconUrl: 'https://images.unsplash.com/photo-1516594798947-e65505dbb29d?w=200&h=200&fit=crop',
        imageUrl: 'https://images.unsplash.com/photo-1516594798947-e65505dbb29d?w=400&h=200&fit=crop',
        color: 'red',
        sortOrder: 6,
        combinedCategories: ['meat', 'fish', 'chicken']
      },
      {
        name: 'Household',
        displayName: 'Household',
        description: 'Household essentials',
        iconUrl: 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=200&h=200&fit=crop',
        imageUrl: 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=200&fit=crop',
        color: 'indigo',
        sortOrder: 7,
        combinedCategories: ['cleaning', 'detergents', 'paper']
      },
      {
        name: 'Personal Care',
        displayName: 'Personal Care',
        description: 'Personal care products',
        iconUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=200&h=200&fit=crop',
        imageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400&h=200&fit=crop',
        color: 'pink',
        sortOrder: 8,
        combinedCategories: ['shampoo', 'soap', 'toothpaste']
      }
    ];

    // Update or create each enhanced category
    for (const categoryData of enhancedCategories) {
      const existingCategory = await Category.findOne({ 
        name: { $regex: new RegExp(`^${categoryData.name}$`, 'i') } 
      });

      if (existingCategory) {
        // Update existing category
        existingCategory.displayName = categoryData.displayName;
        existingCategory.description = categoryData.description;
        existingCategory.iconUrl = categoryData.iconUrl;
        existingCategory.imageUrl = categoryData.imageUrl;
        existingCategory.color = categoryData.color;
        existingCategory.sortOrder = categoryData.sortOrder;
        existingCategory.isFeatured = true;
        existingCategory.combinedCategories = categoryData.combinedCategories;
        
        await existingCategory.save();
        console.log(`✅ Updated category: ${categoryData.name}`);
      } else {
        // Create new category
        const newCategory = new Category({
          ...categoryData,
          isActive: true,
          isFeatured: true
        });
        
        await newCategory.save();
        console.log(`✅ Created category: ${categoryData.name}`);
      }
    }

    // Update product counts for all categories
    const Product = require('../src/models/Product');
    const allCategories = await Category.find({ isFeatured: true });
    
    for (const category of allCategories) {
      await category.updateProductCount();
      console.log(`📊 Updated product count for ${category.name}: ${category.productCount}`);
    }

    // Show final featured categories
    const featuredCategories = await Category.getFeatured(8);
    console.log('\n🎯 Featured categories:');
    featuredCategories.forEach((category, index) => {
      console.log(`${index + 1}. ${category.displayName} - ${category.productCount} products - Order: ${category.sortOrder}`);
    });

    console.log('\n🎉 Featured categories enhancement completed!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error enhancing featured categories:', error);
    process.exit(1);
  }
};

enhanceFeaturedCategories(); 