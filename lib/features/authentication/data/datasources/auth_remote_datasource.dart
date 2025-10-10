import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/http_client.dart';
import '../../../../core/storage/local_storage.dart';

/// Authentication remote data source
/// Handles API calls for authentication
@injectable
class AuthRemoteDataSource {
  final HttpClient httpClient;
  final LocalStorage localStorage;

  AuthRemoteDataSource(this.httpClient, this.localStorage);

  /// Prepare captcha session and get captcha image
  /// Returns: (imageBytes, sessionCookie, timestamp)
  Future<(Uint8List, String, int)> prepareCaptcha() async {
    try {
      final baseUrl = localStorage.getBaseUrl() ?? '';

      if (baseUrl.isEmpty) {
        throw ServerException('Base URL not configured');
      }

      // Extract PHPSESSID cookie from CookieJar (not from headers)
      // CookieManager intercepts Set-Cookie headers automatically
      final uri = Uri.parse(baseUrl);
      final cookies = await httpClient.getCookies(uri);

      String sessionCookie = '';
      for (final cookie in cookies) {
        if (cookie.name == 'PHPSESSID') {
          sessionCookie = cookie.value;
          break;
        }
      }

      if (sessionCookie.isEmpty) {
        throw ServerException('Failed to get session cookie. Please check Base URL and server availability.');
      }

      // Step 2: Get captcha image
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imageResponse = await httpClient.get(
        '$baseUrl/plugin/kcaptcha/kcaptcha_image.php',
        queryParameters: {'t': timestamp.toString()},
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Cookie': 'PHPSESSID=$sessionCookie'},
        ),
      );

      final imageBytes = Uint8List.fromList(imageResponse.data);

      return (imageBytes, sessionCookie, timestamp);
    } on DioException catch (e) {
      if (e.error is AppException) {
        rethrow;
      }
      throw ServerException('Failed to prepare captcha: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to prepare captcha: $e');
    }
  }

  /// Login with credentials
  /// Returns session cookie on success
  Future<String> login({
    required String username,
    required String password,
    required String captchaAnswer,
    required String sessionCookie,
  }) async {
    try {
      final baseUrl = localStorage.getBaseUrl() ?? '';

      if (baseUrl.isEmpty) {
        throw ServerException('Base URL not configured');
      }

      // Submit login
      final response = await httpClient.post(
        '$baseUrl/bbs/login_check.php',
        data: FormData.fromMap({
          'auto_login': 'on',
          'mb_id': username,
          'mb_password': password,
          'captcha_key': captchaAnswer,
        }),
        options: Options(
          headers: {'Cookie': 'PHPSESSID=$sessionCookie'},
          followRedirects: false,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      // Check for successful login (302 redirect)
      if (response.statusCode == 302) {
        // Follow redirect to complete login
        await httpClient.get(
          '$baseUrl/',
          queryParameters: {
            'captcha_key': captchaAnswer,
            'auto_login': 'on',
          },
          options: Options(
            headers: {'Cookie': 'PHPSESSID=$sessionCookie'},
          ),
        );

        return sessionCookie;
      } else {
        throw AuthenticationException('Login failed: Invalid credentials or captcha');
      }
    } on DioException catch (e) {
      if (e.error is AppException) {
        rethrow;
      }
      throw AuthenticationException('Login failed: ${e.message}');
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AuthenticationException('Login failed: $e');
    }
  }

  /// Logout (clear server session)
  Future<void> logout() async {
    try {
      // Clear cookies on the client side
      await httpClient.clearCookies();
    } catch (e) {
      throw ServerException('Logout failed: $e');
    }
  }
}
