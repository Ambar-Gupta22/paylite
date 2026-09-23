import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../domain/payment.dart';

final paymentStatusProvider = AsyncNotifierProviderFamily<PaymentStatusNotifier, Payment, String>(
  () => PaymentStatusNotifier(),
);

class PaymentStatusNotifier extends FamilyAsyncNotifier<Payment, String> {
  Timer? _pollingTimer;

  @override
  Future<Payment> build(String arg) async {
    final repo = ref.watch(paymentRepositoryProvider);
    final payment = await repo.getPaymentStatus(arg);

    // If it's pending, start polling
    if (payment.status == PaymentStatus.pending) {
      _startPolling(arg);
    }

    return payment;
  }

  void _startPolling(String paymentId) {
    _pollingTimer?.cancel();
    // Poll every 3 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        final repo = ref.read(paymentRepositoryProvider);
        final payment = await repo.getPaymentStatus(paymentId);
        
        state = AsyncValue.data(payment);

        if (payment.status != PaymentStatus.pending) {
          timer.cancel();
          _pollingTimer = null;
        }
      } catch (e, st) {
        // Just log or ignore network errors during polling, keep previous state
        // In a real app we might retry a few times before showing an error
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
