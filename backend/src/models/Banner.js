const mongoose = require('mongoose');

const bannerSchema = new mongoose.Schema({
  title: { type: String, required: true },
  subtitle: { type: String },
  imageUrl: { type: String, required: true },
  link: { type: String },
  isActive: { type: Boolean, default: true },
  createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
}, { timestamps: true });

bannerSchema.statics.seedBanners = async function(adminId) {
  const banners = [
    {
      title: 'Get 20% OFF',
      subtitle: 'On your first T-Mart order',
      imageUrl: 'https://images.unsplash.com/photo-1608686207856-001b95cf60ca',
      link: '',
      isActive: true,
      createdBy: "687f14db32e676d13d3a3cf2",
    },
    {
      title: 'Free Delivery',
      subtitle: 'On orders above Rs. 500',
      imageUrl: 'https://images.unsplash.com/photo-1581056771107-24ca5f033842',
      link: '',
      isActive: true,
      createdBy: "687f14db32e676d13d3a3cf2",
    },
    {
      title: '15% Cashback',
      subtitle: 'On all grocery items',
      imageUrl: 'https://images.unsplash.com/photo-1621939514649-280e2ee25f60',
      link: '',
      isActive: true,
      createdBy: "687f14db32e676d13d3a3cf2",
    },
  ];
  await this.deleteMany({});
  await this.insertMany(banners);
};

module.exports = mongoose.model('Banner', bannerSchema); 