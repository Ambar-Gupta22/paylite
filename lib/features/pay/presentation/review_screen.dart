import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/secure_screen.dart';
import '../state/payment_flow_notifier.dart';

class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flowState = ref.watch(paymentFlowProvider);

    if (flowState.stage == FlowStage.idle) {
      // Flow was reset or accessed improperly
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.pop();
      });
      return const SizedBox.shrink();
    }

    return SecureScreen(
      child: Scaffold(
        appBar: AppBar(title: const Text('Review Payment')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    flowState.verifiedVpa?.verifiedName.substring(0, 1).toUpperCase() ?? '?',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Paying ${flowState.verifiedVpa?.verifiedName ?? ''}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  flowState.payeeVpa ?? '',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  MoneyFormatter.formatPaise(flowState.amountPaise ?? 0),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (flowState.note != null && flowState.note!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '"${flowState.note}"',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
                const Spacer(flex: 2),
                ElevatedButton(
                  onPressed: () {
                    ref.read(paymentFlowProvider.notifier).goToPin();
                    context.push('/pay/pin');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Confirm & Pay', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
