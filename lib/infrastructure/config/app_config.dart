import 'package:flutter_template/infrastructure/config/app_environment.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AppConfig {
  final AppEnvironment environment;
  final String baseUrl;
  final String imageBaseUrl;
  final String apiKey;

  const AppConfig._({
    required this.environment,
    required this.baseUrl,
    required this.imageBaseUrl,
    required this.apiKey,
  });

  @factoryMethod
  factory AppConfig.create() {
    const envString = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
    const baseUrl = String.fromEnvironment(
      'BASE_URL',
      defaultValue: 'https://api.themoviedb.org/3',
    );
    const imageBaseUrl = String.fromEnvironment(
      'IMAGE_BASE_URL',
      defaultValue: 'https://image.tmdb.org/t/p/w500',
    );
    const apiKey = String.fromEnvironment('API_KEY', defaultValue: '');

    return AppConfig._(
      environment: AppEnvironment.fromString(envString),
      baseUrl: baseUrl,
      imageBaseUrl: imageBaseUrl,
      apiKey: apiKey,
    );
  }

  bool get isDev => environment.isDev;
  bool get isStage => environment.isStage;
  bool get isProd => environment.isProd;
}
