import '../../../core/errors/result.dart';
import '../model/user.dart';

/// Auth repository interface
abstract class AuthRepository {
  Future<Result<User>> login(String email, String password);
  Future<Result<User>> register(
    String email,
    String password,
    String displayName,
  );
  Future<Result<void>> logout();
  Future<Result<User?>> getCurrentUser();
}
