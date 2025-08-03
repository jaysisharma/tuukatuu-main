const User = require('../models/User');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

exports.registerUser = async ({ name, email, phone, password, role }) => {
  if (typeof phone !== 'string') {
    throw new Error('Phone must be a string');
  }
  const hashedPassword = await bcrypt.hash(password, 10);
  const user = new User({ name, email, phone, password: hashedPassword, role });
  await user.save();
  return user;
};

exports.loginUser = async ({ email, password }) => {
  const user = await User.findOne({ email });
  if (!user) throw new Error('Invalid credentials');
  const isMatch = await bcrypt.compare(password, user.password);
  if (!isMatch) throw new Error('Invalid credentials');
  const token = jwt.sign({ id: user._id, role: user.role }, process.env.JWT_SECRET, { expiresIn: '7d' });
  return { token, user: { id: user._id, name: user.name, email: user.email, role: user.role } };
};

exports.getUserById = async (id) => {
  return await User.findById(id).select('-password');
};

exports.updateUser = async (id, updates) => {
  return await User.findByIdAndUpdate(id, updates, { new: true }).select('-password');
};

exports.changePassword = async (id, oldPassword, newPassword) => {
  const user = await User.findById(id);
  const isMatch = await bcrypt.compare(oldPassword, user.password);
  if (!isMatch) throw new Error('Old password is incorrect');
  user.password = await bcrypt.hash(newPassword, 10);
  await user.save();
  return user;
};

exports.getVendors = async () => {
  return await User.find({ role: 'vendor' }).select('-password');
};

exports.getFeaturedVendors = async () => {
  return await User.find({ role: 'vendor', isFeatured: true }).select('-password');
}; 