import 'package:dio/dio.dart';
import 'package:flutter_template/infrastructure/config/app_config.dart';
import 'package:injectable/injectable.dart';

@module
abstract class ApiClientModule {
  @lazySingleton
  Dio dio(AppConfig appConfig) {
    final dio = Dio(
      BaseOptions(
        baseUrl: appConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        headers: <String, dynamic>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (appConfig.apiKey.isNotEmpty)
            'Authorization': 'Bearer ${appConfig.apiKey}',
        },
      ),
    );

    dio.transformer = BackgroundTransformer();

    return dio;
  }
}
