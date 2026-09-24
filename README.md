# PayLite

> UPI-style person-to-person payments with QR scan-and-pay.

PayLite is a Flutter application demonstrating a complete mobile payment flow. It connects to a mock Node.js backend.

## Features

- **Authentication & Security**: PIN-based login, biometric app lock, device binding.
- **Home & Balance**: View masked balance, recent payments.
- **Scan & Pay**: Scan UPI QR codes to initiate payments.
- **Pay to VPA**: Enter VPA manually, verify payee name.
- **Idempotency**: Prevents duplicate debits on network retries.
- **Payment Status**: Real-time polling for payment resolution.
- **Collect Requests**: Send and respond to money requests.
- **History & Search**: Infinite scrolling transaction history with search and filters.

## Project Structure

This project follows a strict feature-driven architecture using Riverpod for state management.

```
lib/
├── app/          # Theme and Router config
├── core/         # Shared utilities, API client, generic widgets
├── features/     # Feature modules (auth, home, scan, pay, collect, history)
```

Within each feature, you'll find:
- `domain/` - Models and entities
- `data/` - Repositories and DTOs
- `state/` - Riverpod providers
- `presentation/` - Screens and UI components

## Setup Instructions

### 1. Start the Backend

The mock backend is a Node.js Express server.

```bash
cd backend
npm install
npm start
```
The server will run on `http://localhost:3000`.

### 2. Run the Flutter App

Run the app, pointing it to the local backend:

```bash
flutter run --dart-define=API_URL=http://localhost:3000
```
*(For Android emulator, use `http://10.0.2.2:3000` instead)*

### Test Accounts

The backend is seeded with the following users:
- **Priya**: `customer001` (VPA: `priya@paylite`)
- **Ramesh**: `customer002` (VPA: `ramesh@paylite`)
- **Asha**: `customer003` (VPA: `asha@paylite`)

The **PIN is any 4-digit number** (e.g., `1234`).

## Testing

Run unit tests:
```bash
flutter test
```

## Known Limitations
- The "Split Bill" and "Share Receipt" features are not implemented in this version.
