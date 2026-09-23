import 'package:freezed_annotation/freezed_annotation.dart';

part 'qr_payload.freezed.dart';

@freezed
class QrPayload with _$QrPayload {
  const factory QrPayload({
    required String vpa,
    String? name,
    int? amountPaise,
  }) = _QrPayload;
}
