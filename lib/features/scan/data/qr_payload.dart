class QrPayload {
  final String vpa;
  final String? name;
  final int? amountPaise;

  const QrPayload({required this.vpa, this.name, this.amountPaise});
}
