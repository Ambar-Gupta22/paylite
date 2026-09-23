// In-memory store for idempotency keys
const idempotencyStore = new Map();

function idempotency(req, res, next) {
  // Only apply to POST/PATCH/PUT
  if (!['POST', 'PATCH', 'PUT'].includes(req.method)) {
    return next();
  }

  const key = req.headers['idempotency-key'];
  
  if (!key) {
    return next();
  }

  // Check if we already processed this key
  if (idempotencyStore.has(key)) {
    const cachedResponse = idempotencyStore.get(key);
    console.log(`[Idempotency] Serving cached response for key: ${key}`);
    return res.status(cachedResponse.status).json(cachedResponse.body);
  }

  // Intercept the res.json() to save the response
  const originalJson = res.json.bind(res);
  res.json = (body) => {
    // Save to store before sending
    idempotencyStore.set(key, {
      status: res.statusCode,
      body: body
    });
    console.log(`[Idempotency] Saved response for key: ${key}`);
    return originalJson(body);
  };

  next();
}

module.exports = idempotency;
