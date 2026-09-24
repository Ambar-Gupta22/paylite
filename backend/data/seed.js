const { v4: uuidv4 } = require('uuid');

const users = [
  { id: 'u1', customerId: 'customer001', pin: '1234', name: 'Priya Sharma' },
  { id: 'u2', customerId: 'customer002', pin: '1234', name: 'Ramesh Singh' },
  { id: 'u3', customerId: 'customer003', pin: '1234', name: 'Asha Patel' },
];

const accounts = [
  { id: 'acc1', userId: 'u1', maskedNumber: 'XXXXXX1234', balancePaise: 5000000, primaryVpa: 'priya@paylite' }, // 50,000 INR
  { id: 'acc2', userId: 'u2', maskedNumber: 'XXXXXX5678', balancePaise: 1500000, primaryVpa: 'ramesh@paylite' },
  { id: 'acc3', userId: 'u3', maskedNumber: 'XXXXXX9012', balancePaise: 8000000, primaryVpa: 'asha@paylite' },
];

const vpas = [
  { address: 'priya@paylite', verifiedName: 'Priya Sharma', bankName: 'PayLite Bank' },
  { address: 'ramesh@paylite', verifiedName: 'Ramesh Singh', bankName: 'PayLite Bank' },
  { address: 'asha@paylite', verifiedName: 'Asha Patel', bankName: 'PayLite Bank' },
  { address: 'shopkeeper@paylite', verifiedName: 'Sharma General Store', bankName: 'Merchants Bank' },
  { address: 'unknown-fail@paylite', verifiedName: null, bankName: null },
];

const payments = [
  // A few seed payments for Priya
  {
    id: uuidv4(),
    userId: 'u1',
    direction: 'sent',
    counterparty: 'Ramesh Singh',
    amountPaise: 50000, // 500 INR
    note: 'Dinner',
    status: 'SUCCESS',
    upiRef: '314298172938',
    createdAt: new Date(Date.now() - 86400000 * 2).toISOString(), // 2 days ago
  },
  {
    id: uuidv4(),
    userId: 'u1',
    direction: 'received',
    counterparty: 'Asha Patel',
    amountPaise: 15000, // 150 INR
    note: 'Cab share',
    status: 'SUCCESS',
    upiRef: '314298172939',
    createdAt: new Date(Date.now() - 86400000).toISOString(), // 1 day ago
  },
  {
    id: uuidv4(),
    userId: 'u1',
    direction: 'sent',
    counterparty: 'Sharma General Store',
    amountPaise: 125000, // 1250 INR
    note: 'Groceries',
    status: 'FAILED',
    upiRef: '314298172940',
    createdAt: new Date(Date.now() - 3600000).toISOString(), // 1 hour ago
  },
];

const collectRequests = [
  // A pending request for Priya
  {
    id: uuidv4(),
    from: 'ramesh@paylite',
    to: 'priya@paylite',
    amountPaise: 25000, // 250 INR
    note: 'Movie tickets',
    status: 'PENDING',
    createdAt: new Date(Date.now() - 86400000).toISOString(),
    expiresAt: new Date(Date.now() + 86400000).toISOString(), // expires in 1 day
  },
  // An expired request
  {
    id: uuidv4(),
    from: 'asha@paylite',
    to: 'priya@paylite',
    amountPaise: 10000,
    note: 'Coffee',
    status: 'PENDING',
    createdAt: new Date(Date.now() - 172800000).toISOString(),
    expiresAt: new Date(Date.now() - 3600000).toISOString(), // expired 1 hr ago
  }
];

module.exports = {
  users,
  accounts,
  vpas,
  payments,
  collectRequests,
};
