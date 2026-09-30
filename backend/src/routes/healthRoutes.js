const express = require('express');
const router = express.Router();
const { sendSuccess } = require('../utils/responseFormatter');

router.get('/health', (req, res) => {
  return sendSuccess(
    res,
    {
      status: 'UP',
      uptime: process.uptime(),
      timestamp: new Date().toISOString(),
      service: 'Nirmaan Backend Service',
      version: '1.0.0',
    },
    'Nirmaan API is healthy'
  );
});

module.exports = router;
