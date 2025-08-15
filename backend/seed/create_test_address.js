const mongoose = require('mongoose');
require('dotenv').config();

// Import models
const User = require('../src/models/User');
const Address = require('../src/models/Address');

async function createTestAddress() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/tuukatuu');
    console.log('Connected to MongoDB');

    // Find a user (use the first user found)
    const user = await User.findOne({});
    if (!user) {
      console.log('❌ No users found. Please create a user first.');
      process.exit(1);
    }

    console.log('Found user:', user.email);

    // Check if user already has addresses
    const existingAddresses = await Address.find({ userId: user._id });
    console.log(`User has ${existingAddresses.length} existing addresses`);

    if (existingAddresses.length > 0) {
      console.log('✅ User already has addresses. No need to create test address.');
      process.exit(0);
    }

    // Create a test address
    const testAddress = new Address({
      userId: user._id,
      label: 'Home',
      address: '123 Test Street, Kathmandu, Nepal',
      coordinates: {
        latitude: 27.7172,
        longitude: 85.3240
      },
      type: 'home',
      instructions: 'Near the main gate',
      isDefault: true,
      isVerified: true
    });

    await testAddress.save();
    
    console.log('✅ Test address created successfully!');
    console.log('Address:', testAddress.address);
    console.log('Coordinates:', testAddress.coordinates);
    console.log('User ID:', user._id);

    process.exit(0);
  } catch (error) {
    console.error('❌ Error creating test address:', error);
    process.exit(1);
  }
}

createTestAddress(); 