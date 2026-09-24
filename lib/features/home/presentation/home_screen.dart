import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/payment_tile.dart';
import '../../auth/state/session_provider.dart';
import '../../pay/state/history_provider.dart';
import '../state/account_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _balanceVisible = false;

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionProvider);
    final accountState = ref.watch(accountProvider);
    final userName = sessionState.valueOrNull?.userName ?? 'User';

    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, $userName'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log Out',
            onPressed: () {
              ref.read(sessionProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(accountProvider);
          ref.invalidate(historyProvider);
          // Wait for the new future to complete
          try {
            await ref.read(accountProvider.future);
            await ref.read(historyProvider.future);
          } catch (_) {}
        },
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildBalanceCard(accountState),
            const SizedBox(height: 24),
            _buildQuickActions(context),
            const SizedBox(height: 32),
            Text(
              'Recent Payments',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildRecentPayments(ref),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentPayments(WidgetRef ref) {
    final historyState = ref.watch(historyProvider);
    return AsyncValueView(
      value: historyState,
      onRetry: () => ref.invalidate(historyProvider),
      loading: () => const Center(child: CircularProgressIndicator()),
      data: (payments) {
        if (payments.isEmpty) return const Text('No recent payments yet.');
        // Show max 3 recent payments
        final recent = payments.take(3).toList();
        return Column(
          children: recent.map((p) => PaymentTile(payment: p)).toList(),
        );
      },
    );
  }

  Widget _buildBalanceCard(AsyncValue accountState) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: AsyncValueView(
          value: accountState,
          onRetry: () => ref.invalidate(accountProvider),
          loading: () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Available Balance', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              const Skeleton(width: 150, height: 40),
              const SizedBox(height: 16),
              const Skeleton(width: 200, height: 20),
            ],
          ),
          data: (account) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Available Balance',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  IconButton(
                    icon: Icon(
                      _balanceVisible ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white,
                    ),
                    tooltip: _balanceVisible ? 'Hide balance' : 'Show balance',
                    onPressed: () => setState(() => _balanceVisible = !_balanceVisible),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _balanceVisible ? MoneyFormatter.formatPaise(account.balancePaise) : '₹ ••••••',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'A/C No: ${account.maskedNumber}',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                'UPI ID: ${account.primaryVpa}',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionItem(
          context,
          icon: Icons.qr_code_scanner,
          label: 'Scan & Pay',
          onTap: () => context.push('/scan'),
        ),
        _buildActionItem(
          context,
          icon: Icons.send,
          label: 'Pay Contact',
          onTap: () => context.push('/pay'),
        ),
        _buildActionItem(
          context,
          icon: Icons.request_page,
          label: 'Requests',
          onTap: () => context.push('/requests'),
        ),
        _buildActionItem(
          context,
          icon: Icons.history,
          label: 'History',
          onTap: () => context.push('/history'),
        ),
      ],
    );
  }

  Widget _buildActionItem(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
              ),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}
