enum AppEnvironment {
  dev,
  stage,
  prod;

  static AppEnvironment fromString(String value) {
    return switch (value.toLowerCase()) {
      'dev' || 'development' => AppEnvironment.dev,
      'stage' || 'staging' => AppEnvironment.stage,
      'prod' || 'production' => AppEnvironment.prod,
      _ => AppEnvironment.dev,
    };
  }
}

abstract final class AppConfig {
  static const String appEnvRaw = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
  static const String baseUrl = String.fromEnvironment('BASE_URL', defaultValue: 'https://api-dev.example.com');
  static const String appName = String.fromEnvironment('APP_NAME', defaultValue: 'App Dev');

  static final AppEnvironment environment = AppEnvironment.fromString(appEnvRaw);

  static bool get isDev => environment == AppEnvironment.dev;
  static bool get isStage => environment == AppEnvironment.stage;
  static bool get isProd => environment == AppEnvironment.prod;
}
