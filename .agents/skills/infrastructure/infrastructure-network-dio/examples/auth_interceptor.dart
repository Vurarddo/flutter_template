import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'package:flutter_template/infrastructure/storage/secure_store_interactor.dart';

@lazySingleton
class AuthInterceptor extends QueuedInterceptor {
  final SecureStoreInteractor _secureStore;
  final Dio _refreshDio;

  AuthInterceptor(
    this._secureStore,
    @Named('refreshDio') this._refreshDio,
  );

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStore.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      try {
        final refreshToken = await _secureStore.getRefreshToken();
        if (refreshToken == null) {
          await _secureStore.clearTokens();
          return handler.next(err);
        }

        final response = await _refreshDio.post(
          '/auth/refresh',
          data: {'refresh_token': refreshToken},
        );

        final newAccessToken = response.data['access_token'] as String;
        final newRefreshToken = response.data['refresh_token'] as String?;

        await _secureStore.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken ?? refreshToken,
        );

        // Retry original request with new token
        final retryOptions = err.requestOptions;
        retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';

        final retryResponse = await _refreshDio.fetch(retryOptions);
        return handler.resolve(retryResponse);
      } catch (_) {
        await _secureStore.clearTokens();
      }
    }
    handler.next(err);
  }
}
