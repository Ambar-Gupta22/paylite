import 'package:freezed_annotation/freezed_annotation.dart';

part 'vpa.freezed.dart';
part 'vpa.g.dart';

@freezed
class Vpa with _$Vpa {
  const factory Vpa({
    required String address,
    required String verifiedName,
    required String bankName,
  }) = _Vpa;

  factory Vpa.fromJson(Map<String, dynamic> json) => _$VpaFromJson(json);
}
