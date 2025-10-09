// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:cookie_jar/cookie_jar.dart' as _i557;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import 'core/network/dio_module.dart' as _i731;
import 'core/network/http_client.dart' as _i24;
import 'core/network/network_info.dart' as _i75;
import 'core/storage/file_manager.dart' as _i238;
import 'core/storage/hive_storage.dart' as _i355;
import 'core/storage/local_storage.dart' as _i482;
import 'core/storage/storage_module.dart' as _i299;
import 'features/authentication/data/datasources/auth_local_datasource.dart'
    as _i976;
import 'features/authentication/data/datasources/auth_remote_datasource.dart'
    as _i732;
import 'features/authentication/data/repositories/auth_repository_impl.dart'
    as _i446;
import 'features/authentication/domain/repositories/auth_repository.dart'
    as _i877;
import 'features/authentication/domain/usecases/check_login_status.dart'
    as _i605;
import 'features/authentication/domain/usecases/get_current_user.dart' as _i666;
import 'features/authentication/domain/usecases/login.dart' as _i466;
import 'features/authentication/domain/usecases/logout.dart' as _i911;
import 'features/authentication/domain/usecases/prepare_captcha.dart' as _i349;
import 'features/authentication/presentation/bloc/auth_bloc.dart' as _i706;

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
    gh.singleton<_i238.FileManager>(() => _i238.FileManager());
    await gh.singletonAsync<_i460.SharedPreferences>(
      () => storageModule.provideSharedPreferences(),
      preResolve: true,
    );
    gh.singleton<_i355.HiveStorage>(() => _i355.HiveStorage());
    gh.lazySingletonAsync<_i557.CookieJar>(() => dioModule.provideCookieJar());
    gh.lazySingleton<_i895.Connectivity>(() => dioModule.provideConnectivity());
    gh.singletonAsync<_i24.HttpClient>(
        () async => _i24.HttpClient(await getAsync<_i557.CookieJar>()));
    gh.singleton<_i482.LocalStorage>(
        () => _i482.LocalStorage(gh<_i460.SharedPreferences>()));
    gh.factory<_i976.AuthLocalDataSource>(
        () => _i976.AuthLocalDataSource(gh<_i355.HiveStorage>()));
    gh.factoryAsync<_i732.AuthRemoteDataSource>(
        () async => _i732.AuthRemoteDataSource(
              await getAsync<_i24.HttpClient>(),
              gh<_i482.LocalStorage>(),
            ));
    gh.lazySingletonAsync<_i877.AuthRepository>(
        () async => _i446.AuthRepositoryImpl(
              remoteDataSource: await getAsync<_i732.AuthRemoteDataSource>(),
              localDataSource: gh<_i976.AuthLocalDataSource>(),
            ));
    gh.lazySingleton<_i75.NetworkInfo>(
        () => _i75.NetworkInfoImpl(gh<_i895.Connectivity>()));
    gh.factoryAsync<_i466.Login>(
        () async => _i466.Login(await getAsync<_i877.AuthRepository>()));
    gh.factoryAsync<_i605.CheckLoginStatus>(() async =>
        _i605.CheckLoginStatus(await getAsync<_i877.AuthRepository>()));
    gh.factoryAsync<_i666.GetCurrentUser>(() async =>
        _i666.GetCurrentUser(await getAsync<_i877.AuthRepository>()));
    gh.factoryAsync<_i911.Logout>(
        () async => _i911.Logout(await getAsync<_i877.AuthRepository>()));
    gh.factoryAsync<_i349.PrepareCaptcha>(() async =>
        _i349.PrepareCaptcha(await getAsync<_i877.AuthRepository>()));
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
