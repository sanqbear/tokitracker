import 'package:dio/dio.dart';
import '../../error/exceptions.dart';

/// Captcha detection interceptor
/// Detects when a captcha verification is required
/// Based on legacy app's captcha detection logic
class CaptchaInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Check for 302 redirect to captcha page
    // Legacy logic: if (r.code() == 302 && r.header("location").contains("captcha.php"))
    if (response.statusCode == 302) {
      final location = response.headers.value('location');
      if (location != null && location.contains('captcha.php')) {
        // Reject with CaptchaRequiredException
        handler.reject(
          DioException(
            requestOptions: response.requestOptions,
            response: response,
            error: CaptchaRequiredException(location),
            type: DioExceptionType.badResponse,
          ),
        );
        return;
      }
    }

    // Check for 403 Forbidden (may also indicate captcha)
    if (response.statusCode == 403) {
      // Try multiple methods to get the captcha URL
      String? captchaUrl;

      // 1. Check for Location header (some servers use this)
      final location = response.headers.value('location');
      if (location != null && location.isNotEmpty) {
        captchaUrl = location;
      }

      // 2. Use the actual request URL that returned 403
      // The WebView will load this URL and the server will show the captcha
      if (captchaUrl == null || captchaUrl.isEmpty) {
        captchaUrl = response.requestOptions.uri.toString();
      }

      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: CaptchaRequiredException(captchaUrl),
          type: DioExceptionType.badResponse,
        ),
      );
      return;
    }

    // Check response body for captcha indicators
    if (response.data is String) {
      final body = response.data as String;

      // Check if body contains captcha-related content
      if (body.contains('captcha') &&
          (body.contains('verification') || body.contains('recaptcha'))) {
        handler.reject(
          DioException(
            requestOptions: response.requestOptions,
            response: response,
            error: CaptchaRequiredException(),
            type: DioExceptionType.badResponse,
          ),
        );
        return;
      }
    }

    super.onResponse(response, handler);
  }
}
