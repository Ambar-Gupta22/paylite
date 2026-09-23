import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../errors/bank_error.dart';

class ErrorMapper {
  static BankError map(dynamic error) {
    if (error is DioException) {
      final traceId = error.response?.headers.value('x-trace-id');
      
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const BankError.timeout();
        case DioExceptionType.connectionError:
          return const BankError.networkError();
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final responseData = error.response?.data;
          
          String message = 'Unknown error';
          if (responseData is Map<String, dynamic> && responseData['error'] != null) {
            message = responseData['error']['message']?.toString() ?? message;
          }

          if (statusCode == 401) {
            return BankError.unauthorized(traceId: traceId);
          } else if (statusCode == 404) {
            return BankError.notFound(traceId: traceId);
          } else if (statusCode == 409) {
            return BankError.conflict(traceId: traceId);
          } else if (statusCode == 422) {
            return BankError.validationError(message, traceId: traceId);
          } else if (statusCode != null && statusCode >= 500) {
            return BankError.serverError(traceId: traceId);
          } else {
            return BankError.validationError(message, traceId: traceId);
          }
        default:
          return const BankError.networkError();
      }
    }
    
    // Log unexpected exceptions in debug mode
    if (kDebugMode) {
      debugPrint('[ErrorMapper] Unexpected error: $error');
    }
    
    return const BankError.serverError();
  }
}
