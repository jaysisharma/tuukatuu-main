module.exports = {
  jwtSecret: process.env.JWT_SECRET || 'changeme',
  mongoUri: process.env.MONGODB_URI,
  port: process.env.PORT || 3000,
}; 