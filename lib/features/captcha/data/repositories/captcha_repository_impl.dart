import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:tokitracker/core/error/failures.dart';
import 'package:tokitracker/core/network/http_client.dart';
import 'package:tokitracker/core/storage/local_storage.dart';
import 'package:tokitracker/features/captcha/domain/repositories/captcha_repository.dart';

/// Implementation of CaptchaRepository
/// Handles saving cookies to HttpClient and storing user agent
@Injectable(as: CaptchaRepository)
class CaptchaRepositoryImpl implements CaptchaRepository {
  final HttpClient httpClient;
  final LocalStorage localStorage;

  CaptchaRepositoryImpl(this.httpClient, this.localStorage);

  @override
  Future<Either<Failure, void>> saveCookies(
    Map<String, String> cookies,
  ) async {
    try {
      final baseUrl = localStorage.getBaseUrl();
      if (baseUrl == null || baseUrl.isEmpty) {
        return const Left(CacheFailure('Base URL not configured'));
      }

      final uri = Uri.parse(baseUrl);

      // Convert Map<String, String> to List<Cookie>
      final cookieList = cookies.entries
          .map((e) => Cookie(e.key, e.value))
          .toList();

      // Save cookies to HttpClient's CookieJar
      await httpClient.setCookies(uri, cookieList);

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to save cookies: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserAgent(String userAgent) async {
    try {
      // Store user agent in local storage for persistence
      await localStorage.setUserAgent(userAgent);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to update user agent: $e'));
    }
  }
}
