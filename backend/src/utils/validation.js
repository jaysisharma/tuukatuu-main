// Category validation
exports.validateCategoryData = (data, isUpdate = false) => {
  const errors = [];
  
  // Required fields for creation
  if (!isUpdate) {
    if (!data.name || data.name.trim().length === 0) {
      errors.push('Category name is required');
    }
  }
  
  // Validate name if provided
  if (data.name) {
    if (data.name.trim().length < 2) {
      errors.push('Category name must be at least 2 characters long');
    }
    if (data.name.trim().length > 50) {
      errors.push('Category name must be less than 50 characters');
    }
  }
  
  // Validate displayName if provided
  if (data.displayName) {
    if (data.displayName.trim().length < 2) {
      errors.push('Display name must be at least 2 characters long');
    }
    if (data.displayName.trim().length > 100) {
      errors.push('Display name must be less than 100 characters');
    }
  }
  
  // Validate description if provided
  if (data.description && data.description.length > 500) {
    errors.push('Description must be less than 500 characters');
  }
  
  // Validate color if provided
  if (data.color) {
    const validColors = [
      'green', 'blue', 'orange', 'red', 'purple', 'cyan', 
      'indigo', 'pink', 'teal', 'amber', 'deepPurple', 
      'lightBlue', 'yellow', 'brown'
    ];
    if (!validColors.includes(data.color)) {
      errors.push('Invalid color value');
    }
  }
  
  // Validate URLs if provided
  if (data.imageUrl && !isValidUrl(data.imageUrl)) {
    errors.push('Invalid image URL');
  }
  
  if (data.iconUrl && !isValidUrl(data.iconUrl)) {
    errors.push('Invalid icon URL');
  }
  
  // Validate sort order if provided
  if (data.sortOrder !== undefined) {
    if (typeof data.sortOrder !== 'number' || data.sortOrder < 0) {
      errors.push('Sort order must be a non-negative number');
    }
  }
  
  return {
    isValid: errors.length === 0,
    errors
  };
};

// URL validation helper
function isValidUrl(string) {
  try {
    new URL(string);
    return true;
  } catch (_) {
    return false;
  }
}

// Product validation (for auto-category creation)
exports.validateProductData = (data) => {
  const errors = [];
  
  if (!data.category || data.category.trim().length === 0) {
    errors.push('Product category is required');
  }
  
  if (data.category && data.category.trim().length < 2) {
    errors.push('Product category must be at least 2 characters long');
  }
  
  return {
    isValid: errors.length === 0,
    errors
  };
}; 