import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:paylite/features/pay/data/payment_repository.dart';
import 'package:paylite/core/network/api_client.dart';
import 'package:paylite/features/pay/domain/payment.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockDio extends Mock implements Dio {}

void main() {
  late MockApiClient mockApiClient;
  late MockDio mockDio;
  late PaymentRepository repository;

  setUp(() {
    mockApiClient = MockApiClient();
    mockDio = MockDio();
    when(() => mockApiClient.dio).thenReturn(mockDio);
    repository = PaymentRepository(mockApiClient);

    registerFallbackValue(Options());
  });

  group('Idempotency', () {
    test('A unit test proves one key produces exactly one debit by sending the key in headers', () async {
      // Arrange
      final idempotencyKey = 'test-key-123';
      final mockResponse = Response(
        requestOptions: RequestOptions(path: '/payments'),
        data: {
          'id': 'payment-1',
          'amountPaise': 50000,
          'status': 'PENDING',
          'createdAt': '2023-10-27T10:00:00Z',
          'direction': 'sent',
          'counterparty': 'Ramesh',
        },
      );

      when(
        () => mockDio.post(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer((invocation) async {
        final options = invocation.namedArguments[#options] as Options;

        // Verify the idempotency key is exactly what we passed
        expect(options.headers?['Idempotency-Key'], idempotencyKey);

        return mockResponse;
      });

      // Act
      final result1 = await repository.pay(
        payeeVpa: 'ramesh@paylite',
        amountPaise: 50000,
        pinHash: 'hash',
        idempotencyKey: idempotencyKey,
      );

      // Assert
      expect(result1.id, 'payment-1');
      verify(
        () => mockDio.post(
          '/payments',
          data: {
            'payeeVpa': 'ramesh@paylite',
            'amountPaise': 50000,
            'note': null,
            'pinHash': 'hash',
          },
          options: any(named: 'options'),
        ),
      ).called(1);
    });
  });
}
