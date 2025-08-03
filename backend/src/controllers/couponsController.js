const Coupon = require('../models/Coupon');

exports.getCoupons = async (req, res) => {
  const coupons = await Coupon.find();
  res.json(coupons);
};

exports.createCoupon = async (req, res) => {
  try {
    const coupon = new Coupon({ ...req.body, createdBy: req.user.id });
    await coupon.save();
    res.status(201).json(coupon);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

exports.updateCoupon = async (req, res) => {
  try {
    const coupon = await Coupon.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!coupon) return res.status(404).json({ message: 'Coupon not found' });
    res.json(coupon);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

exports.deleteCoupon = async (req, res) => {
  try {
    const coupon = await Coupon.findByIdAndDelete(req.params.id);
    if (!coupon) return res.status(404).json({ message: 'Coupon not found' });
    res.json({ message: 'Coupon deleted' });
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
}; 