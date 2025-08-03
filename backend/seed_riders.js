const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const User = require('./src/models/User');
const Rider = require('./src/models/Rider');
require('dotenv').config();

// Connect to MongoDB
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/tuukatuu', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

const seedRiders = async () => {
  try {
    console.log('🌱 Starting rider seeding...');

    // Create rider users first
    const riderUsers = [
      {
        name: 'Rahul Kumar',
        email: 'rahul.rider@example.com',
        phone: '9876543210',
        password: await bcrypt.hash('password123', 10),
        role: 'rider'
      },
      {
        name: 'Amit Singh',
        email: 'amit.rider@example.com',
        phone: '9876543211',
        password: await bcrypt.hash('password123', 10),
        role: 'rider'
      },
      {
        name: 'Priya Sharma',
        email: 'priya.rider@example.com',
        phone: '9876543212',
        password: await bcrypt.hash('password123', 10),
        role: 'rider'
      },
      {
        name: 'Vikram Patel',
        email: 'vikram.rider@example.com',
        phone: '9876543213',
        password: await bcrypt.hash('password123', 10),
        role: 'rider'
      },
      {
        name: 'Sneha Reddy',
        email: 'sneha.rider@example.com',
        phone: '9876543214',
        password: await bcrypt.hash('password123', 10),
        role: 'rider'
      }
    ];

    // Clear existing rider users
    await User.deleteMany({ role: 'rider' });
    console.log('🗑️  Cleared existing rider users');

    // Create rider users
    const createdUsers = await User.insertMany(riderUsers);
    console.log(`✅ Created ${createdUsers.length} rider users`);

    // Create rider profiles
    const riderProfiles = [
      {
        userId: createdUsers[0]._id,
        profile: {
          fullName: 'Rahul Kumar',
          email: 'rahul.rider@example.com',
          phone: '9876543210',
          gender: 'male',
          emergencyContact: {
            name: 'Priya Kumar',
            phone: '9876543215',
            relationship: 'Wife'
          }
        },
        vehicle: {
          type: 'bike',
          brand: 'Honda',
          model: 'Activa 6G',
          year: 2022,
          color: 'Black',
          licensePlate: 'DL01AB1234'
        },
        documents: {
          drivingLicense: {
            number: 'DL0120201234567',
            expiryDate: new Date('2025-12-31')
          }
        },
        currentLocation: {
          coordinates: [77.2090, 28.6139], // Connaught Place, Delhi
          address: 'Connaught Place, New Delhi'
        },
        status: 'online',
        workPreferences: {
          isAvailable: true,
          workingHours: { start: '08:00', end: '20:00' },
          preferredAreas: ['Connaught Place', 'Khan Market', 'Lajpat Nagar'],
          maxDistance: 8
        },
        verification: {
          isVerified: true,
          isApproved: true,
          submittedAt: new Date('2024-01-01'),
          approvedAt: new Date('2024-01-02')
        },
        earnings: {
          totalEarnings: 12500,
          thisWeek: 1800,
          thisMonth: 6500,
          walletBalance: 1200
        },
        performance: {
          totalDeliveries: 156,
          completedDeliveries: 148,
          cancelledDeliveries: 8,
          averageRating: 4.7,
          totalReviews: 142,
          onTimeDeliveries: 135,
          lateDeliveries: 13
        }
      },
      {
        userId: createdUsers[1]._id,
        profile: {
          fullName: 'Amit Singh',
          email: 'amit.rider@example.com',
          phone: '9876543211',
          gender: 'male',
          emergencyContact: {
            name: 'Sunita Singh',
            phone: '9876543216',
            relationship: 'Sister'
          }
        },
        vehicle: {
          type: 'scooter',
          brand: 'TVS',
          model: 'Jupiter',
          year: 2021,
          color: 'Blue',
          licensePlate: 'DL02CD5678'
        },
        documents: {
          drivingLicense: {
            number: 'DL0120207654321',
            expiryDate: new Date('2026-06-30')
          }
        },
        currentLocation: {
          coordinates: [77.2167, 28.7041], // Khan Market, Delhi
          address: 'Khan Market, New Delhi'
        },
        status: 'online',
        workPreferences: {
          isAvailable: true,
          workingHours: { start: '09:00', end: '21:00' },
          preferredAreas: ['Khan Market', 'South Extension', 'Greater Kailash'],
          maxDistance: 10
        },
        verification: {
          isVerified: true,
          isApproved: true,
          submittedAt: new Date('2024-01-01'),
          approvedAt: new Date('2024-01-02')
        },
        earnings: {
          totalEarnings: 9800,
          thisWeek: 1200,
          thisMonth: 4800,
          walletBalance: 800
        },
        performance: {
          totalDeliveries: 124,
          completedDeliveries: 118,
          cancelledDeliveries: 6,
          averageRating: 4.5,
          totalReviews: 110,
          onTimeDeliveries: 105,
          lateDeliveries: 13
        }
      },
      {
        userId: createdUsers[2]._id,
        profile: {
          fullName: 'Priya Sharma',
          email: 'priya.rider@example.com',
          phone: '9876543212',
          gender: 'female',
          emergencyContact: {
            name: 'Rajesh Sharma',
            phone: '9876543217',
            relationship: 'Brother'
          }
        },
        vehicle: {
          type: 'bicycle',
          brand: 'Hero',
          model: 'Urban Trail',
          year: 2023,
          color: 'Red',
          licensePlate: null
        },
        documents: {
          drivingLicense: {
            number: 'DL0120209876543',
            expiryDate: new Date('2027-03-15')
          }
        },
        currentLocation: {
          coordinates: [77.2089, 28.5562], // Lajpat Nagar, Delhi
          address: 'Lajpat Nagar, New Delhi'
        },
        status: 'online',
        workPreferences: {
          isAvailable: true,
          workingHours: { start: '07:00', end: '19:00' },
          preferredAreas: ['Lajpat Nagar', 'Defence Colony', 'Hauz Khas'],
          maxDistance: 5
        },
        verification: {
          isVerified: true,
          isApproved: true,
          submittedAt: new Date('2024-01-01'),
          approvedAt: new Date('2024-01-02')
        },
        earnings: {
          totalEarnings: 7200,
          thisWeek: 900,
          thisMonth: 3600,
          walletBalance: 600
        },
        performance: {
          totalDeliveries: 89,
          completedDeliveries: 85,
          cancelledDeliveries: 4,
          averageRating: 4.8,
          totalReviews: 78,
          onTimeDeliveries: 82,
          lateDeliveries: 3
        }
      },
      {
        userId: createdUsers[3]._id,
        profile: {
          fullName: 'Vikram Patel',
          email: 'vikram.rider@example.com',
          phone: '9876543213',
          gender: 'male',
          emergencyContact: {
            name: 'Meera Patel',
            phone: '9876543218',
            relationship: 'Wife'
          }
        },
        vehicle: {
          type: 'car',
          brand: 'Maruti',
          model: 'Swift',
          year: 2020,
          color: 'White',
          licensePlate: 'DL03EF9012'
        },
        documents: {
          drivingLicense: {
            number: 'DL0120204567890',
            expiryDate: new Date('2028-09-20')
          }
        },
        currentLocation: {
          coordinates: [77.1025, 28.4595], // Greater Noida
          address: 'Greater Noida, Uttar Pradesh'
        },
        status: 'offline',
        workPreferences: {
          isAvailable: false,
          workingHours: { start: '10:00', end: '22:00' },
          preferredAreas: ['Greater Noida', 'Noida', 'Ghaziabad'],
          maxDistance: 15
        },
        verification: {
          isVerified: true,
          isApproved: true,
          submittedAt: new Date('2024-01-01'),
          approvedAt: new Date('2024-01-02')
        },
        earnings: {
          totalEarnings: 15800,
          thisWeek: 0,
          thisMonth: 7200,
          walletBalance: 1500
        },
        performance: {
          totalDeliveries: 203,
          completedDeliveries: 195,
          cancelledDeliveries: 8,
          averageRating: 4.6,
          totalReviews: 185,
          onTimeDeliveries: 178,
          lateDeliveries: 17
        }
      },
      {
        userId: createdUsers[4]._id,
        profile: {
          fullName: 'Sneha Reddy',
          email: 'sneha.rider@example.com',
          phone: '9876543214',
          gender: 'female',
          emergencyContact: {
            name: 'Arjun Reddy',
            phone: '9876543219',
            relationship: 'Husband'
          }
        },
        vehicle: {
          type: 'bike',
          brand: 'Bajaj',
          model: 'Pulsar 150',
          year: 2021,
          color: 'Silver',
          licensePlate: 'DL04GH3456'
        },
        documents: {
          drivingLicense: {
            number: 'DL0120202345678',
            expiryDate: new Date('2026-11-10')
          }
        },
        currentLocation: {
          coordinates: [77.1861, 28.7041], // Dwarka, Delhi
          address: 'Dwarka, New Delhi'
        },
        status: 'online',
        workPreferences: {
          isAvailable: true,
          workingHours: { start: '08:30', end: '20:30' },
          preferredAreas: ['Dwarka', 'Janakpuri', 'Rajouri Garden'],
          maxDistance: 12
        },
        verification: {
          isVerified: true,
          isApproved: true,
          submittedAt: new Date('2024-01-01'),
          approvedAt: new Date('2024-01-02')
        },
        earnings: {
          totalEarnings: 11200,
          thisWeek: 1500,
          thisMonth: 5800,
          walletBalance: 1000
        },
        performance: {
          totalDeliveries: 167,
          completedDeliveries: 160,
          cancelledDeliveries: 7,
          averageRating: 4.9,
          totalReviews: 152,
          onTimeDeliveries: 155,
          lateDeliveries: 5
        }
      }
    ];

    // Clear existing rider profiles
    await Rider.deleteMany({});
    console.log('🗑️  Cleared existing rider profiles');

    // Create rider profiles
    const createdRiders = await Rider.insertMany(riderProfiles);
    console.log(`✅ Created ${createdRiders.length} rider profiles`);

    console.log('🎉 Rider seeding completed successfully!');
    console.log('\n📊 Rider Summary:');
    console.log(`- Total Riders: ${createdRiders.length}`);
    console.log(`- Online Riders: ${createdRiders.filter(r => r.status === 'online').length}`);
    console.log(`- Total Earnings: ₹${createdRiders.reduce((sum, r) => sum + r.earnings.totalEarnings, 0)}`);
    console.log(`- Average Rating: ${(createdRiders.reduce((sum, r) => sum + r.performance.averageRating, 0) / createdRiders.length).toFixed(1)}`);

    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding riders:', error);
    process.exit(1);
  }
};

// Run the seeding
seedRiders(); 