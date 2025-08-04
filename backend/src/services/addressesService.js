const Address = require('../models/Address');
const { calculateDistance, validateCoordinates } = require('../utils/locationUtils');

// Get all addresses for a user
exports.findAddressesForUser = async (userId) => {
  try {
    console.log('🔍 Backend Service: Finding addresses for user:', userId);
    const addresses = await Address.find({ userId }).sort({ isDefault: -1, createdAt: -1 });
    console.log('🔍 Backend Service: Found ${addresses.length} addresses');
    return addresses;
  } catch (error) {
    console.error('Error finding addresses for user:', error);
    throw new Error('Failed to fetch addresses');
  }
};

// Get default address for a user
exports.getDefaultAddress = async (userId) => {
  try {
    return await Address.getDefaultAddress(userId);
  } catch (error) {
    console.error('Error getting default address:', error);
    throw new Error('Failed to fetch default address');
  }
};

// Create a new address
exports.createAddress = async (userId, addressData) => {
  try {
    // Validate coordinates if provided
    if (addressData.coordinates) {
      if (!validateCoordinates(addressData.coordinates.latitude, addressData.coordinates.longitude)) {
        throw new Error('Invalid coordinates provided');
      }
    }

    // If this is the first address or marked as default, set as default
    const existingAddresses = await Address.countDocuments({ userId });
    if (existingAddresses === 0 || addressData.isDefault) {
      addressData.isDefault = true;
    }

    const addr = new Address({ userId, ...addressData });
    await addr.save();
    return addr;
  } catch (error) {
    console.error('Error creating address:', error);
    throw error;
  }
};

// Update an existing address
exports.updateAddress = async (userId, addressId, updateData) => {
  try {
    // Validate coordinates if provided
    if (updateData.coordinates) {
      if (!validateCoordinates(updateData.coordinates.latitude, updateData.coordinates.longitude)) {
        throw new Error('Invalid coordinates provided');
      }
    }

    const address = await Address.findOneAndUpdate(
      { _id: addressId, userId },
      updateData,
      { new: true }
    );

    if (!address) {
      throw new Error('Address not found');
    }

    return address;
  } catch (error) {
    console.error('Error updating address:', error);
    throw error;
  }
};

// Delete an address
exports.deleteAddress = async (userId, addressId) => {
  try {
    const address = await Address.findOne({ _id: addressId, userId });
    if (!address) {
      throw new Error('Address not found');
    }

    // If deleting default address, set another address as default
    if (address.isDefault) {
      const otherAddress = await Address.findOne({ userId, _id: { $ne: addressId } });
      if (otherAddress) {
        otherAddress.isDefault = true;
        await otherAddress.save();
      }
    }

    await Address.findByIdAndDelete(addressId);
    return { message: 'Address deleted successfully' };
  } catch (error) {
    console.error('Error deleting address:', error);
    throw error;
  }
};

// Set an address as default
exports.setDefaultAddress = async (userId, addressId) => {
  try {
    const address = await Address.findOne({ _id: addressId, userId });
    if (!address) {
      throw new Error('Address not found');
    }

    // Remove default flag from all addresses
    await Address.updateMany({ userId }, { isDefault: false });
    
    // Set the selected address as default
    address.isDefault = true;
    await address.save();
    
    return address;
  } catch (error) {
    console.error('Error setting default address:', error);
    throw error;
  }
};

// Find nearby addresses
exports.findNearbyAddresses = async (userId, latitude, longitude, maxDistance = 5) => {
  try {
    if (!validateCoordinates(latitude, longitude)) {
      throw new Error('Invalid coordinates provided');
    }

    return await Address.findNearby(latitude, longitude, maxDistance);
  } catch (error) {
    console.error('Error finding nearby addresses:', error);
    throw error;
  }
};

// Validate and geocode an address
exports.validateAndGeocodeAddress = async (addressData) => {
  try {
    // Basic validation - check if address is provided
    if (!addressData.address || addressData.address.trim().length === 0) {
      throw new Error('Address is required');
    }

    // If coordinates are not provided, we would geocode the address here
    // For now, we'll require coordinates to be provided
    if (!addressData.coordinates || !addressData.coordinates.latitude || !addressData.coordinates.longitude) {
      throw new Error('Coordinates are required');
    }

    // Validate coordinates
    if (!validateCoordinates(addressData.coordinates.latitude, addressData.coordinates.longitude)) {
      throw new Error('Invalid coordinates provided');
    }

    return {
      ...addressData,
      isVerified: true,
      validatedAt: new Date(),
      validationSource: 'manual'
    };
  } catch (error) {
    console.error('Error validating address:', error);
    throw error;
  }
};

// Search addresses by query
exports.searchAddresses = async (userId, query) => {
  try {
    const searchRegex = new RegExp(query, 'i');
    
    return await Address.find({
      userId,
      $or: [
        { label: searchRegex },
        { address: searchRegex },
        { instructions: searchRegex }
      ]
    }).sort({ isDefault: -1, createdAt: -1 });
  } catch (error) {
    console.error('Error searching addresses:', error);
    throw new Error('Failed to search addresses');
  }
};

// Get address statistics for a user
exports.getAddressStats = async (userId) => {
  try {
    const addresses = await Address.find({ userId });
    
    return {
      total: addresses.length,
      default: addresses.filter(addr => addr.isDefault).length,
      byType: {
        home: addresses.filter(addr => addr.type === 'home').length,
        work: addresses.filter(addr => addr.type === 'work').length,
        other: addresses.filter(addr => addr.type === 'other').length
      },
      verified: addresses.filter(addr => addr.isVerified).length
    };
  } catch (error) {
    console.error('Error getting address stats:', error);
    throw new Error('Failed to get address statistics');
  }
};

// Bulk operations
exports.bulkUpdateAddresses = async (userId, updates) => {
  try {
    const operations = updates.map(update => ({
      updateOne: {
        filter: { _id: update.id, userId },
        update: { $set: update.data }
      }
    }));

    const result = await Address.bulkWrite(operations);
    return result;
  } catch (error) {
    console.error('Error bulk updating addresses:', error);
    throw new Error('Failed to bulk update addresses');
  }
};

// Import addresses (for migration or bulk import)
exports.importAddresses = async (userId, addresses) => {
  try {
    const validatedAddresses = [];
    
    for (const addressData of addresses) {
      try {
        const validated = await this.validateAndGeocodeAddress(addressData);
        validatedAddresses.push({ userId, ...validated });
      } catch (error) {
        console.error(`Failed to validate address: ${error.message}`);
      }
    }

    if (validatedAddresses.length > 0) {
      return await Address.insertMany(validatedAddresses);
    }
    
    return [];
  } catch (error) {
    console.error('Error importing addresses:', error);
    throw new Error('Failed to import addresses');
  }
};

// Export addresses for a user
exports.exportAddresses = async (userId) => {
  try {
    const addresses = await Address.find({ userId });
    
    return addresses.map(addr => ({
      id: addr._id,
      label: addr.label,
      address: addr.address,
      coordinates: addr.coordinates,
      type: addr.type,
      isDefault: addr.isDefault,
      instructions: addr.instructions,
      isVerified: addr.isVerified,
      createdAt: addr.createdAt,
      updatedAt: addr.updatedAt
    }));
  } catch (error) {
    console.error('Error exporting addresses:', error);
    throw new Error('Failed to export addresses');
  }
}; 