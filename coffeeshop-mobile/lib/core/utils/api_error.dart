import '../network/api_exception.dart';

String formatApiError(Object error) {
  if (error is ApiException) {
    return error.when(
      networkException: (message, _) => message,
      serverException: (message, _) => message,
      unauthorizedException: (message) => message,
      forbiddenException: (message) => message,
      validationException: (message, _) => message,
      unknownException: (message) => message,
    );
  }
  return error.toString().replaceFirst('Exception: ', '');
}
