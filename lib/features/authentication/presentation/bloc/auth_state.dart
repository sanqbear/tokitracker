import 'package:equatable/equatable.dart';
import 'dart:typed_data';

import '../../domain/entities/user.dart';

/// Authentication states
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Captcha loading state
class AuthCaptchaLoading extends AuthState {
  const AuthCaptchaLoading();
}

/// Captcha loaded state
class AuthCaptchaLoaded extends AuthState {
  final Uint8List captchaImage;
  final String sessionCookie;
  final int timestamp;

  const AuthCaptchaLoaded({
    required this.captchaImage,
    required this.sessionCookie,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [captchaImage, sessionCookie, timestamp];
}

/// Captcha error state
class AuthCaptchaError extends AuthState {
  final String message;

  const AuthCaptchaError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Authenticated state
class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Unauthenticated state
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Login in progress state
class AuthLoginInProgress extends AuthState {
  const AuthLoginInProgress();
}

/// Login error state
class AuthLoginError extends AuthState {
  final String message;
  final Uint8List? captchaImage;
  final String? sessionCookie;
  final int? timestamp;

  const AuthLoginError(
    this.message, {
    this.captchaImage,
    this.sessionCookie,
    this.timestamp,
  });

  @override
  List<Object?> get props => [message, captchaImage, sessionCookie, timestamp];
}

/// Logout in progress state
class AuthLogoutInProgress extends AuthState {
  const AuthLogoutInProgress();
}

/// Error state
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
