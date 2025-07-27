/// Result wrapper for service operations that can succeed or fail
class ServiceResult<T> {
  final T? data;
  final ServiceError? error;
  final bool isSuccess;

  const ServiceResult.success(this.data) : error = null, isSuccess = true;

  const ServiceResult.failure(this.error) : data = null, isSuccess = false;

  /// Create a success result with data
  factory ServiceResult.ok(T data) => ServiceResult.success(data);

  /// Create a failure result with error
  factory ServiceResult.fail(String message, {String? code, Object? cause}) {
    return ServiceResult.failure(
      ServiceError(message: message, code: code, cause: cause),
    );
  }

  /// Transform the data if the result is successful
  ServiceResult<U> map<U>(U Function(T data) transform) {
    if (isSuccess && data != null) {
      try {
        return ServiceResult.success(transform(data as T));
      } catch (e) {
        return ServiceResult.failure(
          ServiceError(
            message: 'Transformation failed: $e',
            code: 'TRANSFORM_ERROR',
            cause: e,
          ),
        );
      }
    }
    return ServiceResult.failure(error);
  }

  /// Transform the error if the result is a failure
  ServiceResult<T> mapError(
    ServiceError Function(ServiceError error) transform,
  ) {
    if (!isSuccess && error != null) {
      return ServiceResult.failure(transform(error!));
    }
    return this;
  }

  /// Execute a function if the result is successful
  ServiceResult<T> onSuccess(void Function(T data) action) {
    if (isSuccess && data != null) {
      action(data as T);
    }
    return this;
  }

  /// Execute a function if the result is a failure
  ServiceResult<T> onFailure(void Function(ServiceError error) action) {
    if (!isSuccess && error != null) {
      action(error!);
    }
    return this;
  }

  /// Get the data or throw an exception if the result is a failure
  T get dataOrThrow {
    if (isSuccess && data != null) {
      return data as T;
    }
    throw ServiceException(error?.message ?? 'Unknown error', error?.code);
  }

  /// Get the data or return a default value if the result is a failure
  T dataOr(T defaultValue) {
    return isSuccess && data != null ? data as T : defaultValue;
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'ServiceResult.success($data)';
    } else {
      return 'ServiceResult.failure($error)';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServiceResult<T> &&
        other.data == data &&
        other.error == error &&
        other.isSuccess == isSuccess;
  }

  @override
  int get hashCode => data.hashCode ^ error.hashCode ^ isSuccess.hashCode;
}

/// Error information for service operations
class ServiceError {
  final String message;
  final String? code;
  final Object? cause;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  ServiceError({
    required this.message,
    this.code,
    this.cause,
    DateTime? timestamp,
    this.metadata,
  }) : timestamp = timestamp ?? DateTime.now();

  ServiceError copyWith({
    String? message,
    String? code,
    Object? cause,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return ServiceError(
      message: message ?? this.message,
      code: code ?? this.code,
      cause: cause ?? this.cause,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    final codeStr = code != null ? ' ($code)' : '';
    return 'ServiceError$codeStr: $message';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServiceError &&
        other.message == message &&
        other.code == code &&
        other.cause == cause &&
        other.timestamp == timestamp &&
        other.metadata == metadata;
  }

  @override
  int get hashCode {
    return message.hashCode ^
        code.hashCode ^
        cause.hashCode ^
        timestamp.hashCode ^
        metadata.hashCode;
  }
}

/// Exception thrown when accessing data from a failed ServiceResult
class ServiceException implements Exception {
  final String message;
  final String? code;

  const ServiceException(this.message, [this.code]);

  @override
  String toString() {
    final codeStr = code != null ? ' ($code)' : '';
    return 'ServiceException$codeStr: $message';
  }
}

/// Extension methods for Future&lt;ServiceResult&lt;T&gt;&gt;
extension ServiceResultFuture<T> on Future<ServiceResult<T>> {
  /// Transform the data if the future result is successful
  Future<ServiceResult<U>> mapAsync<U>(
    Future<U> Function(T data) transform,
  ) async {
    final result = await this;
    if (result.isSuccess && result.data != null) {
      try {
        final transformedData = await transform(result.data as T);
        return ServiceResult.success(transformedData);
      } catch (e) {
        return ServiceResult.failure(
          ServiceError(
            message: 'Async transformation failed: $e',
            code: 'ASYNC_TRANSFORM_ERROR',
            cause: e,
          ),
        );
      }
    }
    return ServiceResult.failure(result.error);
  }

  /// Chain another async operation if the result is successful
  Future<ServiceResult<U>> flatMapAsync<U>(
    Future<ServiceResult<U>> Function(T data) operation,
  ) async {
    final result = await this;
    if (result.isSuccess && result.data != null) {
      return await operation(result.data as T);
    }
    return ServiceResult.failure(result.error);
  }
}
