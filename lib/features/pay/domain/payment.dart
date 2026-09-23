import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment.freezed.dart';
part 'payment.g.dart';

enum PaymentStatus {
  @JsonValue('SUCCESS') success,
  @JsonValue('PENDING') pending,
  @JsonValue('FAILED') failed,
}

enum PaymentDirection {
  @JsonValue('sent') sent,
  @JsonValue('received') received,
}

@freezed
class Payment with _$Payment {
  const factory Payment({
    required String id,
    PaymentDirection? direction, // Nullable for direct fetches where direction is implicit
    String? counterparty,        // Nullable for the same reason
    required int amountPaise,
    String? note,
    required PaymentStatus status,
    String? upiRef,
    required DateTime createdAt,
  }) = _Payment;

  factory Payment.fromJson(Map<String, dynamic> json) => _$PaymentFromJson(json);
}
