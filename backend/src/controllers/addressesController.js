const Address = require('../models/Address');
const addressesService = require('../services/addressesService');
const { validateCoordinates } = require('../utils/locationUtils');

// ✅ Get all addresses for the authenticated user
exports.getAddresses = async (req, res) => {
  try {
    console.log('🔍 Backend: getAddresses called for user:', req.user.id);
    const addresses = await addressesService.findAddressesForUser(req.user.id);
    console.log('🔍 Backend: Found ${addresses.length} addresses for user');
    res.json(addresses);
  } catch (error) {
    console.error('Error fetching addresses:', error);
    res.status(500).json({ message: error.message });
  }
};

// ✅ Get default address
exports.getDefaultAddress = async (req, res) => {
  try {
    const address = await addressesService.getDefaultAddress(req.user.id);
    if (!address) return res.status(404).json({ message: 'No default address found' });
    res.json(address);
  } catch (error) {
    console.error('Error fetching default address:', error);
    res.status(500).json({ message: error.message });
  }
};

// ✅ Create a new address
exports.createAddress = async (req, res) => {
  try {
    const { label, address, coordinates, type, instructions, isDefault } = req.body;

    if (!label || !address) {
      return res.status(400).json({ message: 'Label and address are required' });
    }

    if (!coordinates || !validateCoordinates(coordinates.latitude, coordinates.longitude)) {
      return res.status(400).json({ message: 'Valid coordinates are required' });
    }

    const addressData = {
      label,
      address,
      coordinates,
      type: type || 'other',
      instructions,
      isDefault: isDefault || false,
    };

    const newAddress = await addressesService.createAddress(req.user.id, addressData);
    res.status(201).json(newAddress);
  } catch (error) {
    console.error('Error creating address:', error);
    res.status(500).json({ message: error.message });
  }
};

// ✅ Update an existing address
exports.updateAddress = async (req, res) => {
  try {
    const { id } = req.params;
    const updateData = req.body;

    if (updateData.coordinates && !validateCoordinates(updateData.coordinates.latitude, updateData.coordinates.longitude)) {
      return res.status(400).json({ message: 'Invalid coordinates provided' });
    }

    const updatedAddress = await addressesService.updateAddress(req.user.id, id, updateData);
    res.json(updatedAddress);
  } catch (error) {
    if (error.message === 'Address not found') {
      return res.status(404).json({ message: error.message });
    }
    console.error('Error updating address:', error);
    res.status(500).json({ message: error.message });
  }
};

// ✅ Delete an address
exports.deleteAddress = async (req, res) => {
  try {
    const { id } = req.params;
    const result = await addressesService.deleteAddress(req.user.id, id);
    res.json(result);
  } catch (error) {
    if (error.message === 'Address not found') {
      return res.status(404).json({ message: error.message });
    }
    console.error('Error deleting address:', error);
    res.status(500).json({ message: error.message });
  }
};

// ✅ Set default address
exports.setDefaultAddress = async (req, res) => {
  try {
    const { id } = req.params;
    const address = await addressesService.setDefaultAddress(req.user.id, id);
    res.json(address);
  } catch (error) {
    if (error.message === 'Address not found') {
      return res.status(404).json({ message: error.message });
    }
    console.error('Error setting default address:', error);
    res.status(500).json({ message: error.message });
  }
};

// ✅ Search addresses by keyword
exports.searchAddresses = async (req, res) => {
  try {
    const { q } = req.query;
    if (!q || q.trim().length === 0) {
      return res.status(400).json({ message: 'Search query is required' });
    }

    const addresses = await addressesService.searchAddresses(req.user.id, q.trim());
    res.json(addresses);
  } catch (error) {
    console.error('Error searching addresses:', error);
    res.status(500).json({ message: error.message });
  }
};

// ✅ Find nearby addresses
exports.findNearbyAddresses = async (req, res) => {
  try {
    const { latitude, longitude, maxDistance = 5 } = req.query;

    if (!latitude || !longitude) {
      return res.status(400).json({ message: 'Latitude and longitude are required' });
    }

    const lat = parseFloat(latitude);
    const lng = parseFloat(longitude);
    const distance = parseFloat(maxDistance);

    if (!validateCoordinates(lat, lng)) {
      return res.status(400).json({ message: 'Invalid coordinates provided' });
    }

    const addresses = await addressesService.findNearbyAddresses(req.user.id, lat, lng, distance);
    res.json(addresses);
  } catch (error) {
    console.error('Error finding nearby addresses:', error);
    res.status(500).json({ message: error.message });
  }
};

// ✅ Validate and geocode an address
exports.validateAddress = async (req, res) => {
  try {
    const addressData = req.body;
    const validatedAddress = await addressesService.validateAndGeocodeAddress(addressData);
    res.json(validatedAddress);
  } catch (error) {
    console.error('Error validating address:', error);
    res.status(400).json({ message: error.message });
  }
};

// ✅ Get address statistics
exports.getAddressStats = async (req, res) => {
  try {
    const stats = await addressesService.getAddressStats(req.user.id);
    res.json(stats);
  } catch (error) {
    console.error('Error getting address stats:', error);
    res.status(500).json({ message: error.message });
  }
};

// ✅ Bulk update multiple addresses
exports.bulkUpdateAddresses = async (req, res) => {
  try {
    const { updates } = req.body;

    if (!Array.isArray(updates) || updates.length === 0) {
      return res.status(400).json({ message: 'Updates array is required' });
    }

    const result = await addressesService.bulkUpdateAddresses(req.user.id, updates);
    res.json(result);
  } catch (error) {
    console.error('Error bulk updating addresses:', error);
    res.status(400).json({ message: error.message });
  }
};

// ✅ Import addresses in bulk
exports.importAddresses = async (req, res) => {
  try {
    const { addresses } = req.body;

    if (!Array.isArray(addresses) || addresses.length === 0) {
      return res.status(400).json({ message: 'Addresses array is required' });
    }

    const imported = await addressesService.importAddresses(req.user.id, addresses);
    res.status(201).json({
      message: `Successfully imported ${imported.length} addresses`,
      addresses: imported,
    });
  } catch (error) {
    console.error('Error importing addresses:', error);
    res.status(400).json({ message: error.message });
  }
};

// ✅ Export all addresses for the user
exports.exportAddresses = async (req, res) => {
  try {
    const addresses = await addressesService.exportAddresses(req.user.id);
    res.json(addresses);
  } catch (error) {
    console.error('Error exporting addresses:', error);
    res.status(500).json({ message: error.message });
  }
};
