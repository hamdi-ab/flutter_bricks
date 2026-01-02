import '../../../core/errors/result.dart';
import '../model/{{entity.snakeCase()}}.dart';

/// Repository interface for {{feature.pascalCase()}}
abstract class {{feature.pascalCase()}}Repository {
  /// Fetch {{entity.pascalCase()}} list
  /// 
  /// [forceRefresh] - If true, bypasses cache and fetches fresh data
  Future<Result<List<{{entity.pascalCase()}}>>> fetch({bool forceRefresh = false});
}
