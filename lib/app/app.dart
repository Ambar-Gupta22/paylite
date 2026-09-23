import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'theme.dart';

import '../core/security/app_lock.dart';
import '../features/auth/state/session_provider.dart';

class PayLiteApp extends ConsumerStatefulWidget {
  const PayLiteApp({super.key});

  @override
  ConsumerState<PayLiteApp> createState() => _PayLiteAppState();
}

class _PayLiteAppState extends ConsumerState<PayLiteApp> {
  late final AppLockObserver _appLockObserver;

  @override
  void initState() {
    super.initState();
    _appLockObserver = AppLockObserver(
      onRequireAuth: () {
        // When lock triggers, clear session to force re-auth
        // Alternatively, we could show an overlay overlay or navigate to a lock screen.
        // For simplicity, we trigger logout which forces router redirect to login.
        ref.read(sessionProvider.notifier).logout();
      },
    );
    WidgetsBinding.instance.addObserver(_appLockObserver);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_appLockObserver);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'PayLite',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
