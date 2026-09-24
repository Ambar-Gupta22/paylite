import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:paylite/features/pay/state/payment_flow_notifier.dart';
import 'package:paylite/features/pay/data/payment_repository.dart';
import 'package:paylite/core/providers.dart';
import 'package:paylite/features/pay/domain/payment.dart';

class MockPaymentRepository extends Mock implements PaymentRepository {}

void main() {
  late MockPaymentRepository mockRepo;
  late ProviderContainer container;

  setUp(() {
    mockRepo = MockPaymentRepository();
    container = ProviderContainer(
      overrides: [paymentRepositoryProvider.overrideWithValue(mockRepo)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('PaymentFlowNotifier', () {
    test('initial state is idle', () {
      final state = container.read(paymentFlowProvider);
      expect(state.stage, FlowStage.idle);
    });

    test('initFlow transitions to reviewing and generates key', () {
      final vpa = Vpa(
        address: 'ramesh@paylite',
        verifiedName: 'Ramesh Singh',
        bankName: 'PayLite Bank',
      );
      container
          .read(paymentFlowProvider.notifier)
          .initFlow('ramesh@paylite', 50000, '', vpa);

      final state = container.read(paymentFlowProvider);

      expect(state.stage, FlowStage.reviewing);
      expect(state.payeeVpa, 'ramesh@paylite');
      expect(state.amountPaise, 50000);
      expect(state.idempotencyKey, isNotNull); // Key is generated once
      expect(state.idempotencyKey!.isNotEmpty, true);
    });

    test('double-tap is blocked during processing', () async {
      when(
        () => mockRepo.pay(
          payeeVpa: any(named: 'payeeVpa'),
          amountPaise: any(named: 'amountPaise'),
          pinHash: any(named: 'pinHash'),
          idempotencyKey: any(named: 'idempotencyKey'),
          note: any(named: 'note'),
        ),
      ).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return Payment(
          id: '1',
          amountPaise: 50000,
          status: PaymentStatus.pending,
          createdAt: DateTime.now(),
          direction: PaymentDirection.sent,
        );
      });

      final notifier = container.read(paymentFlowProvider.notifier);
      final vpa = Vpa(
        address: 'ramesh@paylite',
        verifiedName: 'Ramesh Singh',
        bankName: 'PayLite Bank',
      );
      notifier.initFlow('ramesh@paylite', 50000, '', vpa);
      notifier.goToPin();

      // Fire first request (doesn't await)
      final future1 = notifier.pay('hash');

      // State should now be processing
      expect(container.read(paymentFlowProvider).stage, FlowStage.processing);

      // Fire second request
      final future2 = notifier.pay('hash2');

      await future1;
      await future2;

      // Verify repo was called ONLY ONCE
      verify(
        () => mockRepo.pay(
          payeeVpa: any(named: 'payeeVpa'),
          amountPaise: any(named: 'amountPaise'),
          pinHash: any(named: 'pinHash'),
          idempotencyKey: any(named: 'idempotencyKey'),
          note: any(named: 'note'),
        ),
      ).called(1);
    });
  });
}
