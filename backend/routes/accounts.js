const express = require('express');
const { accounts } = require('../data/seed');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// All account routes require authentication
router.use(authenticateToken);

router.get('/primary', (req, res) => {
  const userId = req.user.userId;
  const account = accounts.find(a => a.userId === userId);

  if (!account) {
    return res.status(404).json({
      error: { code: 'NOT_FOUND', message: 'No primary account found' }
    });
  }

  res.json({
    id: account.id,
    maskedNumber: account.maskedNumber,
    balancePaise: account.balancePaise,
    primaryVpa: account.primaryVpa
  });
});

module.exports = router;
