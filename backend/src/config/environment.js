const dotenv = require('dotenv');
const path = require('path');

dotenv.config({ path: path.resolve(__dirname, '../../.env') });

const config = {
  env: process.env.NODE_ENV || 'development',
  port: parseInt(process.env.PORT, 10) || 5001,
  apiPrefix: process.env.API_PREFIX || '/api/v1',
  allowedOrigins: process.env.ALLOWED_ORIGINS ? process.env.ALLOWED_ORIGINS.split(',') : ['*'],
  jwt: {
    secret: process.env.JWT_SECRET || 'nirmaan_dev_secret_key_change_in_production',
    expiry: process.env.JWT_EXPIRY || '7d',
  },
  firebase: {
    projectId: process.env.FIREBASE_PROJECT_ID || 'nirmaan-app',
    clientEmail: process.env.FIREBASE_CLIENT_EMAIL || '',
    privateKey: process.env.FIREBASE_PRIVATE_KEY ? process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n') : '',
  },
  gemini: {
    apiKey: process.env.GEMINI_API_KEY || '',
  },
};

module.exports = config;
