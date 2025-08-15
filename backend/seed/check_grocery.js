const mongoose = require('mongoose');

mongoose.connect('mongodb://localhost:27017/tuukatuu').then(async () => {
  const Product = require('../src/models/Product');
  const User = require('../src/models/User');
  
  console.log('Checking grocery products...');
  
  const groceryProducts = await Product.find({ 
    category: { $regex: 'grocery', $options: 'i' } 
  }).populate('vendorId');
  
  console.log('Grocery products found:', groceryProducts.length);
  
  if (groceryProducts.length > 0) {
    console.log('Sample product:', groceryProducts[0].name);
    console.log('Has vendorId:', !!groceryProducts[0].vendorId);
    console.log('VendorId:', groceryProducts[0].vendorId);
    console.log('Vendor populated:', groceryProducts[0].vendorId ? !!groceryProducts[0].vendorId.storeName : false);
    if (groceryProducts[0].vendorId) {
      console.log('Vendor name:', groceryProducts[0].vendorId.storeName);
    }
  }
  
  // Check raw vendorId values
  const rawProducts = await Product.find({ 
    category: { $regex: 'grocery', $options: 'i' } 
  });
  
  console.log('\nRaw vendorId values:');
  rawProducts.slice(0, 3).forEach(product => {
    console.log(`- ${product.name}: vendorId = ${product.vendorId}`);
  });
  
  const productsWithVendor = await Product.find({ 
    category: { $regex: 'grocery', $options: 'i' }, 
    vendorId: { $exists: true, $ne: null } 
  });
  
  console.log('\nProducts with valid vendorId:', productsWithVendor.length);
  
  // Check if vendors exist
  const vendors = await User.find({ role: 'vendor' });
  console.log('Total vendors:', vendors.length);
  
  console.log('\nExisting vendors:');
  vendors.forEach(vendor => {
    console.log(`- ${vendor.storeName} (${vendor._id}) - Type: ${vendor.vendorType}/${vendor.vendorSubType}`);
  });
  
  // Check specific vendor
  const specificVendor = await User.findById('688c20019fb22fa00cadf704');
  console.log('\nSpecific vendor exists:', !!specificVendor);
  if (specificVendor) {
    console.log('Vendor name:', specificVendor.storeName);
    console.log('Vendor type:', specificVendor.vendorType);
    console.log('Vendor subtype:', specificVendor.vendorSubType);
  }
  
  // Find a suitable vendor for grocery products
  const groceryVendor = vendors.find(v => v.vendorSubType === 'grocery' || v.vendorSubType === 'supermarket');
  if (groceryVendor) {
    console.log('\nFound suitable vendor for grocery:', groceryVendor.storeName);
    
    // Update grocery products to use this vendor
    const updateResult = await Product.updateMany(
      { category: { $regex: 'grocery', $options: 'i' } },
      { vendorId: groceryVendor._id }
    );
    
    console.log('Updated grocery products:', updateResult.modifiedCount);
  } else {
    console.log('\nNo suitable vendor found for grocery products');
  }
  
  mongoose.disconnect();
}); 