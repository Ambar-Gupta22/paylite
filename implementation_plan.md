# PayLite — 1.5-Day Implementation Plan (v2)

> UPI-style person-to-person payments with QR scan-and-pay  
> **Solo developer** · **Monorepo** · **Riverpod 2.x with `AsyncNotifier`/`Notifier`**

---

## Git Branching Strategy

All work happens on feature branches. PRs are raised against `main` and merged after self-review.

| Branch Name | Phase | What it delivers | Merges after |
|-------------|-------|------------------|--------------|
| `feat/phase-0-foundations` | Phase 0 | Flutter project, folder structure, theme, router, dependencies | — |
| `feat/phase-1-backend` | Phase 1 | Complete Node.js mock API | Phase 0 merged |
| `feat/phase-2-core-data` | Phase 2 | Core layer + Data layer (models, repos, Dio, errors, security) | Phase 0 merged |
| `feat/phase-3-screens` | Phase 3 | All screens, state providers, full pay flow | Phase 1 + 2 merged |
| `feat/phase-4-polish` | Phase 4 | Edge cases, accessibility, animations, security hardening | Phase 3 merged |
| `feat/phase-5-ship` | Phase 5 | Tests, CI pipeline, release build, README | Phase 4 merged |

### Workflow per branch:
```
1. git checkout main && git pull
2. git checkout -b feat/phase-X-name
3. Work, commit frequently with descriptive messages
4. git push origin feat/phase-X-name
5. Create PR on GitHub → self-review → merge to main
6. git checkout main && git pull (before next branch)
```

> [!TIP]
> **Commit convention**: `phase-X: short description` (e.g., `phase-1: add payments endpoint with idempotency`)

---

## Requirements Traceability Matrix

I've cross-checked every requirement from the capstone document against this plan. Here's the full audit:

### Functional Requirements (Features)

| ID | Feature | Priority | Status | Plan Coverage |
|----|---------|----------|--------|---------------|
| F1 | Sign in and device binding | **Must** | ✅ Covered | Phase 2 (repo) + Phase 3A (screen + state) |
| F2 | Home and balance | **Must** | ✅ Covered | Phase 3B |
| F3 | Scan and pay | **Must** | ✅ Covered | Phase 3C |
| F4 | Pay to VPA | **Must** | ✅ Covered | Phase 3C |
| F5 | Idempotent payment | **Must** | ✅ Covered | Phase 1 (backend) + Phase 3C (key gen) + Phase 5 (unit test) |
| F6 | Payment status | **Must** | ✅ Covered | Phase 3C (polling provider) |
| F7 | Request money | **Should** | ✅ Covered | Phase 3D |
| F8 | Split bill | **Should** | ⏭️ Skipped | Time constraint — low rubric ROI |
| F9 | History and search | **Must** | ✅ Covered | Phase 3E |
| F10 | Receipt and share | **Could** | ⏭️ Skipped | Add if time allows after Phase 4 |

### Acceptance Criteria Verification

| Feature | Criterion | Where it's handled |
|---------|-----------|-------------------|
| F1 | Second device cannot use first device's token | Backend: `POST /auth/login` binds token to `deviceId`; middleware rejects mismatched `deviceId` header |
| F1 | Reopening requires biometrics before balance shown | `app_lock.dart` + `WidgetsBindingObserver.didChangeAppLifecycleState` |
| F2 | Balance hidden until eye tapped | `home_screen.dart`: `_balanceVisible` state toggle with eye icon |
| F2 | Pull to refresh re-fetches balance and recent payments | `RefreshIndicator` wrapping home body; `ref.invalidate(accountProvider)` |
| F3 | Malformed QR shows error, never navigates | `qr_parser.dart` returns `Result` type; error → snackbar, no navigation |
| F3 | **QR with fixed amount locks the amount field** | `pay_screen.dart`: if `qrPayload.amount != null`, amount field is `readOnly: true` |
| F4 | Unknown VPAs show error before amount step | `vpaLookup` provider returns 404 → show "No account found for this UPI ID" |
| F4 | Amounts above ₹1,00,000 blocked | `validators.dart`: `validateAmount()` with limit; pay screen uses it |
| F5 | Retry returns original receipt | Backend idempotency store: same key → same response |
| F5 | Unit test proves one key = one debit | Phase 5: `test/unit/idempotency_test.dart` |
| F6 | Pending → success without user refresh | `paymentStatus.family` polls every 5s with `Timer.periodic` |
| F6 | Polling stops when screen closed | Provider `autoDispose` + `ref.onDispose(() => timer.cancel())` |
| F7 | Declined shows within one refresh | Requests screen has pull-to-refresh |
| F7 | Expired (48h) cannot be paid | Backend returns `410 EXPIRED`; UI disables Pay button + shows message |
| F9 | 500+ rows at 60 fps | Cursor pagination + `ListView.builder` (no `ListView(children:)`) |
| F9 | Filters and search combine | `historyProvider` takes both filter enum and search string |

### Baseline Requirements (B1–B9)

