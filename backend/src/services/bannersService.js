const Banner = require('../models/Banner');

exports.findBanners = async () => {
  return await Banner.find({ isActive: true });
};

exports.createBanner = async (user, bannerData) => {
  const banner = new Banner({ ...bannerData, createdBy: user.id });
  await banner.save();
  return banner;
};

exports.updateBanner = async (id, updateData) => {
  return await Banner.findByIdAndUpdate(id, updateData, { new: true });
};

exports.deleteBanner = async (id) => {
  return await Banner.findByIdAndDelete(id);
}; 