import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/check_login_status.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/prepare_captcha.dart';
import 'auth_event.dart';
import 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final PrepareCaptcha prepareCaptcha;
  final Login login;
  final Logout logout;
  final CheckLoginStatus checkLoginStatus;
  final GetCurrentUser getCurrentUser;

  String? _currentSessionCookie;
  Uint8List? _currentCaptchaImage;
  int? _currentTimestamp;

  AuthBloc({
    required this.prepareCaptcha,
    required this.login,
    required this.logout,
    required this.checkLoginStatus,
    required this.getCurrentUser,
  }) : super(const AuthInitial()) {
    on<AuthCaptchaRequested>(_onCaptchaRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthStatusChecked>(_onStatusChecked);
    on<AuthCurrentUserRequested>(_onCurrentUserRequested);
  }

  Future<void> _onCaptchaRequested(
    AuthCaptchaRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthCaptchaLoading());

    final result = await prepareCaptcha();

    result.fold(
      (failure) => emit(AuthCaptchaError(failure.message)),
      (captchaData) {
        // Store captcha data for later use (especially on login error)
        _currentSessionCookie = captchaData.sessionCookie;
        _currentCaptchaImage = captchaData.imageBytes;
        _currentTimestamp = captchaData.timestamp;

        emit(AuthCaptchaLoaded(
          captchaImage: captchaData.imageBytes,
          sessionCookie: captchaData.sessionCookie,
          timestamp: captchaData.timestamp,
        ));
      },
    );
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (_currentSessionCookie == null) {
      emit(const AuthLoginError('Session not initialized. Please load captcha first.'));
      return;
    }

    emit(const AuthLoginInProgress());

    final result = await login(LoginParams(
      username: event.username,
      password: event.password,
      captchaAnswer: event.captchaAnswer,
      sessionCookie: _currentSessionCookie!,
    ));

    result.fold(
      (failure) {
        // Preserve captcha on login failure so user can retry
        emit(AuthLoginError(
          failure.message,
          captchaImage: _currentCaptchaImage,
          sessionCookie: _currentSessionCookie,
          timestamp: _currentTimestamp,
        ));
      },
      (user) {
        // Clear all captcha data after successful login
        _currentSessionCookie = null;
        _currentCaptchaImage = null;
        _currentTimestamp = null;
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLogoutInProgress());

    final result = await logout();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) {
        _currentSessionCookie = null;
        emit(const AuthUnauthenticated());
      },
    );
  }

  Future<void> _onStatusChecked(
    AuthStatusChecked event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await checkLoginStatus();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (isLoggedIn) {
        if (isLoggedIn) {
          // Get current user
          add(const AuthCurrentUserRequested());
        } else {
          emit(const AuthUnauthenticated());
        }
      },
    );
  }

  Future<void> _onCurrentUserRequested(
    AuthCurrentUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await getCurrentUser();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) {
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(const AuthUnauthenticated());
        }
      },
    );
  }
}