| # | Requirement | Status | Where |
|---|------------|--------|-------|
| B1 | Authentication | ✅ | Phase 2 (secure storage restore) + Phase 3A (login, logout in profile/drawer) |
| B2 | App lock | ✅ | Phase 2 (`app_lock.dart`: `WidgetsBindingObserver`, biometric on `resumed`, "Log out instead" button) |
| B3 | Route guard | ✅ | Phase 0 (`router.dart`: `redirect` checks `sessionProvider`; deep links → login if unauthenticated) |
| B4 | Three states everywhere | ✅ | Phase 3 (every screen uses `AsyncValue.when(loading: skeleton, error: retry, data: content)`) |
| B5 | Refresh | ✅ | Phase 3–4 (`RefreshIndicator` on every list; `ref.invalidate()` after mutations) |
| B6 | Idempotency | ✅ | Phase 1 (backend middleware) + Phase 3C (key generated once per review screen) |
| B7 | Errors in plain language | ✅ | Phase 2 (`bank_error.dart` sealed type → user-friendly message getter; no stack traces in UI) |
| B8 | Accessibility | ✅ | Phase 4 (tooltips on icon buttons, text alternatives for color, 200% text scale test, `MediaQuery.disableAnimations` check) |
| B9 | Environments | ✅ | Phase 0 (`api_config.dart` reads `--dart-define=API_URL`) |

### Non-Functional Requirements (PayLite-specific, Table 18)

| Quality | Requirement | Status | How |
|---------|-------------|--------|-----|
| Performance | Pay flow Scan→Status < 10s | ✅ | Minimal navigation steps; async calls only for VPA verify + payment |
| Performance | History 60 fps with 500 rows | ✅ | `ListView.builder` + cursor paging; profile mode verification in Phase 5 |
| Reliability | Zero duplicate debits | ✅ | Idempotency-Key + backend dedup + state machine prevents double-tap |
| Reliability | Pending resolves within 2 min | ✅ | Polling for 2 min, then "We'll notify you" |
| Security | Token in Keychain/Keystore | ✅ | `flutter_secure_storage` |
| Security | PIN never stored/logged, hash only | ✅ | Hash in `pin_screen.dart`, send hash; `kReleaseMode` log guard |
| Security | FLAG_SECURE on pay/PIN screens | ✅ | Phase 4: `FlutterWindowManager` or platform channel |
| Availability | Server down → clear status, no stale balance | ✅ | Error state shows "Could not reach server"; balance shows "Last updated at..." |
| Accessibility | PIN pad 200% font scale | ✅ | Phase 4: responsive PIN pad using `MediaQuery.textScaler` |
| Accessibility | Icon button tooltips | ✅ | Phase 4: `Tooltip` on every `IconButton` |
| Accessibility | Reduce motion honoured | ✅ | Phase 4: check `MediaQuery.disableAnimations` |
| Usability | First-time user pays QR in 3 taps | ✅ | Home → Scan (tap 1) → Confirm after auto-fill (tap 2) → PIN confirm (tap 3) |
| Testability | ≥70% line coverage | ✅ | Phase 5 |
| Testability | Idempotency + polling unit tested | ✅ | Phase 5 |
| Testability | One integration test scan→status | ✅ | Phase 5 |
| Observability | traceId in debug logs | ✅ | Phase 2: `error_mapper.dart` extracts `traceId` from response; `BankError` carries it; logged via `debugPrint` |
| Observability | No PII in logs | ✅ | Phase 4: audit all log statements |

### Module Evidence Requirements (M1–M7)

| Module | Required Evidence | Status | Where |
|--------|------------------|--------|-------|
| M1 | Null-safe models; int paise; no `dynamic` outside fromJson; const constructors | ✅ | Phase 2: freezed models with `const` factories |
| M2 | Responsive layouts at 200% text; forms with validators; go_router with nested routes, path/query params, pop results | ✅ | Phase 0 (router) + Phase 3 (forms) + Phase 4 (responsive check) |
| M3 | Riverpod throughout; `ref.watch` in build, `ref.read` in handlers; immutable state; router guard driven by session | ✅ | Phase 3 (all providers) + Phase 0 (guard) |
| M4 | One repo per domain; Dio + auth/401 interceptors; sealed error; `AsyncValue.when` everywhere; idempotent money | ✅ | Phase 2 (repos, Dio, errors) + Phase 3 (AsyncValue) |
| M5 | Profile mode before/after; skeletons; 2+ purposeful animations with reduce-motion; secure storage; biometric lock; FLAG_SECURE; no secrets in logs | ✅ | Phase 4 (profiling, animations, security) |
| M6 | Unit tests (business rules), widget tests (key screens), 1 integration test; ≥70% coverage; GitHub Actions on PR | ✅ | Phase 5 |
| M7 | Working demo, architecture walkthrough, retrospective | ✅ | Phase 5 (README + demo recording) |

### Edge Cases

| Edge Case | Status | Where |
|-----------|--------|-------|
| Camera permission denied → explain + settings button | ✅ | Phase 3C: `scan_screen.dart` permission handling |
| QR with trailing space/lowercase VPA → normalise | ✅ | Phase 2: `qr_parser.dart` trims + lowercases |
| Network drops after PIN → show Pending, never Failed | ✅ | Phase 3C: `payment_flow_notifier` catches timeout → navigates to status with PENDING |
| Double-tap Confirm → only one request | ✅ | Phase 3C: state machine transitions to `processing` → button disabled |
| Collect request expires on screen → disable Pay | ✅ | Phase 3D: check `expiresAt` vs `DateTime.now()` before enabling button |
| Split paise ₹100/3 → extra to first participant | ⏭️ N/A | F8 Split Bill is skipped |

