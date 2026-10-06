/**
 * AI Endpoint Rate Limiter Middleware
 *
 * Protects Gemini and AI endpoints against abuse, high request volumes,
 * and cost overruns. Restricts requests per IP/business window.
 */

const WINDOW_MS = 60 * 1000; // 1 minute window
const MAX_REQUESTS_PER_WINDOW = 30; // 30 requests per minute

const requestCounts = new Map();

// Periodic cleanup of expired records every 2 minutes
setInterval(() => {
  const now = Date.now();
  for (const [key, record] of requestCounts.entries()) {
    if (now - record.startTime > WINDOW_MS) {
      requestCounts.delete(key);
    }
  }
}, 2 * 60 * 1000).unref();

function aiRateLimiter(req, res, next) {
  // Use businessId if authenticated, otherwise client IP
  const clientKey = req.businessId
    ? `biz_${req.businessId}`
    : req.ip || req.connection.remoteAddress || 'unknown_client';

  const now = Date.now();
  let record = requestCounts.get(clientKey);

  if (!record || now - record.startTime > WINDOW_MS) {
    record = {
      startTime: now,
      count: 1,
    };
    requestCounts.set(clientKey, record);
    res.setHeader('X-RateLimit-Limit', MAX_REQUESTS_PER_WINDOW);
    res.setHeader('X-RateLimit-Remaining', MAX_REQUESTS_PER_WINDOW - 1);
    return next();
  }

  record.count += 1;
  const remaining = Math.max(0, MAX_REQUESTS_PER_WINDOW - record.count);
  res.setHeader('X-RateLimit-Limit', MAX_REQUESTS_PER_WINDOW);
  res.setHeader('X-RateLimit-Remaining', remaining);

  if (record.count > MAX_REQUESTS_PER_WINDOW) {
    res.setHeader('Retry-After', Math.ceil((record.startTime + WINDOW_MS - now) / 1000));
    return res.status(429).json({
      success: false,
      message: 'Rate limit exceeded for AI assistant. Please wait a moment before trying again.',
      error: 'RATE_LIMIT_EXCEEDED',
    });
  }

  next();
}

// Reset helper for testing
aiRateLimiter._resetForTesting = () => {
  requestCounts.clear();
};

module.exports = {
  aiRateLimiter,
  WINDOW_MS,
  MAX_REQUESTS_PER_WINDOW,
};
