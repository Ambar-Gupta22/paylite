const { v4: uuidv4 } = require('uuid');

function chaosMiddleware(req, res, next) {
  // Always inject a traceId for observability
  const traceId = uuidv4();
  req.headers['x-trace-id'] = traceId;
  res.setHeader('X-Trace-Id', traceId);

  // If chaos mode is off, just continue
  if (req.query.chaos !== 'true') {
    return next();
  }

  // 10% chance of random server error
  if (Math.random() < 0.1) {
    console.log(`[Chaos] Simulating 500 Server Error for ${req.path}`);
    return res.status(500).json({
      error: {
        code: 'SERVER_ERROR',
        message: 'Simulated backend failure',
        traceId: traceId
      }
    });
  }

  // 20% chance of high latency (3-8 seconds)
  if (Math.random() < 0.2) {
    const delay = Math.floor(Math.random() * 5000) + 3000;
    console.log(`[Chaos] Simulating ${delay}ms delay for ${req.path}`);
    return setTimeout(next, delay);
  }

  next();
}

module.exports = chaosMiddleware;
