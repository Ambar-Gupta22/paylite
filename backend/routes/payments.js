const express = require('express');
const { v4: uuidv4 } = require('uuid');
const { payments, accounts, vpas } = require('../data/seed');
const { authenticateToken } = require('../middleware/auth');
const idempotency = require('../middleware/idempotency');

const router = express.Router();

router.use(authenticateToken);

// GET /payments/:id
router.get('/:id', (req, res) => {
  const payment = payments.find(p => p.id === req.params.id && p.userId === req.user.userId);
  if (!payment) {
    return res.status(404).json({ error: { code: 'NOT_FOUND', message: 'Payment not found' } });
  }
  res.json(payment);
});

// GET /payments
router.get('/', (req, res) => {
  const { cursor, filter, q } = req.query;
  const userId = req.user.userId;

  let userPayments = payments.filter(p => p.userId === userId);

  // Sorting descending by createdAt
  userPayments.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));

  // Filter
  if (filter && ['sent', 'received', 'failed'].includes(filter)) {
    if (filter === 'failed') {
      userPayments = userPayments.filter(p => p.status === 'FAILED');
    } else {
      userPayments = userPayments.filter(p => p.direction === filter && p.status !== 'FAILED');
    }
  }

  // Search
  if (q) {
    const query = q.toLowerCase();
    userPayments = userPayments.filter(p => 
      p.counterparty.toLowerCase().includes(query) ||
      (p.note && p.note.toLowerCase().includes(query))
    );
  }

  // Pagination (Cursor = index for simplicity in this mock)
  const limit = 15;
  let startIndex = 0;
  if (cursor) {
    startIndex = parseInt(cursor, 10);
    if (isNaN(startIndex)) startIndex = 0;
  }

  const items = userPayments.slice(startIndex, startIndex + limit);
  const nextCursor = (startIndex + limit < userPayments.length) ? (startIndex + limit).toString() : null;

  res.json({ items, nextCursor });
});

// POST /payments (Idempotent)
router.post('/', idempotency, (req, res) => {
  const { payeeVpa, amountPaise, note, pinHash } = req.body;
  const userId = req.user.userId;

  // Basic validations
  if (!payeeVpa || !amountPaise || !pinHash) {
    return res.status(422).json({ error: { code: 'VALIDATION_ERROR', message: 'Missing required fields' } });
  }
  if (amountPaise <= 0 || amountPaise > 10000000) { // Max 1,00,000 INR
    return res.status(422).json({ error: { code: 'LIMIT_EXCEEDED', message: 'Maximum payment limit is ₹1,00,000' } });
  }

  const vpa = vpas.find(v => v.address === payeeVpa.toLowerCase());
  if (!vpa) {
    return res.status(422).json({ error: { code: 'VALIDATION_ERROR', message: 'Invalid VPA' } });
  }

  const account = accounts.find(a => a.userId === userId);
  if (!account || account.balancePaise < amountPaise) {
    return res.status(422).json({ error: { code: 'INSUFFICIENT_FUNDS', message: 'Insufficient balance' } });
  }

  // In a real app, verify pinHash here

  const payment = {
    id: uuidv4(),
    userId,
    direction: 'sent',
    counterparty: vpa.verifiedName || payeeVpa,
    amountPaise,
    note,
    status: 'PENDING',
    upiRef: Math.floor(100000000000 + Math.random() * 900000000000).toString(), // Random 12 digit
    createdAt: new Date().toISOString()
  };

  payments.unshift(payment);

  // Simulate async settlement
  const delay = Math.floor(Math.random() * 7000) + 3000; // 3 to 10 seconds
  setTimeout(() => {
    // 90% success, 10% failure
    const isSuccess = Math.random() < 0.9;
    payment.status = isSuccess ? 'SUCCESS' : 'FAILED';
    if (isSuccess) {
      account.balancePaise -= amountPaise;
    }
    console.log(`[Settlement] Payment ${payment.id} settled as ${payment.status}`);
  }, delay);

  // Return immediately with PENDING
  res.json(payment);
});

module.exports = router;
