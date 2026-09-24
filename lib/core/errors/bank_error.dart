sealed class BankError implements Exception {
  final String? traceId;
  const BankError({this.traceId});

  const factory BankError.unauthorized({String? traceId}) = UnauthorizedError;
  const factory BankError.notFound({String? traceId}) = NotFoundError;
  const factory BankError.validationError(String details, {String? traceId}) =
      ValidationError;
  const factory BankError.conflict({String? traceId}) = ConflictError;
  const factory BankError.serverError({String? traceId}) = ServerError;
  const factory BankError.networkError() = NetworkError;
  const factory BankError.timeout() = TimeoutError;

  String get userMessage {
    return switch (this) {
      UnauthorizedError() => 'Session expired. Please log in again.',
      NotFoundError() => 'The requested resource was not found.',
      ValidationError(details: final d) => d,
      ConflictError() => 'This action has already been processed.',
      ServerError() => 'Something went wrong on our end. Please try again.',
      NetworkError() => 'No internet connection. Check your network.',
      TimeoutError() => 'Request timed out. Please try again.',
    };
  }
}

class UnauthorizedError extends BankError {
  const UnauthorizedError({super.traceId});
}

class NotFoundError extends BankError {
  const NotFoundError({super.traceId});
}

class ValidationError extends BankError {
  final String details;
  const ValidationError(this.details, {super.traceId});
}

class ConflictError extends BankError {
  const ConflictError({super.traceId});
}

class ServerError extends BankError {
  const ServerError({super.traceId});
}

class NetworkError extends BankError {
  const NetworkError() : super(traceId: null);
}

class TimeoutError extends BankError {
  const TimeoutError() : super(traceId: null);
}
