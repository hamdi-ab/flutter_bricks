import 'package:dio/dio.dart';
{{#use_disk_cache}}
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
{{/use_disk_cache}}

import '../../../core/constants/api_endpoints.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/result.dart';
import '../../../network/api_client.dart';
import '../model/{{entity.snakeCase()}}.dart';
import '{{feature.snakeCase()}}_repository.dart';

/// Implementation of [{{feature.pascalCase()}}Repository] with in-memory{{#use_disk_cache}} and disk{{/use_disk_cache}} caching
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

  {{#use_disk_cache}}
  /// Hive Box name for this feature
  static const _boxName = '{{feature.snakeCase()}}_cache';
  
  /// Cache Key
  static const _cacheKey = '{{entity.snakeCase()}}_list';
  {{/use_disk_cache}}

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  @override
  Future<Result<List<{{entity.pascalCase()}}>>> fetch({
    bool forceRefresh = false,
  }) async {
    // 1. Check if we can return cached data
    if (!forceRefresh) {
      if (_isInMemoryCacheValid) {
        return Success(_cache!);
      }
      {{#use_disk_cache}}
      // Check disk cache if memory is invalid
      final diskData = await _readFromDisk();
      if (diskData != null) {
        _cache = diskData;
        _lastFetchTime = DateTime.now(); // Reset TTL for memory warmth
        return Success(diskData);
      }
      {{/use_disk_cache}}
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
      
      {{#use_disk_cache}}
      // 5. Persist to Disk
      await _writeToDisk(entities);
      {{/use_disk_cache}}

      return Success(entities);
    } on DioException catch (e) {
      {{#use_disk_cache}}
      // Fallback: If network fails, try returning stale disk cache
      final staleData = await _readFromDisk();
      if (staleData != null) {
        // You might want to return a specific SuccessWithWarning or just Success type here
        // For now, we return Success but user could check if data is old if needed
        return Success(staleData); 
      }
      {{/use_disk_cache}}
      return Failure(NetworkException(e.message));
    } catch (e) {
      return Failure(UnknownException(e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // Private Helpers
  // ---------------------------------------------------------------------------

  /// Check if the in-memory cache is valid
  bool get _isInMemoryCacheValid {
    if (_cache == null || _lastFetchTime == null) return false;
    
    final difference = DateTime.now().difference(_lastFetchTime!);
    return difference < _cacheTtl;
  }

  /// Update the in-memory cache and timestamp
  void _updateCache(List<{{entity.pascalCase()}}> data) {
    _cache = data;
    _lastFetchTime = DateTime.now();
  }

  {{#use_disk_cache}}
  // ---------------------------------------------------------------------------
  // Disk Cache Helpers (Hive)
  // ---------------------------------------------------------------------------

  Future<List<{{entity.pascalCase()}}>?> _readFromDisk() async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        await Hive.openBox(_boxName);
      }
      final box = Hive.box(_boxName);
      
      // We store the list as a JSON string to avoid TypeAdapter complexity for generic lists
      // or simple Lists of Maps if safe. JSON encoding is safest without code-gen adapters.
      final jsonString = box.get(_cacheKey);
      
      if (jsonString == null) return null;

      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded
          .map((e) => {{entity.pascalCase()}}.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // On disk read fail, just return null (treat as cache miss)
      return null;
    }
  }

  Future<void> _writeToDisk(List<{{entity.pascalCase()}}> data) async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        await Hive.openBox(_boxName);
      }
      final box = Hive.box(_boxName);
      
      // Encode to JSON string
      final jsonString = jsonEncode(data.map((e) => e.toJson()).toList());
      
      await box.put(_cacheKey, jsonString);
    } catch (e) {
      // Silently fail on cache write error (don't block app)
      print('Cache write failed: $e');
    }
  }
  {{/use_disk_cache}}
}
