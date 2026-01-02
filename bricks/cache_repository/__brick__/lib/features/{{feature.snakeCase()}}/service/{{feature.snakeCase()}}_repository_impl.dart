import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/result.dart';
import '../../../network/api_client.dart';
import '../model/{{entity.snakeCase()}}.dart';
import '{{feature.snakeCase()}}_repository.dart';

/// Implementation of [{{feature.pascalCase()}}Repository] with in-memory caching
class {{feature.pascalCase()}}RepositoryImpl implements {{feature.pascalCase()}}Repository {
  {{feature.pascalCase()}}RepositoryImpl({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  // ---------------------------------------------------------------------------
  // Caching State
  // ---------------------------------------------------------------------------
  
  /// In-memory cache for {{entity.pascalCase()}} list
  List<{{entity.pascalCase()}}>? _cache;

  /// Last time the cache was updated
  DateTime? _lastFetchTime;

  /// Cache TTL (Time-To-Live)
  /// TODO: extend this to be configurable via remote config or environment
  static const _cacheTtl = Duration(minutes: 5);

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  @override
  Future<Result<List<{{entity.pascalCase()}}>>> fetch({
    bool forceRefresh = false,
  }) async {
    // 1. Check if we can return cached data
    if (!forceRefresh && _isCacheValid) {
      return Success(_cache!);
    }

    try {
      // 2. Fetch fresh data from network
      // TODO: Replace 'path_to_resource' with actual API endpoint
      final response = await _apiClient.get<List<dynamic>>(
        'path_to_resource', 
      );

      // 3. Parse data
      // Assuming the API returns a list of JSON objects
      final entities = response.data!
          .map((json) => {{entity.pascalCase()}}.fromJson(json as Map<String, dynamic>))
          .toList();

      // 4. Update cache
      _updateCache(entities);
      
      // Extension point: Disk Cache
      // await _diskCache.write(key: '{{feature.snakeCase()}}_key', value: entities);

      return Success(entities);
    } on DioException catch (e) {
      return Failure(NetworkException(e.message));
    } catch (e) {
      return Failure(UnknownException(e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // Private Helpers
  // ---------------------------------------------------------------------------

  /// Check if the in-memory cache is valid
  bool get _isCacheValid {
    if (_cache == null || _lastFetchTime == null) return false;
    
    final difference = DateTime.now().difference(_lastFetchTime!);
    return difference < _cacheTtl;
  }

  /// Update the in-memory cache and timestamp
  void _updateCache(List<{{entity.pascalCase()}}> data) {
    _cache = data;
    _lastFetchTime = DateTime.now();
  }
}
