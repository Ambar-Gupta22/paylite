const express = require('express');
const { users } = require('../data/seed');
const { generateToken } = require('../middleware/auth');

const router = express.Router();

// Simple in-memory tracker for locked accounts
const failedAttempts = new Map();

router.post('/login', (req, res) => {
  const { customerId, pin } = req.body;
  const deviceId = req.headers['x-device-id'];

  if (!deviceId) {
    return res.status(400).json({
      error: { code: 'BAD_REQUEST', message: 'x-device-id header is required' }
    });
  }

  const user = users.find(u => u.customerId === customerId);

  if (!user) {
    return res.status(401).json({
      error: { code: 'INVALID_CREDENTIALS', message: 'Invalid Customer ID or PIN' }
    });
  }

  const attempts = failedAttempts.get(customerId) || 0;
  if (attempts >= 5) {
    return res.status(423).json({
      error: { code: 'ACCOUNT_LOCKED', message: 'Account locked due to too many failed attempts' }
    });
  }

  if (user.pin !== pin) {
    failedAttempts.set(customerId, attempts + 1);
    return res.status(401).json({
      error: { code: 'INVALID_CREDENTIALS', message: 'Invalid Customer ID or PIN' }
    });
  }

  // Success
  failedAttempts.delete(customerId);
  const token = generateToken({ userId: user.id, deviceId, name: user.name });

  res.json({
    token,
    deviceId,
    user: {
      id: user.id,
      name: user.name,
      customerId: user.customerId
    }
  });
});

module.exports = router;
