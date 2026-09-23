import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routes.dart';

// Placeholder session provider for router guard
final sessionProvider = Provider<bool>((ref) => false); // false means not logged in

final routerProvider = Provider<GoRouter>((ref) {
  final isLoggedIn = ref.watch(sessionProvider);

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
        builder: (context, state) => const Scaffold(body: Center(child: Text('Login Screen'))),
      ),
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const Scaffold(body: Center(child: Text('Home Screen'))),
      ),
      GoRoute(
        path: Routes.scan,
        builder: (context, state) => const Scaffold(body: Center(child: Text('Scan Screen'))),
      ),
      GoRoute(
        path: Routes.pay,
        builder: (context, state) => const Scaffold(body: Center(child: Text('Pay Screen'))),
      ),
      GoRoute(
        path: Routes.requests,
        builder: (context, state) => const Scaffold(body: Center(child: Text('Requests Screen'))),
      ),
      GoRoute(
        path: Routes.history,
        builder: (context, state) => const Scaffold(body: Center(child: Text('History Screen'))),
      ),
    ],
  );
});
