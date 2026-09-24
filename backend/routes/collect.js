const express = require('express');
const { v4: uuidv4 } = require('uuid');
const { collectRequests, accounts, payments, vpas } = require('../data/seed');
const { authenticateToken } = require('../middleware/auth');
const idempotency = require('../middleware/idempotency');

const router = express.Router();

router.use(authenticateToken);

function getUserPrimaryVpa(userId) {
  const account = accounts.find(a => a.userId === userId);
  return account ? account.primaryVpa : null;
}

// GET /collect-requests
router.get('/', (req, res) => {
  const { type } = req.query; // 'incoming' or 'outgoing'
  const userVpa = getUserPrimaryVpa(req.user.userId);

  if (!userVpa) {
    return res.status(404).json({ error: { code: 'NOT_FOUND', message: 'User VPA not found' } });
  }

  let requests = [];
  if (type === 'incoming') {
    requests = collectRequests.filter(r => r.to === userVpa);
  } else if (type === 'outgoing') {
    requests = collectRequests.filter(r => r.from === userVpa);
  } else {
    // Both
    requests = collectRequests.filter(r => r.to === userVpa || r.from === userVpa);
  }

  // Sort descending by creation/expiration
  requests.sort((a, b) => new Date(b.expiresAt) - new Date(a.expiresAt));

  res.json(requests);
});

// POST /collect-requests
router.post('/', (req, res) => {
  const { payeeVpa, amountPaise, note } = req.body;
  const userVpa = getUserPrimaryVpa(req.user.userId);

  if (!userVpa) {
    return res.status(404).json({ error: { code: 'NOT_FOUND', message: 'User VPA not found' } });
  }

  if (!payeeVpa || !amountPaise) {
    return res.status(422).json({ error: { code: 'VALIDATION_ERROR', message: 'Missing fields' } });
  }

  const vpa = vpas.find(v => v.address === payeeVpa.toLowerCase());
  if (!vpa) {
    return res.status(422).json({ error: { code: 'VALIDATION_ERROR', message: 'Invalid VPA' } });
  }

  const request = {
    id: uuidv4(),
    from: userVpa,
    to: payeeVpa.toLowerCase(),
    amountPaise,
    note,
    status: 'PENDING',
    createdAt: new Date().toISOString(),
    expiresAt: new Date(Date.now() + 48 * 3600000).toISOString(), // 48h from now
  };

  collectRequests.unshift(request);
  res.json(request);
});

// POST /collect-requests/:id/pay
router.post('/:id/pay', idempotency, (req, res) => {
  const { pinHash } = req.body;
  const requestId = req.params.id;
  const userId = req.user.userId;
  const userVpa = getUserPrimaryVpa(userId);

  const request = collectRequests.find(r => r.id === requestId && r.to === userVpa);
  if (!request) {
    return res.status(404).json({ error: { code: 'NOT_FOUND', message: 'Request not found' } });
  }

  if (request.status !== 'PENDING') {
    return res.status(422).json({ error: { code: 'VALIDATION_ERROR', message: `Request is already ${request.status}` } });
  }

  if (new Date(request.expiresAt) < new Date()) {
    request.status = 'EXPIRED';
    return res.status(410).json({ error: { code: 'EXPIRED', message: 'Request has expired' } });
  }

  const account = accounts.find(a => a.userId === userId);
  if (!account || account.balancePaise < request.amountPaise) {
    return res.status(422).json({ error: { code: 'INSUFFICIENT_FUNDS', message: 'Insufficient balance' } });
  }

  // Create payment
  const payment = {
    id: uuidv4(),
    userId,
    direction: 'sent',
    counterparty: request.from,
    amountPaise: request.amountPaise,
    note: request.note,
    status: 'PENDING',
    upiRef: Math.floor(100000000000 + Math.random() * 900000000000).toString(),
    createdAt: new Date().toISOString()
  };

  payments.unshift(payment);
  request.status = 'PAID';

  // Async settlement
  setTimeout(() => {
    const isSuccess = Math.random() < 0.9;
    payment.status = isSuccess ? 'SUCCESS' : 'FAILED';
    if (isSuccess) account.balancePaise -= request.amountPaise;
  }, 3000);

  res.json(payment);
});

// POST /collect-requests/:id/decline
router.post('/:id/decline', (req, res) => {
  const requestId = req.params.id;
  const userVpa = getUserPrimaryVpa(req.user.userId);

  const request = collectRequests.find(r => r.id === requestId && r.to === userVpa);
  if (!request) {
    return res.status(404).json({ error: { code: 'NOT_FOUND', message: 'Request not found' } });
  }

  if (request.status !== 'PENDING') {
    return res.status(422).json({ error: { code: 'VALIDATION_ERROR', message: `Request is already ${request.status}` } });
  }

  request.status = 'DECLINED';
  res.json(request);
});

module.exports = router;
