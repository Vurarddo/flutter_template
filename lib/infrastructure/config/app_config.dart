import 'package:injectable/injectable.dart';

import 'app_environment.dart';

@lazySingleton
class AppConfig {
  final AppEnvironment environment;
  final String baseUrl;
  final String apiKey;

  const AppConfig._({
    required this.environment,
    required this.baseUrl,
    required this.apiKey,
  });

  @factoryMethod
  factory AppConfig.create() {
    const envString = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
    const baseUrl = String.fromEnvironment(
      'BASE_URL',
      defaultValue: 'https://api-dev.example.com',
    );
    const apiKey = String.fromEnvironment('API_KEY', defaultValue: '');

    return AppConfig._(
      environment: AppEnvironment.fromString(envString),
      baseUrl: baseUrl,
      apiKey: apiKey,
    );
  }

  bool get isDev => environment.isDev;
  bool get isStage => environment.isStage;
  bool get isProd => environment.isProd;
}
