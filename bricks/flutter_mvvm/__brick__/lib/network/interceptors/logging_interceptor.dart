import 'package:dio/dio.dart';
import '../../core/utils/logger.dart';

/// Logging interceptor for debugging API requests
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    logger.debug('REQUEST[${options.method}] => PATH: ${options.path}');
    logger.debug('Headers: ${options.headers}');
    logger.debug('Data: ${options.data}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logger.debug(
      'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
    );
    logger.debug('Data: ${response.data}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    logger.error(
      'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
      error: err.message,
    );
    super.onError(err, handler);
  }
}
