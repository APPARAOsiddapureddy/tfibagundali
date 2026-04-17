enum AppEnvironment { development, staging, production }

class AppConfig {
  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.cdnBaseUrl,
  });

  final AppEnvironment environment;
  final String apiBaseUrl;
  final String cdnBaseUrl;

  /// `--dart-define=ENV=development|staging|production`
  /// Optional override: `--dart-define=API_URL=https://host/v1`
  static AppConfig fromEnvironment() {
    const envName = String.fromEnvironment('ENV', defaultValue: 'development');
    const apiUrlOverride = String.fromEnvironment('API_URL');

    final base = switch (envName) {
      'production' => production,
      'staging' => staging,
      _ => development,
    };

    if (apiUrlOverride.isNotEmpty) {
      return AppConfig(
        environment: base.environment,
        apiBaseUrl: apiUrlOverride,
        cdnBaseUrl: base.cdnBaseUrl,
      );
    }
    return base;
  }

  static const AppConfig development = AppConfig(
    environment: AppEnvironment.development,
    // Android emulator → host machine (default Node server PORT=3001 in .env).
    apiBaseUrl: 'http://10.0.2.2:3001/v1',
    cdnBaseUrl: 'http://10.0.2.2:9000',
  );

  static const AppConfig staging = AppConfig(
    environment: AppEnvironment.staging,
    apiBaseUrl: 'https://api-staging.tfibagundali.in/v1',
    cdnBaseUrl: 'https://cdn-staging.tfibagundali.in',
  );

  static const AppConfig production = AppConfig(
    environment: AppEnvironment.production,
    apiBaseUrl: 'https://api.tfibagundali.in/v1',
    cdnBaseUrl: 'https://cdn.tfibagundali.in',
  );
}
