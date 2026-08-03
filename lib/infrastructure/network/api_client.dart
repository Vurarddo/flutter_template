import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../config/app_config.dart';

@module
abstract class ApiClientModule {
  @lazySingleton
  Dio dio(AppConfig appConfig) {
    return Dio(
      BaseOptions(
        baseUrl: appConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: <String, dynamic>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (appConfig.apiKey.isNotEmpty) 'X-API-Key': appConfig.apiKey,
        },
      ),
    );
  }
}
