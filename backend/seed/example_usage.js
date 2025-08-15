const axios = require('axios');

const BASE_URL = 'http://localhost:3000/api';

// Example 1: Search for Wine products
async function searchWineProducts() {
  try {
    console.log('🍷 Searching for Wine products...');
    const response = await axios.get(`${BASE_URL}/products/by-category?category=Wine`);
    
    console.log('Found vendors with wine products:');
    response.data.vendors.forEach((vendorData, index) => {
      const vendor = vendorData.vendor;
      const products = vendorData.products;
      
      console.log(`\n${index + 1}. ${vendor.storeName}`);
      console.log(`   Rating: ${vendor.storeRating} ⭐ (${vendor.storeReviews} reviews)`);
      console.log(`   Description: ${vendor.storeDescription}`);
      
      products.forEach(product => {
        console.log(`   - ${product.name}: ₹${product.price} (${product.unit})`);
        console.log(`     Delivery: ${product.deliveryTime} | Fee: ₹${product.deliveryFee}`);
      });
    });
    
    console.log(`\nTotal products found: ${response.data.total}`);
    
  } catch (error) {
    console.error('Error searching wine products:', error.response?.data || error.message);
  }
}

// Example 2: Search for different categories
async function searchMultipleCategories() {
  const categories = ['Wine', 'Bakery', 'Pharmacy', 'Grocery'];
  
  for (const category of categories) {
    try {
      console.log(`\n🔍 Searching for ${category} products...`);
      const response = await axios.get(`${BASE_URL}/products/by-category?category=${category}`);
      
      if (response.data.vendors.length > 0) {
        console.log(`Found ${response.data.vendors.length} vendor(s) with ${category} products:`);
        response.data.vendors.forEach(vendorData => {
          const vendor = vendorData.vendor;
          const products = vendorData.products;
          console.log(`  - ${vendor.storeName}: ${products.length} products`);
        });
      } else {
        console.log(`No ${category} products found`);
      }
      
    } catch (error) {
      console.error(`Error searching ${category} products:`, error.response?.data || error.message);
    }
  }
}

// Example 3: Search with pagination
async function searchWithPagination() {
  try {
    console.log('\n📄 Searching with pagination (page=1, limit=3)...');
    const response = await axios.get(`${BASE_URL}/products/by-category?category=Wine&page=1&limit=3`);
    
    console.log(`Page ${response.data.page} of ${response.data.totalPages}`);
    console.log(`Showing ${response.data.vendors.length} vendors out of ${response.data.total} total products`);
    
  } catch (error) {
    console.error('Error with pagination:', error.response?.data || error.message);
  }
}

// Run examples
async function runExamples() {
  console.log('🚀 Running Category Search API Examples\n');
  
  await searchWineProducts();
  await searchMultipleCategories();
  await searchWithPagination();
  
  console.log('\n✅ Examples completed!');
}

runExamples(); 