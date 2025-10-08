/// Base exception class
class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, [this.code]);

  @override
  String toString() => 'AppException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Server exception
class ServerException extends AppException {
  ServerException([String message = 'Server error occurred']) : super(message);
}

/// Cache exception
class CacheException extends AppException {
  CacheException([String message = 'Cache error occurred']) : super(message);
}

/// Network exception
class NetworkException extends AppException {
  NetworkException([String message = 'Network error occurred']) : super(message);
}

/// Captcha required exception
class CaptchaRequiredException extends AppException {
  final String? captchaUrl;

  CaptchaRequiredException([this.captchaUrl])
      : super('Captcha verification required');
}

/// Authentication exception
class AuthenticationException extends AppException {
  AuthenticationException([String message = 'Authentication failed'])
      : super(message);
}

/// Timeout exception
class TimeoutException extends AppException {
  TimeoutException([String message = 'Request timeout']) : super(message);
}
