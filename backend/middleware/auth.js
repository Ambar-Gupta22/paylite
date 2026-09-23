const jwt = require('jsonwebtoken');

const SECRET = 'paylite_mock_secret_key_123';

function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

  if (token == null) {
    return res.status(401).json({
      error: { code: 'UNAUTHORIZED', message: 'No authorization token provided' }
    });
  }

  jwt.verify(token, SECRET, (err, user) => {
    if (err) {
      return res.status(401).json({
        error: { code: 'UNAUTHORIZED', message: 'Token is invalid or expired' }
      });
    }

    // Check device binding
    const requestDeviceId = req.headers['x-device-id'];
    if (!requestDeviceId || user.deviceId !== requestDeviceId) {
      return res.status(401).json({
        error: { code: 'UNAUTHORIZED', message: 'Session invalid for this device' }
      });
    }

    req.user = user;
    next();
  });
}

function generateToken(user) {
  return jwt.sign(user, SECRET, { expiresIn: '24h' });
}

module.exports = { authenticateToken, generateToken };
