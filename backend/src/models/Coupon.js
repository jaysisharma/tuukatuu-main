const mongoose = require('mongoose');

const couponSchema = new mongoose.Schema({
  code: { type: String, required: true, unique: true },
  discount: { type: Number, required: true }, // e.g. 10 for 10% or 100 for Rs. 100 off
  type: { type: String, enum: ['percent', 'amount'], default: 'percent' },
  description: { type: String },
  isActive: { type: Boolean, default: true },
  expiryDate: { type: Date },
  createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
}, { timestamps: true });

couponSchema.statics.seedCoupons = async function(adminId) {
  const coupons = [
    {
      code: 'WELCOME20',
      discount: 20,
      type: 'percent',
      description: '20% off for new users',
      isActive: true,
      expiryDate: new Date(Date.now() + 30*24*60*60*1000),
      createdBy: adminId,
    },
    {
      code: 'FREESHIP',
      discount: 100,
      type: 'amount',
      description: 'Rs. 100 off on delivery fee',
      isActive: true,
      expiryDate: new Date(Date.now() + 15*24*60*60*1000),
      createdBy: adminId,
    },
    {
      code: 'GROCERY10',
      discount: 10,
      type: 'percent',
      description: '10% off on groceries',
      isActive: true,
      expiryDate: new Date(Date.now() + 60*24*60*60*1000),
      createdBy: adminId,
    },
  ];
  await this.deleteMany({});
  await this.insertMany(coupons);
};

module.exports = mongoose.model('Coupon', couponSchema); 