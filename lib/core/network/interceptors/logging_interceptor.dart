import 'package:dio/dio.dart';
import 'dart:developer' as developer;

/// Logging interceptor for debugging HTTP requests/responses
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    developer.log(
      'REQUEST[${options.method}] => PATH: ${options.path}',
      name: 'HTTP',
    );
    developer.log(
      'Headers: ${options.headers}',
      name: 'HTTP',
    );
    if (options.queryParameters.isNotEmpty) {
      developer.log(
        'QueryParameters: ${options.queryParameters}',
        name: 'HTTP',
      );
    }
    if (options.data != null) {
      developer.log(
        'Body: ${options.data}',
        name: 'HTTP',
      );
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    developer.log(
      'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
      name: 'HTTP',
    );
    developer.log(
      'Data: ${response.data}',
      name: 'HTTP',
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    developer.log(
      'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
      name: 'HTTP',
      error: err.message,
    );
    super.onError(err, handler);
  }
}
