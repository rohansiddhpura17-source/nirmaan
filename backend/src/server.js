const app = require('./app');
const config = require('./config/environment');

const PORT = config.port;

const server = app.listen(PORT, () => {
  console.log(`=========================================`);
  console.log(`🚀 Nirmaan Backend Service Running`);
  console.log(`🌍 Environment: ${config.env}`);
  console.log(`📡 URL: http://localhost:${PORT}${config.apiPrefix}`);
  console.log(`🩺 Health: http://localhost:${PORT}${config.apiPrefix}/health`);
  console.log(`=========================================`);
});

process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server');
  server.close(() => {
    console.log('HTTP server closed');
  });
});

module.exports = server;
