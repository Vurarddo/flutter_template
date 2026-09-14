import 'package:dio/dio.dart';
import 'package:flutter_template/domain/core/failures/domain_failure.dart';

abstract final class DioExceptionMapper {
  static DomainFailure mapToFailure(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const DomainFailure.network(
          message: 'Connection timed out. Please check your internet access.',
        );

      case DioExceptionType.badResponse:
        final statusCode = exception.response?.statusCode;
        final message = exception.response?.data?['message'] as String? ??
            'Server responded with error status $statusCode.';

        if (statusCode == 401) return const DomainFailure.unauthorized();
        if (statusCode == 403) return const DomainFailure.forbidden();
        if (statusCode == 404) return const DomainFailure.notFound();
        return DomainFailure.server(message: message, statusCode: statusCode);

      case DioExceptionType.cancel:
        return const DomainFailure.cancelled();

      default:
        return DomainFailure.unknown(message: exception.message ?? 'Unknown network error.');
    }
  }
}
