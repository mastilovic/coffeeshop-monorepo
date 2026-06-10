import 'package:coffeeshop_mobile/core/network/api_exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiException.fromDioException', () {
    group('connection timeout', () {
      test('maps connectionTimeout to networkException', () {
        final dioException = DioException(
          type: DioExceptionType.connectionTimeout,
          requestOptions: RequestOptions(path: '/test'),
        );
        final result = ApiException.fromDioException(dioException);
        expect(result, isA<NetworkException>());
        final ex = result as NetworkException;
        expect(ex.message, contains('timed out'));
        expect(ex.statusCode, isNull);
      });
    });

    group('send timeout', () {
      test('maps sendTimeout to networkException', () {
        final dioException = DioException(
          type: DioExceptionType.sendTimeout,
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 408,
          ),
        );
        final result = ApiException.fromDioException(dioException);
        expect(result, isA<NetworkException>());
        final ex = result as NetworkException;
        expect(ex.statusCode, 408);
      });
    });

    group('connection error', () {
      test('maps connectionError to networkException', () {
        final dioException = DioException(
          type: DioExceptionType.connectionError,
          requestOptions: RequestOptions(path: '/test'),
        );
        final result = ApiException.fromDioException(dioException);
        expect(result, isA<NetworkException>());
        final ex = result as NetworkException;
        expect(ex.message, contains('No internet'));
        expect(ex.statusCode, isNull);
      });
    });

    group('unauthorized (401)', () {
      test('maps 401 response to unauthorizedException', () {
        final dioException = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 401,
            data: {'message': 'Invalid token'},
          ),
        );
        final result = ApiException.fromDioException(dioException);
        expect(result, isA<UnauthorizedException>());
        final ex = result as UnauthorizedException;
        expect(ex.message, 'Invalid token');
      });

      test('uses default message when no data in 401', () {
        final dioException = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 401,
          ),
        );
        final result = ApiException.fromDioException(dioException);
        expect(result, isA<UnauthorizedException>());
        final ex = result as UnauthorizedException;
        expect(ex.message, contains('Session expired'));
      });
    });

    group('validation (422/400)', () {
      test('maps 422 response to validationException', () {
        final dioException = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 422,
            data: {
              'message': 'Validation failed',
              'errors': {'email': ['Email is invalid']},
            },
          ),
        );
        final result = ApiException.fromDioException(dioException);
        expect(result, isA<ValidationException>());
        final ex = result as ValidationException;
        expect(ex.message, 'Validation failed');
        expect(ex.errors, {'email': ['Email is invalid']});
      });

      test('maps 400 response to validationException', () {
        final dioException = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 400,
          ),
        );
        final result = ApiException.fromDioException(dioException);
        expect(result, isA<ValidationException>());
      });
    });

    group('server error (5xx)', () {
      test('maps 500 response to serverException', () {
        final dioException = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 500,
            data: {'error': 'Internal error'},
          ),
        );
        final result = ApiException.fromDioException(dioException);
        expect(result, isA<ServerException>());
        final ex = result as ServerException;
        expect(ex.statusCode, 500);
        expect(ex.message, 'Internal error');
      });

      test('maps 503 response to serverException', () {
        final dioException = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 503,
          ),
        );
        final result = ApiException.fromDioException(dioException);
        expect(result, isA<ServerException>());
      });
    });

    group('unknown errors', () {
      test('maps non-401/422/5xx to unknownException', () {
        final dioException = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 302,
          ),
        );
        final result = ApiException.fromDioException(dioException);
        expect(result, isA<UnknownException>());
      });

      test('maps other DioException types to unknownException', () {
        final dioException = DioException(
          type: DioExceptionType.cancel,
          message: 'Request cancelled',
          requestOptions: RequestOptions(path: '/test'),
        );
        final result = ApiException.fromDioException(dioException);
        expect(result, isA<UnknownException>());
        expect((result as UnknownException).message, 'Request cancelled');
      });

      test('uses default message for null message', () {
        final dioException = DioException(
          type: DioExceptionType.cancel,
          requestOptions: RequestOptions(path: '/test'),
        );
        final result = ApiException.fromDioException(dioException);
        expect(result, isA<UnknownException>());
      });
    });
  });

  group('ApiException equality', () {
    test('networkException equality', () {
      const a = NetworkException(message: 'No internet', statusCode: null);
      const b = NetworkException(message: 'No internet', statusCode: null);
      expect(a, equals(b));
    });

    test('unauthorizedException equality', () {
      const a = UnauthorizedException(message: 'Expired');
      const b = UnauthorizedException(message: 'Expired');
      expect(a, equals(b));
    });

    test('validationException equality', () {
      const a = ValidationException(
        message: 'Error',
        errors: {'email': ['Invalid']},
      );
      const b = ValidationException(
        message: 'Error',
        errors: {'email': ['Invalid']},
      );
      expect(a, equals(b));
    });
  });
}
