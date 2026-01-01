import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/result.dart';
import '../../../network/api_client.dart';
import '../model/auth_response.dart';
import '../model/user.dart';
import 'auth_repository.dart';

/// Auth repository implementation
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required ApiClient apiClient,
    required SharedPreferences sharedPreferences,
  }) : _apiClient = apiClient,
       _sharedPreferences = sharedPreferences;

  final ApiClient _apiClient;
  final SharedPreferences _sharedPreferences;

  @override
  Future<Result<User>> login(String email, String password) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      final authResponse = AuthResponse.fromJson(response.data!);

      // Save token
      await _sharedPreferences.setString(
        AppConstants.authTokenKey,
        authResponse.token,
      );

      return Success(authResponse.user);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return const Failure(AuthException('Invalid credentials'));
      }
      return Failure(NetworkException(e.message));
    } catch (e) {
      return Failure(UnknownException(e.toString()));
    }
  }

  @override
  Future<Result<User>> register(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.register,
        data: {
          'email': email,
          'password': password,
          'displayName': displayName,
        },
      );

      final authResponse = AuthResponse.fromJson(response.data!);

      // Save token
      await _sharedPreferences.setString(
        AppConstants.authTokenKey,
        authResponse.token,
      );

      return Success(authResponse.user);
    } on DioException catch (e) {
      return Failure(NetworkException(e.message));
    } catch (e) {
      return Failure(UnknownException(e.toString()));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _sharedPreferences.remove(AppConstants.authTokenKey);
      return const Success(null);
    } catch (e) {
      return Failure(CacheException(e.toString()));
    }
  }

  @override
  Future<Result<User?>> getCurrentUser() async {
    try {
      final token = _sharedPreferences.getString(AppConstants.authTokenKey);

      if (token == null) {
        return const Success(null);
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.profile,
      );

      final user = User.fromJson(response.data!);
      return Success(user);
    } on DioException catch (e) {
      return Failure(NetworkException(e.message));
    } catch (e) {
      return Failure(UnknownException(e.toString()));
    }
  }
}