### Evaluation Rubric Coverage (100 points)

| Area | Points | Coverage |
|------|--------|----------|
| Functional completeness (Must + Should attempted) | 25 | All 7 Must + F7 Should ✅ |
| Architecture & code quality (layers, no Dio in widgets) | 15 | Strict layer separation ✅ |
| State management (watch/read, immutable, no stale) | 10 | Riverpod AsyncNotifier ✅ |
| API & error handling (repos, BankError, 3 states, idempotency) | 15 | Full coverage ✅ |
| Performance & motion (measured, animations, reduce motion) | 10 | Phase 4 ✅ |
| Security (secure storage, biometric, FLAG_SECURE, logs) | 10 | Phase 2 + 4 ✅ |
| Testing & CI/CD (coverage, meaningful tests, pipeline, protected main) | 10 | Phase 5 ✅ |
| Demo & communication (demo, retrospective, architecture) | 5 | Phase 5 (README) ✅ |

---

## Phase 0 — Project Setup & Foundations (45 min)

**Branch**: `feat/phase-0-foundations`

### Step 0.1 — Create Flutter project (5 min)
- Run `flutter create` in the repo root (monorepo — Flutter at root, backend in `backend/`)
- Configure `analysis_options.yaml` with strict lints

### Step 0.2 — Add dependencies to `pubspec.yaml` (5 min)
```yaml
dependencies:
  flutter_riverpod: ^2.6.x
  go_router: ^14.x
  dio: ^5.x
  flutter_secure_storage: ^9.x
  local_auth: ^2.x
  mobile_scanner: ^6.x
  freezed_annotation: ^2.x
  json_annotation: ^4.x
  intl: ^0.19.x          # Indian number formatting

dev_dependencies:
  freezed: ^2.x
  json_serializable: ^6.x
  build_runner: ^2.x
  mocktail: ^1.x
  flutter_lints: ^5.x
```
- Run `flutter pub get`

### Step 0.3 — Create folder structure (10 min)
Create the entire empty folder structure as specified in the architecture:
```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── router.dart
│   ├── routes.dart
│   └── theme.dart
├── core/
│   ├── errors/
│   ├── network/
│   ├── security/
│   ├── utils/
│   └── widgets/
└── features/
    ├── auth/      (domain/, data/, state/, presentation/, widgets/)
    ├── home/      (domain/, data/, state/, presentation/, widgets/)
    ├── scan/      (data/, presentation/, widgets/)
    ├── pay/       (domain/, data/, state/, presentation/, widgets/)
    ├── collect/   (domain/, data/, state/, presentation/, widgets/)
    └── history/   (state/, presentation/, widgets/)
```

### Step 0.4 — Theme setup (10 min)
- `theme.dart`: Define `AppTheme` with:
  - Color scheme (banking: deep blue primary, green for success, amber for pending, red for failed)
  - Text theme (clean, readable, scales well at 200%)
  - Component themes (cards, buttons, inputs, app bar)
- `app.dart`: `MaterialApp.router` with `ProviderScope` wrapping

### Step 0.5 — Router with session guard (10 min)
- `routes.dart`: Route path constants (`/login`, `/home`, `/scan`, `/pay`, `/pay/review`, `/pay/pin`, `/pay/status/:id`, `/requests`, `/history`)
- `router.dart`: `GoRouter` with:
  - `redirect` that checks session state → sends to `/login` if unauthenticated
  - Nested routes under `/pay` for the payment flow
  - Path and query parameters (`/pay?vpa=...&amount=...&name=...`)

### Step 0.6 — Environment config (5 min)
- `api_config.dart`: Read `API_URL` from `--dart-define` with fallback to `http://localhost:3000`
- No hardcoded URLs anywhere else

### ✅ PR: `feat/phase-0-foundations` → `main`

---

## Phase 1 — Backend (Mock Node.js API) (2.5 hours)

**Branch**: `feat/phase-1-backend`

### Step 1.1 — Project init (10 min)
- Create `backend/` directory
- `npm init -y`
- Install: `express`, `cors`, `uuid`, `jsonwebtoken`
- Create `backend/server.js` entry point
- Add `backend/.gitignore` for `node_modules/`

### Step 1.2 — Middleware (20 min)
- **`middleware/auth.js`**: Validate `Authorization: Bearer <token>` header; extract `userId` and `deviceId` from JWT payload; reject if `deviceId` header doesn't match token's device; return `401` with standard error shape
- **`middleware/idempotency.js`**: Read `Idempotency-Key` header; if key exists in store → return cached response; else execute handler, cache response by key
- **`middleware/chaos.js`**: If `?chaos=true` query param, randomly (20% chance) delay 3–8 seconds or return 500

