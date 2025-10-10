// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
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
    gh.lazySingleton<_i895.Connectivity>(() => dioModule.provideConnectivity());
    gh.singleton<_i482.LocalStorage>(
        () => _i482.LocalStorage(gh<_i460.SharedPreferences>()));
    gh.factory<_i976.AuthLocalDataSource>(
        () => _i976.AuthLocalDataSource(gh<_i355.HiveStorage>()));
    gh.factory<_i732.AuthRemoteDataSource>(() => _i732.AuthRemoteDataSource(
          gh<_i24.HttpClient>(),
          gh<_i482.LocalStorage>(),
        ));
    gh.lazySingleton<_i877.AuthRepository>(() => _i446.AuthRepositoryImpl(
          remoteDataSource: gh<_i732.AuthRemoteDataSource>(),
          localDataSource: gh<_i976.AuthLocalDataSource>(),
        ));
    gh.lazySingleton<_i75.NetworkInfo>(
        () => _i75.NetworkInfoImpl(gh<_i895.Connectivity>()));
    gh.factory<_i605.CheckLoginStatus>(
        () => _i605.CheckLoginStatus(gh<_i877.AuthRepository>()));
    gh.factory<_i666.GetCurrentUser>(
        () => _i666.GetCurrentUser(gh<_i877.AuthRepository>()));
    gh.factory<_i466.Login>(() => _i466.Login(gh<_i877.AuthRepository>()));
    gh.factory<_i911.Logout>(() => _i911.Logout(gh<_i877.AuthRepository>()));
    gh.factory<_i349.PrepareCaptcha>(
        () => _i349.PrepareCaptcha(gh<_i877.AuthRepository>()));
    gh.factory<_i706.AuthBloc>(() => _i706.AuthBloc(
          prepareCaptcha: gh<_i349.PrepareCaptcha>(),
          login: gh<_i466.Login>(),
          logout: gh<_i911.Logout>(),
          checkLoginStatus: gh<_i605.CheckLoginStatus>(),
          getCurrentUser: gh<_i666.GetCurrentUser>(),
        ));
    return this;
  }
}

class _$StorageModule extends _i299.StorageModule {}

class _$DioModule extends _i731.DioModule {}
