const axios = require('axios');

const BASE_URL = 'http://localhost:3000/api';

async function testDailyEssentials() {
  try {
    console.log('🧪 Testing Daily Essentials API...\n');

    // Test 1: Get all products
    console.log('1. Testing GET /products...');
    const productsResponse = await axios.get(`${BASE_URL}/products?limit=5`);
    console.log('✅ Products loaded:', productsResponse.data.data?.length || 0, 'products');
    
    if (productsResponse.data.data && productsResponse.data.data.length > 0) {
      const firstProduct = productsResponse.data.data[0];
      console.log('   First product:', firstProduct.name);
    }

    // Test 2: Get daily essentials
    console.log('\n2. Testing GET /daily-essentials...');
    const essentialsResponse = await axios.get(`${BASE_URL}/daily-essentials`);
    console.log('✅ Daily essentials loaded:', essentialsResponse.data.data?.length || 0, 'essentials');

    // Test 3: Add a product to daily essentials (if we have products)
    if (productsResponse.data.data && productsResponse.data.data.length > 0) {
      const productToAdd = productsResponse.data.data[0];
      console.log(`\n3. Testing POST /daily-essentials/add with product: ${productToAdd.name}...`);
      
      try {
        const addResponse = await axios.post(`${BASE_URL}/daily-essentials/add`, {
          productId: productToAdd._id
        });
        console.log('✅ Product added to daily essentials:', addResponse.data.message);
        
        // Test 4: Remove the product from daily essentials
        console.log(`\n4. Testing POST /daily-essentials/remove with product: ${productToAdd.name}...`);
        const removeResponse = await axios.post(`${BASE_URL}/daily-essentials/remove`, {
          productId: productToAdd._id
        });
        console.log('✅ Product removed from daily essentials:', removeResponse.data.message);
        
      } catch (error) {
        console.log('⚠️  Add/Remove test failed (might need admin auth):', error.response?.data?.message || error.message);
      }
    }

    console.log('\n🎉 All tests completed!');
    
  } catch (error) {
    console.error('❌ Test failed:', error.response?.data || error.message);
  }
}

// Run the test
testDailyEssentials(); 