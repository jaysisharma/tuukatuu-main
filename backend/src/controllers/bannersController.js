const Banner = require('../models/Banner');

exports.getBanners = async (req, res) => {
  const banners = await Banner.find({ isActive: true });
  res.json(banners);
};

exports.createBanner = async (req, res) => {
  try {
    const banner = new Banner({ ...req.body, createdBy: req.user.id });
    await banner.save();
    res.status(201).json(banner);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

exports.updateBanner = async (req, res) => {
  try {
    const banner = await Banner.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!banner) return res.status(404).json({ message: 'Banner not found' });
    res.json(banner);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

exports.deleteBanner = async (req, res) => {
  try {
    const banner = await Banner.findByIdAndDelete(req.params.id);
    if (!banner) return res.status(404).json({ message: 'Banner not found' });
    res.json({ message: 'Banner deleted' });
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
}; 