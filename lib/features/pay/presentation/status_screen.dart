import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/secure_screen.dart';
import '../domain/payment.dart';
import '../state/payment_status_provider.dart';
import '../state/payment_flow_notifier.dart';
import '../state/history_provider.dart';
import '../../home/state/account_provider.dart';

class StatusScreen extends ConsumerWidget {
  final String paymentId;

  const StatusScreen({super.key, required this.paymentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusState = ref.watch(paymentStatusProvider(paymentId));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _cleanUpAndGoHome(context, ref);
        }
      },
      child: SecureScreen(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Payment Status'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Close',
              onPressed: () => _cleanUpAndGoHome(context, ref),
            ),
          ),
          body: SafeArea(
            child: AsyncValueView(
              value: statusState,
              onRetry: () => ref.invalidate(paymentStatusProvider(paymentId)),
              loading: () => const Center(child: CircularProgressIndicator()),
              data: (payment) => _buildStatusContent(context, ref, payment),
            ),
          ),
        ),
      ),
    );
  }

  void _cleanUpAndGoHome(BuildContext context, WidgetRef ref) {
    ref.read(paymentFlowProvider.notifier).reset();
    ref.invalidate(historyProvider);
    ref.invalidate(accountProvider);
    context.go('/home');
  }

  Widget _buildStatusContent(BuildContext context, WidgetRef ref, Payment payment) {
    IconData icon;
    Color color;
    String statusText;

    switch (payment.status) {
      case PaymentStatus.success:
        icon = Icons.check_circle;
        color = Colors.green;
        statusText = 'Payment Successful';
        break;
      case PaymentStatus.failed:
        icon = Icons.cancel;
        color = Colors.red;
        statusText = 'Payment Failed';
        break;
      case PaymentStatus.pending:
        icon = Icons.hourglass_empty;
        color = Colors.orange;
        statusText = 'Payment Processing...';
        break;
    }

    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          AnimatedSwitcher(
            duration: disableAnimations ? Duration.zero : const Duration(milliseconds: 500),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: Icon(
              icon,
              key: ValueKey<PaymentStatus>(payment.status),
              size: 100,
              color: color,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            statusText,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            MoneyFormatter.formatPaise(payment.amountPaise),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildDetailRow('To', payment.counterparty ?? 'Unknown'),
                const Divider(),
                _buildDetailRow('Date', AppDateFormat.format(payment.createdAt)),
                const Divider(),
                _buildDetailRow('Ref ID', payment.id.split('-').first.toUpperCase()),
              ],
            ),
          ),
          const Spacer(flex: 2),
          if (payment.status != PaymentStatus.pending)
            ElevatedButton(
              onPressed: () => _cleanUpAndGoHome(context, ref),
              child: const Text('Done'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