### Step 1.3 — Seed data (15 min)
- **`data/seed.js`**: Pre-load in-memory:
  - 3 users: Priya (customer001), Ramesh (customer002), Asha (customer003)
  - 3 accounts with balances (in paise)
  - 5 VPAs: `priya@paylite`, `ramesh@paylite`, `asha@paylite`, `shopkeeper@paylite`, `unknown-fail@paylite`
  - 20 seed payment history entries (mix of SUCCESS/PENDING/FAILED, sent/received)
  - 3 seed collect requests (one pending, one declined, one expired)

### Step 1.4 — Auth endpoint (15 min)
- `POST /auth/login`
  - Body: `{ customerId, pin }`
  - Validates against seed users
  - Generates JWT with `userId + deviceId` (deviceId from `X-Device-Id` header)
  - Returns `{ token, deviceId, user: { name } }`
  - Errors: `401 INVALID_CREDENTIALS`, `423 ACCOUNT_LOCKED` (after 5 wrong attempts)

### Step 1.5 — Account endpoint (10 min)
- `GET /accounts/primary`
  - Auth required
  - Returns `{ id, maskedNumber, balancePaise, primaryVpa }`

### Step 1.6 — VPA endpoint (10 min)
- `GET /vpa/:address`
  - Auth required
  - Normalize: trim, lowercase
  - Returns `{ address, verifiedName, bankName }`
  - Errors: `404 VPA_NOT_FOUND`

### Step 1.7 — Payments endpoints (30 min) — THE CORE
- `POST /payments`
  - Auth required + Idempotency middleware
  - Body: `{ payeeVpa, amountPaise, note, pinHash }`
  - Validates: VPA exists, amount > 0, amount ≤ 10000000 (₹1,00,000), sufficient balance
  - Creates payment with `status: PENDING`
  - **Simulates async settlement**: After random 3–10s, status changes to `SUCCESS` (90%) or `FAILED` (10%)
  - Returns `{ id, status: "PENDING", upiRef, createdAt }`
  - Errors: `422 INSUFFICIENT_FUNDS`, `422 LIMIT_EXCEEDED`, `409 KEY_REUSED`
- `GET /payments/:id`
  - Returns current payment status (may have changed from PENDING → SUCCESS)
- `GET /payments?cursor=&limit=&filter=&q=`
  - Cursor pagination (`{ items, nextCursor }`)
  - Filter by: `sent`, `received`, `failed`
  - Search by counterparty name or VPA (case-insensitive substring)

### Step 1.8 — Collect request endpoints (20 min)
- `POST /collect-requests`
  - Body: `{ payeeVpa, amountPaise, note }`
  - Creates with `expiresAt = now + 48h`
  - Returns `{ id, from, to, amountPaise, status: "PENDING", expiresAt }`
- `POST /collect-requests/:id/pay`
  - Checks not expired (→ `410 EXPIRED`)
  - Creates a payment (same flow as POST /payments)
  - Updates request `status: PAID`
- `POST /collect-requests/:id/decline`
  - Updates `status: DECLINED`
- `GET /collect-requests?type=incoming|outgoing`
  - Returns user's collect requests

### Step 1.9 — Error shapes & server start (10 min)
- Ensure every error follows: `{ error: { code, message, details, traceId } }`
- `traceId`: UUID per request, attached to every response via response header too
- Server listens on port 3000
- Add `npm start` script
- Test with Postman/curl: login → get balance → verify VPA → pay → check status

### ✅ PR: `feat/phase-1-backend` → `main`

---

## Phase 2 — Core + Data Layer (2.5 hours)

**Branch**: `feat/phase-2-core-data`

### Step 2.1 — BankError sealed class (15 min)
- `core/errors/bank_error.dart`
- Sealed class with variants:
  ```dart
  sealed class BankError {
    String get userMessage; // plain-language, never a stack trace
    String? get traceId;    // from server response
  }
  // Variants: Unauthorized, NotFound, ValidationError(details),
  //   Conflict, ServerError, NetworkError, Timeout
  ```

### Step 2.2 — API client with Dio + interceptors (20 min)
- `core/network/api_config.dart`: `baseUrl` from `String.fromEnvironment('API_URL', defaultValue: 'http://localhost:3000')`
- `core/network/api_client.dart`:
  - Dio singleton with `baseUrl`, JSON content-type
  - **Auth interceptor**: adds `Authorization: Bearer <token>` + `X-Device-Id` header from secure storage
  - **401 interceptor**: on 401 response → clear session → redirect to login (via Riverpod session state)
  - **Logging interceptor**: logs method + URL + status code; **never** logs token, PIN, or account numbers
- `core/network/error_mapper.dart`:
  - `DioException` → `BankError` mapping
  - Extracts `traceId` from response body `error.traceId`
  - Connection timeout → `BankError.timeout`
  - No connection → `BankError.networkError`
  - HTTP 401 → `BankError.unauthorized`
  - HTTP 404 → `BankError.notFound`
  - HTTP 409 → `BankError.conflict`
  - HTTP 422 → `BankError.validationError(details)`
  - HTTP 5xx → `BankError.serverError`

### Step 2.3 — Secure session store (10 min)
- `core/security/secure_session_store.dart`
  - Uses `FlutterSecureStorage` (Keychain on iOS, Keystore on Android)
  - `saveSession(token, deviceId)`, `getSession()`, `clearSession()`
  - Never logs token values

