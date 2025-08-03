const request = require('supertest');
const mongoose = require('mongoose');
const app = require('../src/index');
const Address = require('../src/models/Address');
const User = require('../src/models/User');
const jwt = require('jsonwebtoken');

describe('Address API Tests', () => {
  let testUser;
  let authToken;
  let testAddress;

  beforeAll(async () => {
    // Create a test user
    testUser = new User({
      name: 'Test User',
      email: 'test@example.com',
      password: 'password123',
      role: 'customer'
    });
    await testUser.save();

    // Generate auth token
    authToken = jwt.sign(
      { id: testUser._id, email: testUser.email, role: testUser.role },
      process.env.JWT_SECRET || 'test-secret'
    );
  });

  afterAll(async () => {
    // Clean up test data
    await User.findByIdAndDelete(testUser._id);
    await mongoose.connection.close();
  });

  beforeEach(async () => {
    // Clear addresses before each test
    await Address.deleteMany({ userId: testUser._id });
  });

  describe('POST /api/addresses', () => {
    it('should create a new address', async () => {
      const addressData = {
        label: 'Home',
        address: '123 Test Street, Kathmandu',
        coordinates: {
          latitude: 27.7172,
          longitude: 85.3240
        },
        type: 'home',
        instructions: 'Near the main gate'
      };

      const response = await request(app)
        .post('/api/addresses')
        .set('Authorization', `Bearer ${authToken}`)
        .send(addressData)
        .expect(201);

      expect(response.body).toHaveProperty('_id');
      expect(response.body.label).toBe(addressData.label);
      expect(response.body.address).toBe(addressData.address);
      expect(response.body.coordinates.latitude).toBe(addressData.coordinates.latitude);
      expect(response.body.coordinates.longitude).toBe(addressData.coordinates.longitude);
      expect(response.body.isDefault).toBe(true); // First address should be default
    });

    it('should return 400 for missing required fields', async () => {
      const addressData = {
        label: 'Home'
        // Missing address and coordinates
      };

      const response = await request(app)
        .post('/api/addresses')
        .set('Authorization', `Bearer ${authToken}`)
        .send(addressData)
        .expect(400);

      expect(response.body).toHaveProperty('message');
    });

    it('should return 400 for invalid coordinates', async () => {
      const addressData = {
        label: 'Home',
        address: '123 Test Street',
        coordinates: {
          latitude: 200, // Invalid latitude
          longitude: 85.3240
        }
      };

      const response = await request(app)
        .post('/api/addresses')
        .set('Authorization', `Bearer ${authToken}`)
        .send(addressData)
        .expect(400);

      expect(response.body).toHaveProperty('message');
    });
  });

  describe('GET /api/addresses', () => {
    it('should return all addresses for the user', async () => {
      // Create test addresses
      const addresses = [
        {
          userId: testUser._id,
          label: 'Home',
          address: '123 Home Street',
          coordinates: { latitude: 27.7172, longitude: 85.3240 },
          type: 'home',
          isDefault: true
        },
        {
          userId: testUser._id,
          label: 'Work',
          address: '456 Work Street',
          coordinates: { latitude: 27.7173, longitude: 85.3241 },
          type: 'work',
          isDefault: false
        }
      ];

      await Address.insertMany(addresses);

      const response = await request(app)
        .get('/api/addresses')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(Array.isArray(response.body)).toBe(true);
      expect(response.body).toHaveLength(2);
      expect(response.body[0].isDefault).toBe(true); // Default should be first
    });
  });

  describe('PUT /api/addresses/:id', () => {
    it('should update an existing address', async () => {
      // Create a test address
      const address = new Address({
        userId: testUser._id,
        label: 'Home',
        address: '123 Test Street',
        coordinates: { latitude: 27.7172, longitude: 85.3240 },
        type: 'home'
      });
      await address.save();

      const updateData = {
        label: 'Updated Home',
        instructions: 'Updated instructions'
      };

      const response = await request(app)
        .put(`/api/addresses/${address._id}`)
        .set('Authorization', `Bearer ${authToken}`)
        .send(updateData)
        .expect(200);

      expect(response.body.label).toBe(updateData.label);
      expect(response.body.instructions).toBe(updateData.instructions);
    });

    it('should return 404 for non-existent address', async () => {
      const fakeId = new mongoose.Types.ObjectId();

      const response = await request(app)
        .put(`/api/addresses/${fakeId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .send({ label: 'Updated' })
        .expect(404);

      expect(response.body).toHaveProperty('message');
    });
  });

  describe('DELETE /api/addresses/:id', () => {
    it('should delete an address', async () => {
      // Create a test address
      const address = new Address({
        userId: testUser._id,
        label: 'Home',
        address: '123 Test Street',
        coordinates: { latitude: 27.7172, longitude: 85.3240 },
        type: 'home'
      });
      await address.save();

      const response = await request(app)
        .delete(`/api/addresses/${address._id}`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(response.body).toHaveProperty('message');
      expect(response.body.message).toBe('Address deleted successfully');

      // Verify address is deleted
      const deletedAddress = await Address.findById(address._id);
      expect(deletedAddress).toBeNull();
    });
  });

  describe('PATCH /api/addresses/:id/default', () => {
    it('should set an address as default', async () => {
      // Create test addresses
      const addresses = [
        {
          userId: testUser._id,
          label: 'Home',
          address: '123 Home Street',
          coordinates: { latitude: 27.7172, longitude: 85.3240 },
          type: 'home',
          isDefault: true
        },
        {
          userId: testUser._id,
          label: 'Work',
          address: '456 Work Street',
          coordinates: { latitude: 27.7173, longitude: 85.3241 },
          type: 'work',
          isDefault: false
        }
      ];

      const savedAddresses = await Address.insertMany(addresses);
      const workAddress = savedAddresses[1];

      const response = await request(app)
        .patch(`/api/addresses/${workAddress._id}/default`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(response.body.isDefault).toBe(true);

      // Verify other address is no longer default
      const homeAddress = await Address.findById(savedAddresses[0]._id);
      expect(homeAddress.isDefault).toBe(false);
    });
  });

  describe('GET /api/addresses/search', () => {
    it('should search addresses by query', async () => {
      // Create test addresses
      const addresses = [
        {
          userId: testUser._id,
          label: 'Home',
          address: '123 Home Street, Kathmandu',
          coordinates: { latitude: 27.7172, longitude: 85.3240 },
          type: 'home'
        },
        {
          userId: testUser._id,
          label: 'Work',
          address: '456 Work Street, Lalitpur',
          coordinates: { latitude: 27.7173, longitude: 85.3241 },
          type: 'work'
        }
      ];

      await Address.insertMany(addresses);

      const response = await request(app)
        .get('/api/addresses/search?q=Home')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(Array.isArray(response.body)).toBe(true);
      expect(response.body).toHaveLength(1);
      expect(response.body[0].label).toBe('Home');
    });

    it('should return 400 for empty search query', async () => {
      const response = await request(app)
        .get('/api/addresses/search?q=')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(400);

      expect(response.body).toHaveProperty('message');
    });
  });

  describe('GET /api/addresses/nearby', () => {
    it('should find nearby addresses', async () => {
      // Create test addresses
      const addresses = [
        {
          userId: testUser._id,
          label: 'Nearby',
          address: '123 Nearby Street',
          coordinates: { latitude: 27.7172, longitude: 85.3240 },
          type: 'other'
        },
        {
          userId: testUser._id,
          label: 'Far Away',
          address: '456 Far Street',
          coordinates: { latitude: 28.0000, longitude: 86.0000 },
          type: 'other'
        }
      ];

      await Address.insertMany(addresses);

      const response = await request(app)
        .get('/api/addresses/nearby?latitude=27.7172&longitude=85.3240&maxDistance=5')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(Array.isArray(response.body)).toBe(true);
      expect(response.body.length).toBeGreaterThan(0);
    });

    it('should return 400 for missing coordinates', async () => {
      const response = await request(app)
        .get('/api/addresses/nearby?latitude=27.7172')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(400);

      expect(response.body).toHaveProperty('message');
    });
  });
}); 