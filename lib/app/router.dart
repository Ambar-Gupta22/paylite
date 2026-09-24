import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'routes.dart';

import '../features/auth/state/session_provider.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/scan/presentation/scan_screen.dart';
import '../features/pay/presentation/pay_screen.dart';
import '../features/pay/presentation/review_screen.dart';
import '../features/pay/presentation/pin_screen.dart';
import '../features/pay/presentation/status_screen.dart';
import '../features/collect/presentation/requests_screen.dart';
import '../features/pay/presentation/history_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final sessionState = ref.watch(sessionProvider);
  final isLoggedIn = sessionState.valueOrNull != null;

  return GoRouter(
    initialLocation: Routes.login,
    redirect: (context, state) {
      final isGoingToLogin = state.matchedLocation == Routes.login;

      if (!isLoggedIn && !isGoingToLogin) return Routes.login;
      if (isLoggedIn && isGoingToLogin) return Routes.home;

      return null;
    },
    routes: [
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: Routes.scan,
        builder: (context, state) => const ScanScreen(),
      ),
      GoRoute(
        path: Routes.pay,
        builder: (context, state) {
          return PayScreen(
            initialVpa: state.uri.queryParameters['vpa'],
            initialName: state.uri.queryParameters['name'],
            initialAmount: state.uri.queryParameters['amount'],
          );
        },
        routes: [
          GoRoute(
            path: 'review',
            builder: (context, state) => const ReviewScreen(),
          ),
          GoRoute(path: 'pin', builder: (context, state) => const PinScreen()),
          GoRoute(
            path: 'status/:id',
            builder: (context, state) =>
                StatusScreen(paymentId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: Routes.requests,
        builder: (context, state) => const RequestsScreen(),
      ),
      GoRoute(
        path: Routes.history,
        builder: (context, state) => const HistoryScreen(),
      ),
    ],
  );
});
