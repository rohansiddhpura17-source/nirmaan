const app = require('./app');
const config = require('./config/environment');
const seedService = require('./services/seedService');

const PORT = config.port;

const server = app.listen(PORT, async () => {
  console.log(`=========================================`);
  console.log(`🚀 Nirmaan Backend Service Running`);
  console.log(`🌍 Environment: ${config.env}`);
  console.log(`📡 URL: http://localhost:${PORT}${config.apiPrefix}`);
  console.log(`🩺 Health: http://localhost:${PORT}${config.apiPrefix}/health`);
  console.log(`=========================================`);

  try {
    if (config.env !== 'production') {
      await seedService.seedTenant('biz_nirmaan_demo', 'usr_business_owner');
      console.log(`🌱 Demo tenant biz_nirmaan_demo seeded successfully (development mode)`);
    } else {
      console.log(`🔒 Production mode active: automatic demo seeding disabled`);
    }
  } catch (err) {
    console.warn(`Could not seed demo tenant on startup:`, err.message);
  }
});

process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server');
  server.close(() => {
    console.log('HTTP server closed');
  });
});

module.exports = server;
