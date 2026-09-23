import 'package:freezed_annotation/freezed_annotation.dart';

part 'bank_error.freezed.dart';

/// A sealed class representing all possible business and technical errors
/// that can occur when communicating with the PayLite backend.
@freezed
sealed class BankError with _$BankError implements Exception {
  
  /// Re-authentication is required.
  const factory BankError.unauthorized({String? traceId}) = _Unauthorized;

  /// The requested resource (e.g., VPA) was not found.
  const factory BankError.notFound({String? traceId}) = _NotFound;

  /// The request contained invalid data (e.g., amount exceeded limit).
  const factory BankError.validationError(String details, {String? traceId}) = _ValidationError;

  /// A conflict occurred (e.g., idempotency key reused differently).
  const factory BankError.conflict({String? traceId}) = _Conflict;

  /// The server encountered an unexpected error.
  const factory BankError.serverError({String? traceId}) = _ServerError;

  /// The user has no internet connection or DNS failed.
  const factory BankError.networkError() = _NetworkError;

  /// The connection to the server timed out.
  const factory BankError.timeout() = _Timeout;

  const BankError._();

  /// A user-friendly message safe to display in the UI.
  /// Never contains stack traces or technical jargon.
  String get userMessage {
    return when(
      unauthorized: (_) => 'Your session has expired. Please log in again.',
      notFound: (_) => 'The requested information could not be found.',
      validationError: (details, _) => details,
      conflict: (_) => 'There was a conflict processing your request.',
      serverError: (_) => 'Our servers are currently unavailable. Please try again later.',
      networkError: () => 'No internet connection. Please check your network and try again.',
      timeout: () => 'The connection timed out. Please try again.',
    );
  }
}
