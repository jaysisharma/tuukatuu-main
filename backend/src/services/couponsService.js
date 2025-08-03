const Coupon = require('../models/Coupon');

exports.findCoupons = async () => {
  return await Coupon.find({ isActive: true, expiryDate: { $gte: new Date() } });
};

exports.createCoupon = async (user, couponData) => {
  const coupon = new Coupon({ ...couponData, createdBy: user.id });
  await coupon.save();
  return coupon;
};

exports.updateCoupon = async (id, updateData) => {
  return await Coupon.findByIdAndUpdate(id, updateData, { new: true });
};

exports.deleteCoupon = async (id) => {
  return await Coupon.findByIdAndDelete(id);
}; 