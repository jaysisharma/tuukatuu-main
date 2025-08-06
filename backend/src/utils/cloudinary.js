const cloudinary = require('cloudinary').v2;
const fs = require('fs');

// Configure Cloudinary
cloudinary.config({
  cloud_name: 'dyugb2jp8',
  api_key: '434489253172958',
  api_secret: 'MCetPW20Oppujxj4A9q63zGol70'
});

// Upload image to Cloudinary
exports.uploadToCloudinary = async (file, folder = 'general') => {
  try {
    if (!file) {
      throw new Error('No file provided');
    }

    const result = await cloudinary.uploader.upload(file.path, {
      folder: folder,
      resource_type: 'auto',
      transformation: [
        { width: 800, height: 800, crop: 'limit' },
        { quality: 'auto' }
      ]
    });

    // Delete local file after upload
    fs.unlinkSync(file.path);

    return {
      secure_url: result.secure_url,
      public_id: result.public_id,
      width: result.width,
      height: result.height,
      format: result.format
    };
  } catch (error) {
    // Clean up local file if it exists
    if (file && file.path && fs.existsSync(file.path)) {
      fs.unlinkSync(file.path);
    }
    throw error;
  }
};

// Delete image from Cloudinary
exports.deleteFromCloudinary = async (publicId) => {
  try {
    const result = await cloudinary.uploader.destroy(publicId);
    return result;
  } catch (error) {
    throw error;
  }
};

// Update image in Cloudinary
exports.updateCloudinaryImage = async (publicId, newFile, folder = 'general') => {
  try {
    // Delete old image
    if (publicId) {
      await this.deleteFromCloudinary(publicId);
    }

    // Upload new image
    return await this.uploadToCloudinary(newFile, folder);
  } catch (error) {
    throw error;
  }
}; 