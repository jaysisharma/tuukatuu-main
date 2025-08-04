const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
require('dotenv').config();

// Import User model
const User = require('./src/models/User');

async function createAdmin() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/first_db2');
    console.log('Connected to MongoDB');

    // Check if admin already exists
    const existingAdmin = await User.findOne({ role: 'admin' });
    if (existingAdmin) {
      console.log('Admin user already exists:', existingAdmin.email);
      console.log('You can use this admin account to login');
      process.exit(0);
    }

    // Create admin user
    const hashedPassword = await bcrypt.hash('admin123', 10);
    
    const adminUser = new User({
      name: 'Admin User',
      email: 'admin@tuukatuu.com',
      password: hashedPassword,
      role: 'admin',
      phone: '+977-1234567890',
      isActive: true,
      isVerified: true
    });

    await adminUser.save();
    
    console.log('✅ Admin user created successfully!');
    console.log('Email: admin@tuukatuu.com');
    console.log('Password: admin123');
    console.log('You can now login to the admin panel');

    process.exit(0);
  } catch (error) {
    console.error('❌ Error creating admin user:', error);
    process.exit(1);
  }
}

createAdmin(); 