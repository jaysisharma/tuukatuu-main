const Product = require('../models/Product');

exports.findProducts = async (vendorId) => {
  const query = {};
  if (vendorId) query.vendorId = vendorId;
  return await Product.find(query);
};

exports.createProduct = async (user, productData) => {
  const product = new Product({ ...productData, vendorId: user.id });
  await product.save();
  return product;
};

exports.getMyProducts = async (vendorId) => {
  return await Product.find({ vendorId });
};

exports.updateProduct = async (user, productId, updateData) => {
  let product;
  if (user.role === 'vendor') {
    product = await Product.findOneAndUpdate({ _id: productId, vendorId: user.id }, updateData, { new: true });
  } else {
    product = await Product.findByIdAndUpdate(productId, updateData, { new: true });
  }
  return product;
};

exports.deleteProduct = async (user, productId) => {
  let product;
  if (user.role === 'vendor') {
    product = await Product.findOneAndDelete({ _id: productId, vendorId: user.id });
  } else {
    product = await Product.findByIdAndDelete(productId);
  }
  return product;
}; 