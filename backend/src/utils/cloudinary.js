const cloudinary = require('cloudinary').v2;
const fs = require('fs');
const path = require('path');

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

    // Support both multer file object and direct file path string
    let filePath = typeof file === 'string' ? file : file.path;
    if (!filePath && file && file.destination && file.filename) {
      filePath = path.join(file.destination, file.filename);
    }

    if (!filePath) {
      throw new Error('Missing file path');
    }

    const result = await cloudinary.uploader.upload(filePath, {
      folder: folder,
      resource_type: 'auto',
      transformation: [
        { width: 800, height: 800, crop: 'limit' },
        { quality: 'auto' }
      ]
    });

    // Delete local file after upload
    if (fs.existsSync(filePath)) {
      fs.unlinkSync(filePath);
    }

    return {
      secure_url: result.secure_url,
      public_id: result.public_id,
      width: result.width,
      height: result.height,
      format: result.format
    };
  } catch (error) {
    // Clean up local file if it exists
    try {
      const filePath = typeof file === 'string' ? file : file?.path;
      if (filePath && fs.existsSync(filePath)) {
        fs.unlinkSync(filePath);
      }
    } catch (_) {}
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