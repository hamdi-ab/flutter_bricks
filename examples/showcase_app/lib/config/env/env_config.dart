/// App flavor/environment enum
enum Flavor { dev, staging, prod }

/// Environment configuration based on flavor
abstract class EnvConfig {
  String get apiBaseUrl;
  String get appName;
  bool get enableLogging;
  Flavor get flavor;
}

/// Development environment
class DevEnv implements EnvConfig {
  @override
  String get apiBaseUrl => 'https://dev-api.example.com';

  @override
  String get appName => 'Showcase App (Dev)';

  @override
  bool get enableLogging => true;

  @override
  Flavor get flavor => Flavor.dev;
}

/// Staging environment
class StagingEnv implements EnvConfig {
  @override
  String get apiBaseUrl => 'https://staging-api.example.com';

  @override
  String get appName => 'Showcase App (Staging)';

  @override
  bool get enableLogging => true;

  @override
  Flavor get flavor => Flavor.staging;
}

/// Production environment
class ProdEnv implements EnvConfig {
  @override
  String get apiBaseUrl => 'https://api.example.com';

  @override
  String get appName => 'Showcase App';

  @override
  bool get enableLogging => false;

  @override
  Flavor get flavor => Flavor.prod;
}

/// Get environment config based on flavor
EnvConfig getEnvConfig(Flavor flavor) {
  switch (flavor) {
    case Flavor.dev:
      return DevEnv();
    case Flavor.staging:
      return StagingEnv();
    case Flavor.prod:
      return ProdEnv();
  }
}
