enum PaymentStatus { pending, success, failed }

enum PaymentDirection { sent, received }

class Payment {
  final String id;
  final int amountPaise;
  final PaymentStatus status;
  final DateTime createdAt;
  final PaymentDirection direction;
  final String? counterparty;
  final String? note;

  const Payment({
    required this.id,
    required this.amountPaise,
    required this.status,
    required this.createdAt,
    required this.direction,
    this.counterparty,
    this.note,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      amountPaise: json['amountPaise'] as int,
      status: PaymentStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == (json['status'] as String).toLowerCase(),
        orElse: () => PaymentStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      direction: PaymentDirection.values.firstWhere(
        (e) => e.name.toLowerCase() == (json['direction'] as String).toLowerCase(),
        orElse: () => PaymentDirection.sent,
      ),
      counterparty: json['counterparty'] as String?,
      note: json['note'] as String?,
    );
  }
}
