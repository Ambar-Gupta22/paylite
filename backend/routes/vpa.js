const express = require('express');
const { vpas } = require('../data/seed');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

router.use(authenticateToken);

router.get('/:address', (req, res) => {
  const address = req.params.address.trim().toLowerCase();
  const vpa = vpas.find(v => v.address === address);

  if (!vpa || !vpa.verifiedName) {
    return res.status(404).json({
      error: { code: 'VPA_NOT_FOUND', message: 'No account found for this UPI ID' }
    });
  }

  res.json({
    address: vpa.address,
    verifiedName: vpa.verifiedName,
    bankName: vpa.bankName
  });
});

module.exports = router;
