enum AppEnvironment {
  dev,
  stage,
  prod;

  bool get isDev => this == dev;
  bool get isStage => this == stage;
  bool get isProd => this == prod;

  static AppEnvironment fromString(String env) {
    return AppEnvironment.values.firstWhere(
      (e) => e.name.toLowerCase() == env.toLowerCase(),
      orElse: () => AppEnvironment.dev,
    );
  }
}
