import 'package:dio/dio.dart';

import '../../../core/errors/bank_error.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/error_mapper.dart';
import '../domain/collect_request.dart';
import '../../pay/domain/payment.dart';

class CollectRepository {
  final ApiClient _apiClient;

  CollectRepository(this._apiClient);

  Future<List<CollectRequest>> getRequests({String type = 'incoming'}) async {
    try {
      final response = await _apiClient.dio.get(
        '/collect-requests',
        queryParameters: {'type': type},
      );

      final List<dynamic> itemsJson = response.data;
      return itemsJson.map((json) => CollectRequest.fromJson(json)).toList();
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  Future<CollectRequest> createRequest({
    required String payeeVpa,
    required int amountPaise,
    String? note,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/collect-requests',
        data: {'payeeVpa': payeeVpa, 'amountPaise': amountPaise, 'note': note},
      );

      return CollectRequest.fromJson(response.data);
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  Future<Payment> payRequest({
    required String id,
    required String pinHash,
    required String idempotencyKey,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/collect-requests/$id/pay',
        data: {'pinHash': pinHash},
        options: Options(headers: {'Idempotency-Key': idempotencyKey}),
      );

      return Payment.fromJson(response.data);
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  Future<void> declineRequest(String id) async {
    try {
      await _apiClient.dio.post('/collect-requests/$id/decline');
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }
}
