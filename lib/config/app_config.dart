class AppConfig {
  static const String dashScopeApiKey = 'sk-c7aab8eefa5b47d387cf166372a939ea';

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://172.26.74.55:8080/api',
  );

  static String getBaseUrl() {
    return apiBaseUrl;
  }
}