### Step 2.4 — Biometric service (10 min)
- `core/security/biometric_service.dart`
  - Wraps `local_auth`
  - `authenticate(reason)` → `bool`
  - `isAvailable()` → `bool`
  - Falls back to device PIN if biometrics unavailable

### Step 2.5 — App lock (15 min)
- `core/security/app_lock.dart`
  - `WidgetsBindingObserver` listening to `AppLifecycleState`
  - On `paused` → set lock flag
  - On `resumed` → if locked, show biometric overlay
  - "Log out instead" button option on the lock overlay

### Step 2.6 — Utility classes (10 min)
- `core/utils/money.dart`: `formatPaise(int paise)` → `₹1,00,000` (Indian grouping with `intl`)
- `core/utils/date_format.dart`: ISO-8601 UTC → local `DateTime` → formatted display strings
- `core/utils/validators.dart`:
  - `validateVpa(String)` — format check (must contain @)
  - `validateAmount(int paise)` — > 0 and ≤ 10000000 (₹1,00,000)
  - `validatePin(String)` — 4–6 digits
  - `validateCustomerId(String)` — non-empty, alphanumeric

### Step 2.7 — Shared widgets (15 min)
- `core/widgets/async_value_view.dart`: Generic widget that takes `AsyncValue<T>` and renders loading (skeleton), error (with retry callback), or data
- `core/widgets/skeleton.dart`: Shimmer placeholder cards (for home, history, requests)
- `core/widgets/pin_pad.dart`: Custom UPI PIN entry (4–6 digits, large touch targets, scales at 200% font)

### Step 2.8 — Domain models with freezed (20 min)
- `features/auth/domain/session.dart`: `Session(token, deviceId, userName)`
- `features/home/domain/account.dart`: `Account(id, maskedNumber, balancePaise, primaryVpa)`
- `features/pay/domain/vpa.dart`: `Vpa(address, verifiedName, bankName)`
- `features/pay/domain/payment.dart`: `Payment(id, direction, counterparty, amountPaise, note, status, upiRef, createdAt)` with `PaymentStatus` enum (`success, pending, failed`)
- `features/collect/domain/collect_request.dart`: `CollectRequest(id, from, to, amountPaise, status, expiresAt)` with `CollectStatus` enum
- `features/scan/data/qr_payload.dart`: `QrPayload(vpa, name, amount)` — nullable amount
- Run `dart run build_runner build --delete-conflicting-outputs`

### Step 2.9 — Repositories (25 min)
Each repository: takes `Dio` via constructor, converts JSON → domain model, catches `DioException` → throws `BankError` via error mapper.

- **`features/auth/data/auth_repository.dart`**
  - `login(customerId, pin, deviceId)` → `Session`
  - `logout()` → clears secure storage
- **`features/pay/data/payment_repository.dart`**
  - `pay(payeeVpa, amountPaise, note, pinHash, idempotencyKey)` → `Payment`
  - `getPaymentStatus(id)` → `Payment`
  - `getHistory({cursor, limit, filter, query})` → `({List<Payment> items, String? nextCursor})`
- **`features/pay/data/vpa_repository.dart`**
  - `verifyVpa(address)` → `Vpa`
- **`features/collect/data/collect_repository.dart`**
  - `createRequest(payeeVpa, amountPaise, note)` → `CollectRequest`
  - `payRequest(id, pinHash, idempotencyKey)` → `Payment`
  - `declineRequest(id)` → `void`
  - `getRequests({type})` → `List<CollectRequest>`
- **`features/scan/data/qr_parser.dart`**
  - `parse(String rawQr)` → `QrPayload?`
  - Handles `upi://pay?pa=<vpa>&pn=<name>&am=<amount>` format
  - Normalizes: trim whitespace, lowercase VPA
  - Returns `null` for malformed QR

### ✅ PR: `feat/phase-2-core-data` → `main`

---

## Phase 3 — Screens & State (5 hours)

**Branch**: `feat/phase-3-screens`

### Step 3A — Auth Flow (45 min)

#### Step 3A.1 — Session provider (15 min)
- `features/auth/state/session_provider.dart`
- `AsyncNotifier<Session?>`:
  - `build()`: tries to restore from secure storage → biometric check → return session or null
  - `login(customerId, pin)`: calls `authRepository.login()` → saves to secure storage → returns session
  - `logout()`: calls `authRepository.logout()` → state = null → router redirects to `/login`

#### Step 3A.2 — Login screen (20 min)
- `features/auth/presentation/login_screen.dart`
- Form with:
  - Customer ID field (validated: non-empty, alphanumeric)
  - PIN field (obscured, 4–6 digits)
  - Login button (disabled while loading)
- On submit → `ref.read(sessionProvider.notifier).login(...)`
- Error display: "Invalid credentials", "Account locked" (plain language from `BankError.userMessage`)
- Loading state: button shows spinner

#### Step 3A.3 — App lock integration (10 min)
- Wire `app_lock.dart` into `app.dart` via `WidgetsBindingObserver`
- Show lock overlay on resume with biometric prompt
- "Log out instead" button calls `sessionProvider.notifier.logout()`

---

### Step 3B — Home Screen (45 min)

#### Step 3B.1 — Account provider (10 min)
- `features/home/state/account_provider.dart`
- `AsyncNotifier<Account>`: fetches `GET /accounts/primary`
- Auto-refreshes when invalidated

