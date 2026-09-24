import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/error_mapper.dart';
import '../domain/payment.dart';

class PaymentRepository {
  final ApiClient _apiClient;

  PaymentRepository(this._apiClient);

  Future<Payment> pay({
    required String payeeVpa,
    required int amountPaise,
    String? note,
    required String pinHash,
    required String idempotencyKey,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/payments',
        data: {
          'payeeVpa': payeeVpa,
          'amountPaise': amountPaise,
          'note': note,
          'pinHash': pinHash,
        },
        options: Options(headers: {'Idempotency-Key': idempotencyKey}),
      );

      return Payment.fromJson(response.data);
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  Future<Payment> getPaymentStatus(String id) async {
    try {
      final response = await _apiClient.dio.get('/payments/$id');
      return Payment.fromJson(response.data);
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  Future<({List<Payment> items, String? nextCursor})> getHistory({
    String? cursor,
    int? limit,
    String? filter,
    String? query,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (cursor != null) queryParams['cursor'] = cursor;
      if (limit != null) queryParams['limit'] = limit;
      if (filter != null) queryParams['filter'] = filter;
      if (query != null) queryParams['q'] = query;

      final response = await _apiClient.dio.get(
        '/payments',
        queryParameters: queryParams,
      );

      final List<dynamic> itemsJson = response.data['items'];
      final List<Payment> items = itemsJson
          .map((json) => Payment.fromJson(json))
          .toList();
      final String? nextCursor = response.data['nextCursor'];

      return (items: items, nextCursor: nextCursor);
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }
}
