exports.successResponse = (res, data, message = 'Success', status = 200) => {
  res.status(status).json({ 
    success: true, 
    message, 
    data 
  });
};

exports.errorResponse = (res, message = 'Internal Server Error', status = 500) => {
  res.status(status).json({ 
    success: false, 
    message 
  });
};

// Legacy functions for backward compatibility
exports.success = (res, data, message = 'Success') => {
  exports.successResponse(res, data, message);
};

exports.error = (res, error, status = 500) => {
  const message = error.message || error;
  exports.errorResponse(res, message, status);
}; 