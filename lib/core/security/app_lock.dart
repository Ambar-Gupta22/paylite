import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Since AppLock needs to interact with authentication and biometric state,
// we will wire it up in Phase 3 when providers are fully set up.
// For now, this is a placeholder structure that WidgetsBindingObserver will use.

class AppLockObserver extends WidgetsBindingObserver {
  bool _isLocked = false;
  DateTime? _pausedAt;

  final VoidCallback onRequireAuth;

  AppLockObserver({required this.onRequireAuth});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      _pausedAt = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      if (_pausedAt != null) {
        final backgroundDuration = DateTime.now().difference(_pausedAt!);
        // Lock if backgrounded for more than 10 seconds (or immediately based on security needs)
        if (backgroundDuration.inSeconds > 10) {
          _isLocked = true;
        }
      }

      if (_isLocked) {
        onRequireAuth();
        _isLocked =
            false; // Reset lock after prompting (auth screen handles the rest)
      }

      _pausedAt = null;
    }
  }
}
