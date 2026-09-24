import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../security/secure_session_store.dart';
import 'api_config.dart';

class ApiClient {
  late final Dio _dio;
  final SecureSessionStore _sessionStore;

  ApiClient(this._sessionStore) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        contentType: 'application/json',
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Attach tokens and device ID
          final session = await _sessionStore.getSession();
          if (session != null) {
            options.headers['Authorization'] = 'Bearer ${session.token}';
            options.headers['X-Device-Id'] = session.deviceId;
          }

          // Log request (excluding sensitive headers)
          if (kDebugMode) {
            debugPrint('[API Request] ${options.method} ${options.uri}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            final traceId = response.headers.value('x-trace-id') ?? 'none';
            debugPrint(
              '[API Response] ${response.statusCode} ${response.requestOptions.path} (trace: $traceId)',
            );
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          if (kDebugMode) {
            final traceId = e.response?.headers.value('x-trace-id') ?? 'none';
            debugPrint(
              '[API Error] ${e.response?.statusCode} ${e.requestOptions.path} (trace: $traceId)',
            );
          }

          // Note: 401 interceptor for global logout will be handled via Riverpod
          // provider listening to a stream, or directly in the repository wrapper.
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