#### Step 3B.2 — Home screen (35 min)
- `features/home/presentation/home_screen.dart`
- **Balance card**:
  - Masked by default (`₹ ••••••`)
  - Tap eye icon → reveals balance (`formatPaise()`)
  - `Tooltip` on eye icon: "Show balance" / "Hide balance"
- **Quick actions row**: Scan, Pay, Request (3 `IconButton`s with `Tooltip`)
  - Scan → `/scan`
  - Pay → `/pay`
  - Request → `/requests`
- **Recent payments**: Last 5 from `historyProvider` (simple list)
- **Pull to refresh**: `RefreshIndicator` → `ref.invalidate(accountProvider)` + `ref.invalidate(historyProvider)`
- **Three states**: Loading → skeleton card + skeleton list; Error → retry button; Data → content
- **Drawer/profile**: Logout button

---

### Step 3C — Scan & Pay Flow (2 hours) — CRITICAL PATH

#### Step 3C.1 — QR scanner screen (20 min)
- `features/scan/presentation/scan_screen.dart`
- Uses `MobileScanner` widget
- **Permission handling**:
  - If denied: show explanation "Camera is needed to scan payment QR codes" + "Open Settings" button (`openAppSettings()`)
  - If granted: show camera feed
- On barcode detected → `qrParser.parse(rawValue)`
  - Invalid → `SnackBar("This is not a valid payment QR")`, stay on scan screen
  - Valid → navigate to `/pay?vpa=<vpa>&name=<name>&amount=<amount>`

#### Step 3C.2 — VPA lookup provider (10 min)
- `features/pay/state/vpa_lookup_provider.dart`
- `AsyncNotifierFamily<Vpa, String>`: given VPA address, calls `vpaRepository.verifyVpa()`
- 404 → "No account found for this UPI ID"

#### Step 3C.3 — Pay screen (25 min)
- `features/pay/presentation/pay_screen.dart`
- **VPA input**:
  - If came from QR: pre-filled, may be read-only
  - If manual entry: text field + "Verify" button
  - Shows verified name below VPA after lookup succeeds
  - Shows error if VPA not found
- **Amount input**:
  - **If QR had fixed amount: field is `readOnly: true`** (F3 acceptance criterion)
  - Otherwise: editable with ₹ prefix, Indian number formatting
  - Validation: > 0, ≤ ₹1,00,000 → error message: "Maximum payment limit is ₹1,00,000"
- **Note input**: optional, max 50 chars
- **Continue button**: disabled until VPA verified + amount valid
- Navigate to `/pay/review` with all data

#### Step 3C.4 — Payment flow notifier (20 min)
- `features/pay/state/payment_flow_notifier.dart`
- `Notifier<PaymentFlowState>` (not async — synchronous state machine)
- States: `idle → verifying → reviewing → enteringPin → processing → completed(Payment) → error(BankError)`
- **Idempotency key**: generated ONCE when state transitions to `reviewing` (UUID v4)
- **Double-tap prevention**: `processing` state makes confirm button disabled; `pay()` only works from `enteringPin` state
- **Timeout handling**: if pay call throws `BankError.timeout` → navigate to status screen with `PENDING` (never show "Failed" after PIN is entered)

#### Step 3C.5 — Review screen (15 min)
- `features/pay/presentation/review_screen.dart`
- Summary card: Payee VPA, verified name, amount (formatted), note
- "Confirm & Pay" button → navigates to PIN screen
- Back button → returns to pay screen (data preserved)
- Idempotency key displayed? No — internal only

#### Step 3C.6 — PIN screen (15 min)
- `features/pay/presentation/pin_screen.dart`
- Custom `PinPad` widget (from core/widgets)
- 4–6 digit entry, obscured dots
- On complete → hash PIN (SHA-256) → `paymentFlowNotifier.pay(pinHash)`
- **FLAG_SECURE**: set on this screen (Phase 4 will implement the platform channel)
- Scales properly at 200% font

#### Step 3C.7 — Payment status provider (15 min)
- `features/pay/state/payment_status_provider.dart`
- `AsyncNotifierFamily<Payment, String>` (family parameter = payment ID)
- `build(id)`:
  1. Fetch initial status
  2. If `PENDING`: start `Timer.periodic(5 seconds)` polling `getPaymentStatus(id)`
  3. If terminal (`SUCCESS` or `FAILED`): stop polling
  4. After 2 minutes of PENDING: stop polling, keep showing "Pending — we'll notify you"
- `ref.onDispose(() => timer?.cancel())` — **ensures no timer leak**

#### Step 3C.8 — Status screen (15 min)
- `features/pay/presentation/status_screen.dart`
- Animated status display:
  - ✅ SUCCESS: green check, "Payment successful", amount, UPI ref
  - ⏳ PENDING: amber clock, "Payment is being processed...", progress indicator
  - ❌ FAILED: red cross, "Payment failed", reason
- "Done" button → navigates to `/home` (clears payment flow stack)
- UPI reference number displayed (copyable if we add F10)

---

### Step 3D — Request Money (45 min)

