/// Application constants
class AppConstants {
  const AppConstants._();

  // API
  static const apiTimeout = Duration(seconds: 30);
  static const connectTimeout = Duration(seconds: 30);
  static const receiveTimeout = Duration(seconds: 30);

  // Pagination
  static const defaultPageSize = 20;

  // Animation durations
  static const shortAnimationDuration = Duration(milliseconds: 200);
  static const mediumAnimationDuration = Duration(milliseconds: 300);
  static const longAnimationDuration = Duration(milliseconds: 500);

  // Storage keys
  static const authTokenKey = 'auth_token';
  static const userKey = 'user';
  static const themeKey = 'theme_mode';
}
