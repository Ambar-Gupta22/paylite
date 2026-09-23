const express = require('express');
const cors = require('cors');

const authRoutes = require('./routes/auth');
const accountsRoutes = require('./routes/accounts');
const vpaRoutes = require('./routes/vpa');
const paymentsRoutes = require('./routes/payments');
const collectRoutes = require('./routes/collect');
const chaosMiddleware = require('./middleware/chaos');

const app = express();
app.use(cors());
app.use(express.json());

// Global chaos middleware for simulating network flakiness (optional, triggered via ?chaos=true)
app.use(chaosMiddleware);

// Routes
app.use('/auth', authRoutes);
app.use('/accounts', accountsRoutes);
app.use('/vpa', vpaRoutes);
app.use('/payments', paymentsRoutes);
app.use('/collect-requests', collectRoutes);

// Fallback error handler
app.use((err, req, res, next) => {
  console.error('[Unhandled Error]', err);
  res.status(500).json({
    error: {
      code: 'SERVER_ERROR',
      message: 'An unexpected error occurred.',
      traceId: req.headers['x-trace-id'] || 'unknown',
    }
  });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 PayLite Mock API running on http://localhost:${PORT}`);
});
