import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import 'network/api_client.dart';
import 'security/biometric_service.dart';
import 'security/secure_session_store.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/home/data/account_repository.dart';
import '../features/pay/data/payment_repository.dart';
import '../features/pay/data/vpa_repository.dart';
import '../features/collect/data/collect_repository.dart';

// --- Core Services ---

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
});

final secureSessionStoreProvider = Provider<SecureSessionStore>((ref) {
  return SecureSessionStore(ref.watch(secureStorageProvider));
});

final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService(LocalAuthentication());
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(secureSessionStoreProvider));
});

// --- Repositories ---

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(apiClientProvider));
});

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepository(ref.watch(apiClientProvider));
});

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepository(ref.watch(apiClientProvider));
});

final vpaRepositoryProvider = Provider<VpaRepository>((ref) {
  return VpaRepository(ref.watch(apiClientProvider));
});

final collectRepositoryProvider = Provider<CollectRepository>((ref) {
  return CollectRepository(ref.watch(apiClientProvider));
});
