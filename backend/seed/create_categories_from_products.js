const mongoose = require('mongoose');
const Product = require('../src/models/Product');
const Category = require('../src/models/Category');
require('dotenv').config();

async function createCategoriesFromProducts() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/first_db');
    console.log('Connected to MongoDB');

    // Get all unique categories from products
    const products = await Product.find({});
    const uniqueCategories = [...new Set(products.map(p => p.category))];
    
    console.log(`Found ${uniqueCategories.length} unique categories:`, uniqueCategories);

    // Create categories for each unique category name
    for (const categoryName of uniqueCategories) {
      // Check if category already exists
      const existingCategory = await Category.findOne({ name: categoryName });
      
      if (!existingCategory) {
        // Count products in this category
        const productCount = await Product.countDocuments({ category: categoryName });
        
        // Create new category
        const newCategory = new Category({
          name: categoryName,
          displayName: categoryName,
          description: `Category for ${categoryName} products`,
          color: getRandomColor(),
          isActive: true,
          isFeatured: false,
          sortOrder: 0,
          productCount: productCount
        });
        
        await newCategory.save();
        console.log(`✅ Created category: ${categoryName} (${productCount} products)`);
      } else {
        console.log(`⏭️  Category already exists: ${categoryName}`);
      }
    }

    // Update product counts for all categories
    const categories = await Category.find({});
    for (const category of categories) {
      const productCount = await Product.countDocuments({ category: category.name });
      if (category.productCount !== productCount) {
        category.productCount = productCount;
        await category.save();
        console.log(`📊 Updated product count for ${category.name}: ${productCount}`);
      }
    }

    console.log('\n🎉 Categories creation completed!');
    console.log(`Total categories: ${categories.length}`);
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error creating categories:', error);
    process.exit(1);
  }
}

function getRandomColor() {
  const colors = ['green', 'blue', 'orange', 'red', 'purple', 'cyan', 'indigo', 'pink', 'teal', 'amber', 'deepPurple', 'lightBlue', 'yellow', 'brown'];
  return colors[Math.floor(Math.random() * colors.length)];
}

createCategoriesFromProducts();
