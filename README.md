# PayLite 💸

A lightweight, UPI-style person-to-person payments app built with Flutter and Node.js. 

PayLite allows users to pay any VPA (Virtual Payment Address) or scan a QR code in under ten seconds, request money from others, and see payment status in real-time.

## Features
- **Sign in and Device Binding**: Secure login with session restored from secure storage, bound to the specific device.
- **Biometric App Lock**: Background locking and biometric (fingerprint/face ID) unlock.
- **Scan and Pay**: Easily scan UPI QR codes to initiate a payment.
- **Pay to VPA**: Verify and pay to any valid VPA address.
- **Idempotent Payments**: Guarantees that users are never charged twice for the same transaction, even on a flaky network.
- **Real-time Payment Status**: See a pending payment succeed natively without needing to refresh.
- **Request Money**: Send and manage collect requests from other users.
- **History & Search**: Fast, paginated transaction history with filtering and search capabilities.

## Architecture

PayLite follows a strict 4-layer architecture separating UI from Business Logic and Data handling. State is managed using **Riverpod**, and routing is handled via **GoRouter**.

![PayLite Architecture Diagram](P01_PayLite_Architecture.png)

### The 4 Layers:
1. **Presentation (Screens & Widgets)**: Dumb UI that only watches Riverpod providers and triggers actions. It handles no HTTP calls or business logic.
2. **State (Riverpod)**: Holds `AsyncValue`s. Stores state like session tokens, active payment flows, and paginated history.
3. **Data (Repositories)**: Communicates with the backend using Dio. It converts JSON into strongly-typed Dart models (via Freezed) and maps HTTP errors to a sealed `BankError` class.
4. **Core (Shared Utilities)**: Contains reusable infrastructure like the Dio client, SecureSessionStore, BiometricService, and validators.

## Project Structure (Monorepo)

```text
paylite/
├── backend/          # Node.js + Express Mock API (Coming soon in Phase 1)
└── lib/
    ├── app/          # Theme, Routes, and GoRouter setup
    ├── core/         # Network client, Secure Storage, Errors, Validators
    └── features/     # Feature-first structure
        ├── auth/     # Login and Session management
        ├── home/     # Balance and quick actions
        ├── scan/     # QR code scanner
        ├── pay/      # VPA lookup, Payment Flow, PIN pad, Status
        ├── collect/  # Request money features
        └── history/  # Transaction history
```

## Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.13+)
- [Node.js](https://nodejs.org/) (for the backend mock API)

### 1. Run the Backend API
*Note: The backend is currently being built in Phase 1.*
```bash
cd backend
npm install
npm start
```
The server will run on `http://localhost:3000`.

### 2. Run the Flutter App
Open a new terminal window in the root directory:
```bash
flutter pub get

# Run on Android emulator or connected device
flutter run --dart-define=API_URL=http://10.0.2.2:3000

# Run on iOS simulator
flutter run --dart-define=API_URL=http://localhost:3000
```
*(Note: `10.0.2.2` is a special alias to your host loopback interface for Android emulators).*

## Code Quality & CI
- **Strict Lints**: Configured in `analysis_options.yaml` to ensure clean, bug-free code.
- **No Stack Traces in UI**: All Dio errors are mapped to plain-language `BankError` messages.
- **Testing**: Built with testability in mind, aiming for >70% coverage.
