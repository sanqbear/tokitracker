import 'package:dio/dio.dart';
import 'dart:io';
import '../../error/exceptions.dart';

/// Error handling interceptor
/// Converts Dio errors to custom exceptions
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // If the error is already a CaptchaRequiredException, pass it through
    if (err.error is CaptchaRequiredException) {
      handler.next(err);
      return;
    }

    AppException exception;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        exception = TimeoutException(
          'Connection timeout. Please check your internet connection.',
        );
        break;

      case DioExceptionType.badResponse:
        exception = _handleStatusCode(err.response?.statusCode);
        break;

      case DioExceptionType.cancel:
        exception = AppException('Request cancelled');
        break;

      case DioExceptionType.connectionError:
        if (err.error is SocketException) {
          exception = NetworkException(
            'No internet connection. Please check your network.',
          );
        } else {
          exception = NetworkException('Connection error occurred');
        }
        break;

      case DioExceptionType.badCertificate:
        exception = NetworkException('SSL certificate error');
        break;

      case DioExceptionType.unknown:
      default:
        if (err.error is SocketException) {
          exception = NetworkException(
            'No internet connection. Please check your network.',
          );
        } else {
          exception = AppException(
            'An unexpected error occurred: ${err.message}',
          );
        }
        break;
    }

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        error: exception,
        type: err.type,
      ),
    );
  }

  AppException _handleStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return ServerException('Bad request');
      case 401:
        return AuthenticationException('Unauthorized. Please login again.');
      case 403:
        return AuthenticationException('Access forbidden');
      case 404:
        return ServerException('Resource not found');
      case 408:
        return TimeoutException('Request timeout');
      case 429:
        return ServerException('Too many requests. Please try again later.');
      case 500:
        return ServerException('Internal server error');
      case 502:
        return ServerException('Bad gateway');
      case 503:
        return ServerException('Service unavailable');
      case 504:
        return TimeoutException('Gateway timeout');
      default:
        return ServerException(
          'Server error occurred (Status: $statusCode)',
        );
    }
  }
}
