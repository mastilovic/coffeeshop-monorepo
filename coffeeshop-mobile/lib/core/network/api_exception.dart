import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_exception.freezed.dart';

@freezed
sealed class ApiException with _$ApiException implements Exception {
  const factory ApiException.networkException({
    required String message,
    required int? statusCode,
  }) = NetworkException;

  const factory ApiException.serverException({
    required String message,
    required int? statusCode,
  }) = ServerException;

  const factory ApiException.unauthorizedException({
    required String message,
  }) = UnauthorizedException;

  const factory ApiException.forbiddenException({
    required String message,
  }) = ForbiddenException;

  const factory ApiException.validationException({
    required String message,
    required Map<String, List<String>>? errors,
  }) = ValidationException;

  const factory ApiException.unknownException({
    required String message,
  }) = UnknownException;

  factory ApiException.fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException.networkException(
          message: 'Connection timed out. Please check your internet connection.',
          statusCode: e.response?.statusCode,
        );
      case DioExceptionType.connectionError:
        return const ApiException.networkException(
          message: 'No internet connection. Please check your network.',
          statusCode: null,
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;

        if (statusCode == 401) {
          return ApiException.unauthorizedException(
            message: _extractMessage(data) ?? 'Session expired. Please login again.',
          );
        } else if (statusCode == 403) {
          return ApiException.forbiddenException(
            message: _extractMessage(data) ??
                "You don't have permission to perform this action.",
          );
        } else if (statusCode == 422 || statusCode == 400) {
          return ApiException.validationException(
            message: _extractMessage(data) ?? 'Validation failed.',
            errors: _extractErrors(data),
          );
        } else if (statusCode != null && statusCode >= 500) {
          return ApiException.serverException(
            message: _extractMessage(data) ?? 'Server error. Please try again later.',
            statusCode: statusCode,
          );
        } else {
          return ApiException.unknownException(
            message: _extractMessage(data) ?? 'An unexpected error occurred.',
          );
        }
      default:
        return ApiException.unknownException(
          message: e.message ?? 'An unexpected error occurred.',
        );
    }
  }

  static String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ?? data['error'] as String?;
    }
    return null;
  }

  static Map<String, List<String>>? _extractErrors(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('errors')) {
      final errors = data['errors'];
      if (errors is Map<String, dynamic>) {
        return errors.map(
          (key, value) => MapEntry(
            key,
            value is List ? value.cast<String>() : [value.toString()],
          ),
        );
      }
    }
    return null;
  }
}