#### Step 3D.1 — Collect provider (15 min)
- `features/collect/state/collect_provider.dart`
- `AsyncNotifier<List<CollectRequest>>`: fetches all requests
- Methods: `createRequest(vpa, amount)`, `payRequest(id, pinHash)`, `declineRequest(id)`

#### Step 3D.2 — Requests screen (30 min)
- `features/collect/presentation/requests_screen.dart`
- **Two tabs**: Incoming / Outgoing
- **Incoming tab**:
  - Each request: from VPA, amount, status badge
  - If `PENDING` and not expired: "Pay" and "Decline" buttons
  - If expired (`expiresAt < now`): buttons disabled, "Expired" badge
  - Pay → PIN screen → payment flow
  - Decline → confirm dialog → `declineRequest(id)`
- **Outgoing tab**:
  - Each request: to VPA, amount, status badge (PENDING/PAID/DECLINED/EXPIRED)
  - Declined shows "Declined" badge
- **Pull to refresh**
- **Three states**: skeleton, error+retry, empty ("No requests yet")
- **Create request**: FAB → bottom sheet with VPA + amount → `createRequest()`

---

### Step 3E — History & Search (45 min)

#### Step 3E.1 — History provider (15 min)
- `features/history/state/history_provider.dart`
- `AsyncNotifier<HistoryState>` where `HistoryState = { items: List<Payment>, nextCursor: String?, filter: PaymentFilter?, searchQuery: String? }`
- `loadMore()`: fetches next page, appends to items
- `setFilter(filter)`: resets items, fetches with filter
- `setSearch(query)`: resets items, fetches with query
- Filters + search combine: `?cursor=&filter=sent&q=priya`

#### Step 3E.2 — History screen (30 min)
- `features/history/presentation/history_screen.dart`
- **Search bar**: at top, debounced (300ms)
- **Filter chips**: All, Sent, Received, Failed — selected state
- **Infinite scroll list**: `ListView.builder` + `ScrollController`
  - On reaching bottom → `historyProvider.loadMore()`
  - Loading indicator at bottom while fetching
- **Payment tile widget**: direction icon (↑sent/↓received), counterparty name, amount, status badge, relative time
- **Three states**: skeleton list (6 shimmer tiles), error+retry, empty ("No payments found")
- **Pull to refresh**: resets pagination

### ✅ PR: `feat/phase-3-screens` → `main`

---

## Phase 4 — Integration, Polish & Edge Cases (2 hours)

**Branch**: `feat/phase-4-polish`

### Step 4.1 — Connect Flutter to backend (15 min)
- Ensure all screens work end-to-end against the running backend
- Test: Login → Home → Scan → Pay → PIN → Status → History
- Test: Login → Requests → Create → Decline
- Fix any integration issues (URL paths, JSON field names, etc.)

### Step 4.2 — Edge case hardening (20 min)
- [ ] Camera permission denied → explain why + settings button (already in 3C.1, verify it works)
- [ ] QR with trailing space/lowercase → verify `qr_parser.dart` normalizes
- [ ] Network drops after PIN → verify flow goes to Status with PENDING
- [ ] Double-tap Confirm → verify state machine blocks second tap
- [ ] Collect request expires while viewing → timer or check `expiresAt` on Pay button tap
- [ ] Server is down → all screens show "Could not reach server" + retry
- [ ] Stale balance → after error, show "Last updated" timestamp

### Step 4.3 — Three states audit (15 min)
Go through every screen and verify:
- [ ] Home: skeleton balance + skeleton list → error+retry → data
- [ ] Pay: VPA verification loading → error → verified name
- [ ] Status: loading → pending animation → success/failure
- [ ] Requests: skeleton list → error+retry → empty/data
- [ ] History: skeleton list → error+retry → empty/data

### Step 4.4 — Accessibility (15 min)
- [ ] Add `Tooltip` to every `IconButton` (eye toggle, scan, pay, refresh, etc.)
- [ ] Verify all status colors have text labels too (not color-only: SUCCESS text + green, PENDING text + amber, FAILED text + red)
- [ ] Test layout at 200% text scale — fix any overflows
- [ ] PIN pad: verify large touch targets, readable at 200%

### Step 4.5 — Animations & reduce motion (20 min)
- **Animation 1**: Payment status transition (pending spinner → success checkmark with scale animation)
- **Animation 2**: Balance reveal (fade in/out with slide)
- Both check `MediaQuery.disableAnimations` → skip animation if true
- Skeleton shimmer also respects reduce motion

### Step 4.6 — Security hardening (15 min)
- [ ] FLAG_SECURE on Pay, Review, PIN, Status screens (use `flutter_windowmanager` or method channel)
- [ ] Audit all `debugPrint` / `log` calls: no tokens, PINs, account numbers, VPAs in logs
- [ ] PIN: verify it's hashed before sending, never stored
- [ ] Token: verify only in `FlutterSecureStorage`, never in shared preferences
- [ ] Release build: will be obfuscated (Phase 5)

### Step 4.7 — Refresh & data invalidation (10 min)
- [ ] After successful payment → `ref.invalidate(accountProvider)` + `ref.invalidate(historyProvider)`
- [ ] After creating/paying/declining collect request → `ref.invalidate(collectProvider)`
- [ ] Pull-to-refresh on: Home, History, Requests

