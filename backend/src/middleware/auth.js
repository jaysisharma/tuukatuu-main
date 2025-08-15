const jwt = require('jsonwebtoken');
const config = require('../config');

function authenticateToken(req, res, next) {
  console.log('🔍 Auth Middleware: Checking authentication for path:', req.path);
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  
  if (!token) {
    console.log('❌ Auth Middleware: No token provided');
    return res.status(401).json({ message: 'No token provided' });
  }

  console.log('🔍 Auth Middleware: Token found, verifying...');
  jwt.verify(token, config.jwtSecret, (err, user) => {
    if (err) {
      console.log('❌ Auth Middleware: Invalid token:', err.message);
      return res.status(403).json({ message: 'Invalid token' });
    }
    console.log('🔍 Auth Middleware: Token verified for user:', user.id);
    req.user = user;
    next();
  });
}

function authorizeRoles(...roles) {
  return (req, res, next) => {
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ message: 'Forbidden: insufficient role' });
    }
    next();
  };
}

function requireAdmin(req, res, next) {
  if (!req.user || req.user.role !== 'admin') {
    return res.status(403).json({ message: 'Forbidden: Admin access required' });
  }
  next();
}

module.exports = { authenticateToken, authorizeRoles, requireAdmin }; 