// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i100;

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
import 'features/authentication/data/datasources/auth_local_datasource.dart'
    as _i976;
import 'features/authentication/data/datasources/auth_remote_datasource.dart'
    as _i732;
import 'features/authentication/data/models/user_model.dart' as _i909;
import 'features/authentication/data/repositories/auth_repository_impl.dart'
    as _i446;
import 'features/authentication/domain/entities/captcha_data.dart' as _i785;
import 'features/authentication/domain/entities/user.dart' as _i473;
import 'features/authentication/domain/repositories/auth_repository.dart'
    as _i877;
import 'features/authentication/domain/usecases/check_login_status.dart'
    as _i605;
import 'features/authentication/domain/usecases/get_current_user.dart' as _i666;
import 'features/authentication/domain/usecases/login.dart' as _i466;
import 'features/authentication/domain/usecases/logout.dart' as _i911;
import 'features/authentication/domain/usecases/prepare_captcha.dart' as _i349;
import 'features/authentication/presentation/bloc/auth_bloc.dart' as _i706;
import 'features/authentication/presentation/bloc/auth_event.dart' as _i536;
import 'features/authentication/presentation/bloc/auth_state.dart' as _i45;
import 'features/authentication/presentation/pages/login_page.dart' as _i244;
import 'features/authentication/presentation/widgets/login_form.dart' as _i348;
import 'features/home/presentation/pages/home_page.dart' as _i521;
import 'features/settings/presentation/pages/settings_page.dart' as _i212;
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
    gh.factory<_i909.UserModelAdapter>(() => _i909.UserModelAdapter());
    gh.factory<_i536.AuthCaptchaRequested>(
        () => const _i536.AuthCaptchaRequested());
    gh.factory<_i536.AuthLogoutRequested>(
        () => const _i536.AuthLogoutRequested());
    gh.factory<_i536.AuthStatusChecked>(() => const _i536.AuthStatusChecked());
    gh.factory<_i536.AuthCurrentUserRequested>(
        () => const _i536.AuthCurrentUserRequested());
    gh.factory<_i45.AuthInitial>(() => const _i45.AuthInitial());
    gh.factory<_i45.AuthLoading>(() => const _i45.AuthLoading());
    gh.factory<_i45.AuthCaptchaLoading>(() => const _i45.AuthCaptchaLoading());
    gh.factory<_i45.AuthUnauthenticated>(
        () => const _i45.AuthUnauthenticated());
    gh.factory<_i45.AuthLoginInProgress>(
        () => const _i45.AuthLoginInProgress());
    gh.factory<_i45.AuthLogoutInProgress>(
        () => const _i45.AuthLogoutInProgress());
    gh.factory<_LoginFormState>(() => _LoginFormState());
    gh.factory<_SettingsPageState>(() => _SettingsPageState());
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
    gh.factory<_i244.LoginPage>(() => _i244.LoginPage(key: gh<_i409.Key>()));
    gh.factory<_i348.LoginForm>(() => _i348.LoginForm(key: gh<_i409.Key>()));
    gh.factory<_i521.HomePage>(() => _i521.HomePage(key: gh<_i409.Key>()));
    gh.factory<_i212.SettingsPage>(
        () => _i212.SettingsPage(key: gh<_i409.Key>()));
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
    gh.factory<_i45.AuthCaptchaError>(
        () => _i45.AuthCaptchaError(gh<String>()));
    gh.factory<_i45.AuthLoginError>(() => _i45.AuthLoginError(gh<String>()));
    gh.factory<_i45.AuthError>(() => _i45.AuthError(gh<String>()));
    gh.singleton<_i924.AppRouter>(
        () => _i924.AppRouter(gh<_i482.LocalStorage>()));
    gh.factory<_i466.LoginParams>(() => _i466.LoginParams(
          username: gh<String>(),
          password: gh<String>(),
          captchaAnswer: gh<String>(),
          sessionCookie: gh<String>(),
        ));
    gh.factory<_i25.RouteGuard>(
        () => _i25.RouteGuard(gh<_i482.LocalStorage>()));
    gh.factory<_i45.AuthCaptchaLoaded>(() => _i45.AuthCaptchaLoaded(
          captchaImage: gh<_i100.Uint8List>(),
          sessionCookie: gh<String>(),
          timestamp: gh<int>(),
        ));
    gh.factory<_i976.AuthLocalDataSource>(
        () => _i976.AuthLocalDataSource(gh<_i355.HiveStorage>()));
    gh.factory<_i638.CaptchaRequiredException>(
        () => _i638.CaptchaRequiredException(gh<String>()));
    gh.factory<_i536.AuthLoginRequested>(() => _i536.AuthLoginRequested(
          username: gh<String>(),
          password: gh<String>(),
          captchaAnswer: gh<String>(),
        ));
    gh.factoryAsync<_i732.AuthRemoteDataSource>(
        () async => _i732.AuthRemoteDataSource(
              await getAsync<_i24.HttpClient>(),
              gh<_i482.LocalStorage>(),
            ));
    gh.factory<_i728.CaptchaFailure>(() => _i728.CaptchaFailure(
          gh<String>(),
          gh<String>(),
        ));
    gh.lazySingletonAsync<_i877.AuthRepository>(
        () async => _i446.AuthRepositoryImpl(
              remoteDataSource: await getAsync<_i732.AuthRemoteDataSource>(),
              localDataSource: gh<_i976.AuthLocalDataSource>(),
            ));
    gh.factory<_i909.UserModel>(() => _i909.UserModel(
          username: gh<String>(),
          sessionCookie: gh<String>(),
          loginTime: gh<DateTime>(),
        ));
    gh.factory<_i473.User>(() => _i473.User(
          username: gh<String>(),
          sessionCookie: gh<String>(),
          loginTime: gh<DateTime>(),
        ));
    gh.factory<_i785.CaptchaData>(() => _i785.CaptchaData(
          imageBytes: gh<_i100.Uint8List>(),
          sessionCookie: gh<String>(),
          timestamp: gh<int>(),
        ));
    gh.lazySingleton<_i75.NetworkInfo>(
        () => _i75.NetworkInfoImpl(gh<_i895.Connectivity>()));
    gh.factoryAsync<_i605.CheckLoginStatus>(() async =>
        _i605.CheckLoginStatus(await getAsync<_i877.AuthRepository>()));
    gh.factoryAsync<_i666.GetCurrentUser>(() async =>
        _i666.GetCurrentUser(await getAsync<_i877.AuthRepository>()));
    gh.factoryAsync<_i466.Login>(
        () async => _i466.Login(await getAsync<_i877.AuthRepository>()));
    gh.factoryAsync<_i911.Logout>(
        () async => _i911.Logout(await getAsync<_i877.AuthRepository>()));
    gh.factoryAsync<_i349.PrepareCaptcha>(() async =>
        _i349.PrepareCaptcha(await getAsync<_i877.AuthRepository>()));
    gh.factory<_i45.AuthAuthenticated>(
        () => _i45.AuthAuthenticated(gh<_i473.User>()));
    gh.factoryAsync<_i706.AuthBloc>(() async => _i706.AuthBloc(
          prepareCaptcha: await getAsync<_i349.PrepareCaptcha>(),
          login: await getAsync<_i466.Login>(),
          logout: await getAsync<_i911.Logout>(),
          checkLoginStatus: await getAsync<_i605.CheckLoginStatus>(),
          getCurrentUser: await getAsync<_i666.GetCurrentUser>(),
        ));
    return this;
  }
}

class _$StorageModule extends _i299.StorageModule {}

class _$DioModule extends _i731.DioModule {}
