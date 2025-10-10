import 'package:dio/dio.dart';
// import 'package:injectable/injectable.dart'; // Not needed - registered manually
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

import '../constants/api_constants.dart';
import 'interceptors/captcha_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

/// Custom HTTP client wrapping Dio
/// Replacement for CustomHttpClient.java in legacy app
/// NOTE: HttpClient is now registered manually in injection_container.dart
/// to avoid async dependency chain with CookieJar
class HttpClient {
  late final Dio _dio;
  final CookieJar _cookieJar;

  HttpClient(this._cookieJar) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: Duration(milliseconds: ApiConstants.connectionTimeout),
        receiveTimeout: Duration(milliseconds: ApiConstants.receiveTimeout),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          'Accept-Language': 'ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7',
        },
        followRedirects: false, // Handle redirects manually for captcha detection
        validateStatus: (status) {
          // Accept all status codes to handle them in interceptors
          return status != null && status < 500;
        },
      ),
    );

    // Add interceptors in order
    _dio.interceptors.addAll([
      CookieManager(_cookieJar),
      LoggingInterceptor(),
      CaptchaInterceptor(),
      ErrorInterceptor(),
    ]);
  }

  /// GET request
  /// Corresponds to CustomHttpClient.mget() in legacy app
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Download file
  Future<Response> download(
    String urlPath,
    dynamic savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    Options? options,
  }) async {
    try {
      final response = await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        deleteOnError: deleteOnError,
        lengthHeader: lengthHeader,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Get cookies for a specific URI
  Future<List<Cookie>> getCookies(Uri uri) async {
    return await _cookieJar.loadForRequest(uri);
  }

  /// Set cookies for a specific URI
  Future<void> setCookies(Uri uri, List<Cookie> cookies) async {
    await _cookieJar.saveFromResponse(uri, cookies);
  }

  /// Clear all cookies
  Future<void> clearCookies() async {
    await _cookieJar.deleteAll();
  }

  /// Get the underlying Dio instance (for advanced usage)
  Dio get dio => _dio;
}
