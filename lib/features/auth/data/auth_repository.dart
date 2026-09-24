import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/error_mapper.dart';
import '../domain/session.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  Future<Session> login(String customerId, String pin, String deviceId) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/login',
        data: {'customerId': customerId, 'pin': pin},
        options: Options(headers: {'X-Device-Id': deviceId}),
      );

      return Session(
        token: response.data['token'],
        deviceId: response.data['deviceId'],
        userName: response.data['user']['name'],
      );
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  // Logout clears server-side session if needed. For our mock, we just rely
  // on clearing the local secure storage (handled in the provider).
}
