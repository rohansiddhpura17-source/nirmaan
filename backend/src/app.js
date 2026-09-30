const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');

const config = require('./config/environment');
const routes = require('./routes');
const { errorHandler, notFoundHandler } = require('./middleware/errorHandler');

const app = express();

// Security and utility middlewares
app.use(helmet());
app.use(cors({ origin: config.allowedOrigins }));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

if (config.env !== 'test') {
  app.use(morgan('dev'));
}

// API Routes
app.use(config.apiPrefix, routes);

// 404 & Error Handlers
app.use(notFoundHandler);
app.use(errorHandler);

module.exports = app;
