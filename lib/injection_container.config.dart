// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:cookie_jar/cookie_jar.dart' as _i557;
import 'package:flutter/material.dart' as _i409;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import 'config/routes/app_router.dart' as _i924;
import 'config/routes/route_guard.dart' as _i25;
import 'core/error/exceptions.dart' as _i638;
import 'core/error/failures.dart' as _i728;
import 'core/network/dio_module.dart' as _i731;
import 'core/network/http_client.dart' as _i24;
import 'core/network/interceptors/captcha_interceptor.dart' as _i665;
import 'core/network/interceptors/error_interceptor.dart' as _i578;
import 'core/network/interceptors/logging_interceptor.dart' as _i251;
import 'core/network/network_info.dart' as _i75;
import 'core/storage/file_manager.dart' as _i238;
import 'core/storage/hive_storage.dart' as _i355;
import 'core/storage/local_storage.dart' as _i482;
import 'core/storage/storage_module.dart' as _i299;
import 'main.dart' as _i67;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final storageModule = _$StorageModule();
    final dioModule = _$DioModule();
    gh.factory<_i665.CaptchaInterceptor>(() => _i665.CaptchaInterceptor());
    gh.factory<_i578.ErrorInterceptor>(() => _i578.ErrorInterceptor());
    gh.factory<_i251.LoggingInterceptor>(() => _i251.LoggingInterceptor());
    gh.singleton<_i238.FileManager>(() => _i238.FileManager());
    gh.singleton<_i355.HiveStorage>(() => _i355.HiveStorage());
    await gh.singletonAsync<_i460.SharedPreferences>(
      () => storageModule.provideSharedPreferences(),
      preResolve: true,
    );
    gh.lazySingletonAsync<_i557.CookieJar>(() => dioModule.provideCookieJar());
    gh.lazySingleton<_i895.Connectivity>(() => dioModule.provideConnectivity());
    gh.singletonAsync<_i24.HttpClient>(
        () async => _i24.HttpClient(await getAsync<_i557.CookieJar>()));
    gh.singleton<_i482.LocalStorage>(
        () => _i482.LocalStorage(gh<_i460.SharedPreferences>()));
    gh.factory<_i67.MyApp>(() => _i67.MyApp(key: gh<_i409.Key>()));
    gh.factory<_i638.AppException>(() => _i638.AppException(
          gh<String>(),
          gh<String>(),
        ));
    gh.factory<_i638.ServerException>(
        () => _i638.ServerException(gh<String>()));
    gh.factory<_i638.CacheException>(() => _i638.CacheException(gh<String>()));
    gh.factory<_i638.NetworkException>(
        () => _i638.NetworkException(gh<String>()));
    gh.factory<_i638.AuthenticationException>(
        () => _i638.AuthenticationException(gh<String>()));
    gh.factory<_i638.TimeoutException>(
        () => _i638.TimeoutException(gh<String>()));
    gh.factory<_i728.ServerFailure>(() => _i728.ServerFailure(gh<String>()));
    gh.factory<_i728.CacheFailure>(() => _i728.CacheFailure(gh<String>()));
    gh.factory<_i728.NetworkFailure>(() => _i728.NetworkFailure(gh<String>()));
    gh.factory<_i728.AuthenticationFailure>(
        () => _i728.AuthenticationFailure(gh<String>()));
    gh.factory<_i728.TimeoutFailure>(() => _i728.TimeoutFailure(gh<String>()));
    gh.factory<_i728.ValidationFailure>(
        () => _i728.ValidationFailure(gh<String>()));
    gh.singleton<_i924.AppRouter>(
        () => _i924.AppRouter(gh<_i482.LocalStorage>()));
    gh.factory<_i25.RouteGuard>(
        () => _i25.RouteGuard(gh<_i482.LocalStorage>()));
    gh.factory<_i638.CaptchaRequiredException>(
        () => _i638.CaptchaRequiredException(gh<String>()));
    gh.factory<_i728.CaptchaFailure>(() => _i728.CaptchaFailure(
          gh<String>(),
          gh<String>(),
        ));
    gh.lazySingleton<_i75.NetworkInfo>(
        () => _i75.NetworkInfoImpl(gh<_i895.Connectivity>()));
    return this;
  }
}

class _$StorageModule extends _i299.StorageModule {}

class _$DioModule extends _i731.DioModule {}
