import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/bank_error.dart';
import '../../../core/providers.dart';
import '../domain/payment.dart';
import '../domain/vpa.dart';

enum FlowStage {
  idle,
  verifying,
  reviewing,
  enteringPin,
  processing,
  completed,
  error,
}

class PaymentFlowState {
  final FlowStage stage;
  final String? payeeVpa;
  final Vpa? verifiedVpa;
  final int? amountPaise;
  final String? note;
  final String? idempotencyKey;
  final Payment? finalPayment;
  final BankError? error;

  const PaymentFlowState({
    this.stage = FlowStage.idle,
    this.payeeVpa,
    this.verifiedVpa,
    this.amountPaise,
    this.note,
    this.idempotencyKey,
    this.finalPayment,
    this.error,
  });

  PaymentFlowState copyWith({
    FlowStage? stage,
    String? payeeVpa,
    Vpa? verifiedVpa,
    int? amountPaise,
    String? note,
    String? idempotencyKey,
    Payment? finalPayment,
    BankError? error,
  }) {
    return PaymentFlowState(
      stage: stage ?? this.stage,
      payeeVpa: payeeVpa ?? this.payeeVpa,
      verifiedVpa: verifiedVpa ?? this.verifiedVpa,
      amountPaise: amountPaise ?? this.amountPaise,
      note: note ?? this.note,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      finalPayment: finalPayment ?? this.finalPayment,
      error: error ?? this.error,
    );
  }
}

final paymentFlowProvider = NotifierProvider<PaymentFlowNotifier, PaymentFlowState>(() {
  return PaymentFlowNotifier();
});

class PaymentFlowNotifier extends Notifier<PaymentFlowState> {
  @override
  PaymentFlowState build() => const PaymentFlowState();

  void initFlow(String vpa, int amount, String note, Vpa verifiedVpa) {
    // Generate idempotency key ONCE when we start review
    final idKey = '${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(10000)}';
    
    state = state.copyWith(
      stage: FlowStage.reviewing,
      payeeVpa: vpa,
      amountPaise: amount,
      note: note,
      verifiedVpa: verifiedVpa,
      idempotencyKey: idKey,
      error: null,
    );
  }

  void goToPin() {
    if (state.stage != FlowStage.reviewing) return;
    state = state.copyWith(stage: FlowStage.enteringPin);
  }
  
  void cancelToReview() {
    state = state.copyWith(stage: FlowStage.reviewing);
  }

  Future<void> pay(String pinHash) async {
    if (state.stage != FlowStage.enteringPin) return;

    state = state.copyWith(stage: FlowStage.processing, error: null);

    try {
      final repo = ref.read(paymentRepositoryProvider);
      final payment = await repo.pay(
        payeeVpa: state.payeeVpa!,
        amountPaise: state.amountPaise!,
        note: state.note,
        pinHash: pinHash,
        idempotencyKey: state.idempotencyKey!,
      );

      state = state.copyWith(
        stage: FlowStage.completed,
        finalPayment: payment,
      );
    } on BankError catch (e) {
      if (e == const BankError.timeout()) {
        // Create a dummy pending payment since we don't know the status
        // In a real app we might poll for this idempotency key later
        final pendingPayment = Payment(
          id: 'unknown-timeout',
          amountPaise: state.amountPaise!,
          status: PaymentStatus.pending,
          createdAt: DateTime.now(),
          direction: PaymentDirection.sent,
          counterparty: state.payeeVpa,
        );
        state = state.copyWith(
          stage: FlowStage.completed,
          finalPayment: pendingPayment,
        );
      } else {
        state = state.copyWith(
          stage: FlowStage.error,
          error: e,
        );
      }
    } catch (e) {
      state = state.copyWith(
        stage: FlowStage.error,
        error: const BankError.serverError(),
      );
    }
  }
  
  void reset() {
    state = const PaymentFlowState();
  }
}
