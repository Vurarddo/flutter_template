import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'package:flutter_template/infrastructure/config/app_config.dart';
import 'package:flutter_template/infrastructure/network/interceptors/auth_interceptor.dart';
import 'package:flutter_template/infrastructure/network/interceptors/logging_interceptor.dart';

@module
abstract class NetworkModule {
  @Named('refreshDio')
  @lazySingleton
  Dio refreshDio() {
    return Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: Duration(seconds: AppConfig.connectTimeoutSeconds),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
  }

  @lazySingleton
  Dio dio(
    AuthInterceptor authInterceptor,
    LoggingInterceptor loggingInterceptor,
  ) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: Duration(seconds: AppConfig.connectTimeoutSeconds),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Offload heavy JSON parsing off the UI isolate
    dio.transformer = BackgroundTransformer();

    dio.interceptors.addAll([
      authInterceptor,
      if (AppConfig.enableLogging) loggingInterceptor,
    ]);

    return dio;
  }
}
