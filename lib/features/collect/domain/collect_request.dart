enum CollectStatus { pending, paid, declined }

class CollectRequest {
  final String id;
  final String requesterVpa;
  final int amountPaise;
  final String? note;
  final CollectStatus status;
  final DateTime createdAt;

  const CollectRequest({
    required this.id,
    required this.requesterVpa,
    required this.amountPaise,
    this.note,
    required this.status,
    required this.createdAt,
  });

  factory CollectRequest.fromJson(Map<String, dynamic> json) {
    return CollectRequest(
      id: json['id'] as String,
      requesterVpa: json['requesterVpa'] as String? ?? json['from'] as String? ?? 'unknown',
      amountPaise: json['amountPaise'] as int,
      note: json['note'] as String?,
      status: CollectStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == (json['status'] as String).toLowerCase(),
        orElse: () => CollectStatus.pending,
      ),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : DateTime.now(),
    );
  }
}
