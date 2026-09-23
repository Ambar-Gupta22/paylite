import 'dart:io';
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
    final store = ref.watch(secureSessionStoreProvider);
    final biometric = ref.watch(biometricServiceProvider);
    
    final session = await store.getSession();
    
    if (session != null) {
      // If returning user, prompt for biometrics before restoring session fully
      if (await biometric.isAvailable()) {
        final authenticated = await biometric.authenticate('Verify your identity to open PayLite');
        if (!authenticated) {
          // If they cancel biometric, we don't log them out entirely, but we don't emit a session yet
          // For simplicity in this app, we'll force logout or just throw an error.
          // In a real app, they'd fall back to PIN.
          throw Exception('Biometric authentication failed or canceled');
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
      String deviceId = 'unknown-device';
      try {
        final deviceInfo = DeviceInfoPlugin();
        if (Platform.isAndroid) {
          final androidInfo = await deviceInfo.androidInfo;
          deviceId = androidInfo.id;
        } else if (Platform.isIOS) {
          final iosInfo = await deviceInfo.iosInfo;
          deviceId = iosInfo.identifierForVendor ?? 'unknown-ios-device';
        } else if (Platform.isWindows) {
          deviceId = 'windows-dev-machine'; // For web/desktop testing
        }
      } catch (_) {
        // Fallback
        deviceId = 'device-${DateTime.now().millisecondsSinceEpoch}';
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
