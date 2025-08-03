const mongoose = require('mongoose');
const Category = require('./src/models/Category');

mongoose.connect('mongodb://localhost:27017/first_db', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

const fixFeaturedCategoriesOrder = async () => {
  try {
    console.log('🔧 Fixing featured categories order...');

    // Define the proper order for enhanced categories
    const enhancedCategoriesOrder = [
      { name: 'Fruits & Vegetables', sortOrder: 1 },
      { name: 'Dairy & Eggs', sortOrder: 2 },
      { name: 'Beverages', sortOrder: 3 },
      { name: 'Snacks & Chocolates', sortOrder: 4 },
      { name: 'Bakery', sortOrder: 5 },
      { name: 'Meat & Fish', sortOrder: 6 },
      { name: 'Household', sortOrder: 7 },
      { name: 'Personal Care', sortOrder: 8 }
    ];

    // Update enhanced categories with proper sort order
    for (const categoryData of enhancedCategoriesOrder) {
      const category = await Category.findOne({ 
        name: { $regex: new RegExp(`^${categoryData.name}$`, 'i') } 
      });

      if (category) {
        category.sortOrder = categoryData.sortOrder;
        category.isFeatured = true;
        await category.save();
        console.log(`✅ Updated ${category.name} with sort order ${categoryData.sortOrder}`);
      } else {
        console.log(`⚠️ Category not found: ${categoryData.name}`);
      }
    }

    // Set old categories to higher sort orders (so they appear after enhanced ones)
    const oldCategories = ['Beer', 'Eggs', 'Test Category', 'Wine & Beerr', 'apples'];
    let oldSortOrder = 100; // Start from high number

    for (const categoryName of oldCategories) {
      const category = await Category.findOne({ 
        name: { $regex: new RegExp(`^${categoryName}$`, 'i') } 
      });

      if (category) {
        category.sortOrder = oldSortOrder++;
        await category.save();
        console.log(`✅ Updated ${category.name} with sort order ${category.sortOrder}`);
      }
    }

    // Show final featured categories in order
    const featuredCategories = await Category.getFeatured(8);
    console.log('\n🎯 Featured categories (in order):');
    featuredCategories.forEach((category, index) => {
      console.log(`${index + 1}. ${category.displayName} - ${category.productCount} products - Order: ${category.sortOrder}`);
    });

    console.log('\n🎉 Featured categories order fixed!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error fixing featured categories order:', error);
    process.exit(1);
  }
};

fixFeaturedCategoriesOrder(); 