### Step 4.8 — Observability (10 min)
- [ ] Every `BankError` carries `traceId` from server
- [ ] `error_mapper.dart`: logs `"[BankError] $type traceId=$traceId"` via `debugPrint`
- [ ] No PII (personal identifiable info) in any log statement

### ✅ PR: `feat/phase-4-polish` → `main`

---

## Phase 5 — Testing, CI & Ship (1.5 hours)

**Branch**: `feat/phase-5-ship`

### Step 5.1 — Unit tests (30 min)
Priority tests that earn the most rubric points:

- [ ] `test/core/utils/validators_test.dart` — VPA validation, amount limits, PIN validation
- [ ] `test/core/utils/money_test.dart` — paise formatting, Indian grouping
- [ ] `test/features/scan/data/qr_parser_test.dart` — valid QR, invalid QR, trailing space, no amount, lowercase normalization
- [ ] `test/features/pay/state/payment_flow_notifier_test.dart` — state machine transitions, idempotency key generated once, double-tap blocked
- [ ] `test/features/pay/state/payment_status_provider_test.dart` — polling starts on PENDING, stops on SUCCESS/FAILED, stops on dispose, stops after 2 min
- [ ] `test/features/pay/data/payment_repository_test.dart` — idempotency key sent in header, error mapping
- [ ] **`test/features/pay/idempotency_test.dart`** — **"A unit test proves one key produces exactly one debit"** (F5 acceptance criterion)

### Step 5.2 — Widget tests (20 min)
- [ ] `test/features/auth/presentation/login_screen_test.dart` — validates inputs, shows error, navigates on success
- [ ] `test/features/home/presentation/home_screen_test.dart` — balance hidden by default, revealed on tap, shows skeleton during loading
- [ ] `test/features/pay/presentation/pay_screen_test.dart` — amount ≤ ₹1,00,000 validation, QR amount locks field

### Step 5.3 — Integration test (15 min)
- [ ] `integration_test/pay_flow_test.dart` — Login → (mock) Scan QR → Pay → PIN → Status shows SUCCESS
  - Uses a fake backend or mock repository

### Step 5.4 — CI pipeline (10 min)
- [ ] `.github/workflows/ci.yml`:
```yaml
name: CI
on:
  pull_request:
    branches: [main]
  push:
    branches: [main]
jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: 'stable'
      - run: flutter pub get
      - run: dart format --set-exit-if-changed .
      - run: flutter analyze
      - run: flutter test --coverage
      # Coverage gate
      - run: |
          COVERAGE=$(lcov --summary coverage/lcov.info 2>&1 | grep "lines" | grep -o '[0-9.]*%' | head -1)
          echo "Coverage: $COVERAGE"
```

### Step 5.5 — Release build (10 min)
- [ ] `flutter build apk --obfuscate --split-debug-info=symbols/ --dart-define=API_URL=http://10.0.2.2:3000`
- [ ] Keep symbols for crash reporting
- [ ] Verify APK launches and connects to backend

### Step 5.6 — README (10 min)
- [ ] Project description
- [ ] Setup instructions (Flutter + Node.js backend)
- [ ] How to run: `cd backend && npm start` then `flutter run --dart-define=API_URL=...`
- [ ] Environment variables
- [ ] Architecture diagram (reference `P01_PayLite_Architecture.png`)
- [ ] Known limitations (F8 Split and F10 Receipt not implemented)

### Step 5.7 — Demo prep (5 min)
- [ ] Plan 5-minute demo flow:
  1. Login (happy path)
  2. Home (show/hide balance)
  3. Scan QR → Pay → PIN → Status (success)
  4. Show one failure path: no network → error → retry
  5. History with search + filters
  6. Architecture walkthrough (folder structure, layers)

### ✅ PR: `feat/phase-5-ship` → `main`

---

## Solo Developer Timeline (Adjusted)

Since you're working alone, here's the recommended order:

| Time Block | Duration | Phase | Focus |
|-----------|----------|-------|-------|
| **Block 1** | 45 min | Phase 0 | Project setup, structure, router |
| **Block 2** | 2.5 hours | Phase 1 | Backend API (Node.js) |
| — Break — | 15 min | | |
| **Block 3** | 2.5 hours | Phase 2 | Core + Data layer |
| — End of Day 1 (~6 hours) — | | | |
| **Block 4** | 3 hours | Phase 3A–3C | Auth + Home + **Pay flow** (critical) |
| **Block 5** | 1.5 hours | Phase 3D–3E | Requests + History |
| — Break — | 15 min | | |
| **Block 6** | 1.5 hours | Phase 4 | Polish, edge cases, accessibility |
| **Block 7** | 1.5 hours | Phase 5 | Tests, CI, release, README |
| — End of Day 2 (~6.5 hours + breaks) — | | | |

> [!IMPORTANT]
> **If you're running out of time**, the priorities in order are:
> 1. Phase 3C (Pay flow) — this is THE core feature and "the hard part"
> 2. Phase 5.1 (Unit tests for idempotency + polling) — directly scored
> 3. Phase 4.6 (Security) — 10 rubric points
> 4. Phase 3E (History) — Must feature
> 5. Phase 3D (Requests) — Should feature, can be partial
