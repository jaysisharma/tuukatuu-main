const axios = require('axios');

const BASE_URL = 'http://localhost:3000/api';

async function testServer() {
  try {
    console.log('🧪 Testing Backend Server...\n');

    // Test 1: Check if server is running
    console.log('1. Testing server connectivity...');
    try {
      const response = await axios.get(`${BASE_URL}/categories`);
      console.log('✅ Server is running and accessible');
      console.log(`   Categories endpoint working: ${response.data.success}\n`);
    } catch (error) {
      if (error.code === 'ECONNREFUSED') {
        console.log('❌ Server is not running. Please start the backend server first.');
        console.log('   Run: cd backend && npm start\n');
        return;
      } else {
        console.log('⚠️  Server is running but categories endpoint failed:', error.response?.data?.message || error.message, '\n');
      }
    }

    // Test 2: Test today-deals endpoint
    console.log('2. Testing today-deals endpoint...');
    try {
      const response = await axios.get(`${BASE_URL}/today-deals`);
      console.log('✅ Today-deals endpoint working');
      console.log(`   Response: ${response.data.message}\n`);
    } catch (error) {
      console.log('❌ Today-deals endpoint failed:', error.response?.data?.message || error.message, '\n');
    }

    // Test 3: Test today-deals stats endpoint
    console.log('3. Testing today-deals stats endpoint...');
    try {
      const response = await axios.get(`${BASE_URL}/today-deals/stats`);
      console.log('✅ Today-deals stats endpoint working');
      console.log(`   Response: ${response.data.message}\n`);
    } catch (error) {
      console.log('❌ Today-deals stats endpoint failed:', error.response?.data?.message || error.message, '\n');
    }

    // Test 4: Test T-Mart endpoints
    console.log('4. Testing T-Mart endpoints...');
    try {
      const response = await axios.get(`${BASE_URL}/tmart/deals`);
      console.log('✅ T-Mart deals endpoint working');
      console.log(`   Response: ${response.data.message}\n`);
    } catch (error) {
      console.log('❌ T-Mart deals endpoint failed:', error.response?.data?.message || error.message, '\n');
    }

    console.log('🎉 Server testing complete!');

  } catch (error) {
    console.error('❌ Test failed:', error.message);
  }
}

// Run the test
testServer();
