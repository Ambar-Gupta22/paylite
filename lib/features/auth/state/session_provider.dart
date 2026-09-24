import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../../../core/providers.dart';
import '../domain/session.dart';

final sessionProvider = AsyncNotifierProvider<SessionNotifier, Session?>(() {
  return SessionNotifier();
});

class SessionNotifier extends AsyncNotifier<Session?> {
  @override
  Future<Session?> build() async {
    final store = ref.read(secureSessionStoreProvider);

    // Simply try to restore the session from secure storage.
    // We use ref.read (not ref.watch) so that this provider does NOT
    // get rebuilt whenever unrelated providers touch the dependency graph.
    final session = await store.getSession();

    if (session != null && !kIsWeb) {
      // On native platforms, optionally prompt biometrics.
      // On web (Chrome testing), skip biometrics entirely.
      final biometric = ref.read(biometricServiceProvider);
      if (await biometric.isAvailable()) {
        final authenticated = await biometric.authenticate(
          'Verify your identity to open PayLite',
        );
        if (!authenticated) {
          // User cancelled — clear session and force re-login
          await store.clearSession();
          return null;
        }
      }
    }

    return session;
  }

  Future<void> login(String customerId, String pin) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final store = ref.read(secureSessionStoreProvider);

      // Get a simple device ID
      String deviceId = 'web-browser';
      if (!kIsWeb) {
        try {
          final deviceInfo = DeviceInfoPlugin();
          final info = await deviceInfo.deviceInfo;
          deviceId =
              info.data['id']?.toString() ??
              info.data['identifierForVendor']?.toString() ??
              'device-${DateTime.now().millisecondsSinceEpoch}';
        } catch (_) {
          deviceId = 'device-${DateTime.now().millisecondsSinceEpoch}';
        }
      }

      final session = await repo.login(customerId, pin, deviceId);
      await store.saveSession(session);
      return session;
    });
  }

  Future<void> logout() async {
    final store = ref.read(secureSessionStoreProvider);
    await store.clearSession();
    state = const AsyncValue.data(null);
  }
}
