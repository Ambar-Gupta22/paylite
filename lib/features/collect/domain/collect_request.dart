import 'package:freezed_annotation/freezed_annotation.dart';

part 'collect_request.freezed.dart';
part 'collect_request.g.dart';

enum CollectStatus {
  @JsonValue('PENDING') pending,
  @JsonValue('PAID') paid,
  @JsonValue('DECLINED') declined,
  @JsonValue('EXPIRED') expired,
}

@freezed
class CollectRequest with _$CollectRequest {
  const factory CollectRequest({
    required String id,
    required String from,
    required String to,
    required int amountPaise,
    required CollectStatus status,
    required DateTime expiresAt,
  }) = _CollectRequest;

  factory CollectRequest.fromJson(Map<String, dynamic> json) => _$CollectRequestFromJson(json);
}
