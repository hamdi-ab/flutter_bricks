/// Environment configuration
abstract class EnvConfig {
  String get apiBaseUrl;
  String get appName;
  bool get enableLogging;
}

/// Development environment
class DevEnv implements EnvConfig {
  @override
  String get apiBaseUrl => 'https://dev-api.example.com';

  @override
  String get appName => '{{project_name.titleCase()}} (Dev)';

  @override
  bool get enableLogging => true;
}

/// Production environment
class ProdEnv implements EnvConfig {
  @override
  String get apiBaseUrl => 'https://api.example.com';

  @override
  String get appName => '{{project_name.titleCase()}}';

  @override
  bool get enableLogging => false;
}
