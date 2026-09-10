import 'package:dio/dio.dart';
import 'package:flutter_template/domain/movies/failures/movies_failure.dart';

abstract final class DioExceptionMapper {
  static MoviesFailure mapToMoviesFailure(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
      case DioExceptionType.transformTimeout:
        return const NetworkMoviesFailure();

      case DioExceptionType.badResponse:
        final statusCode = exception.response?.statusCode;
        final dynamic data = exception.response?.data;
        final serverMessage = data is Map<String, dynamic>
            ? (data['status_message'] as String? ??
                data['message'] as String? ??
                'An error occurred on the server.')
            : 'An error occurred on the server.';

        if (statusCode == 401) {
          return const UnauthorizedMoviesFailure();
        }
        if (statusCode == 404) {
          return const NotFoundMoviesFailure();
        }

        return ServerMoviesFailure(
          message: serverMessage,
          statusCode: statusCode,
        );

      case DioExceptionType.cancel:
        return const NetworkMoviesFailure('Request was cancelled.');

      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return UnknownMoviesFailure(
          message: exception.message ?? 'Unknown network error.',
          error: exception.error,
          stackTrace: exception.stackTrace,
        );
    }
  }
}
