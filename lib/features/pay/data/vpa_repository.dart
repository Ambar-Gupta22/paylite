import 'package:dio/dio.dart';

import '../../../core/errors/bank_error.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/error_mapper.dart';
import '../domain/vpa.dart';

class VpaRepository {
  final ApiClient _apiClient;

  VpaRepository(this._apiClient);

  Future<Vpa> verifyVpa(String address) async {
    try {
      // Normalize before sending just in case, though backend also handles it
      final normalizedAddress = address.trim().toLowerCase();
      final response = await _apiClient.dio.get('/vpa/$normalizedAddress');

      return Vpa.fromJson(response.data);
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }
}
