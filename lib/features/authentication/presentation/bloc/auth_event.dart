import 'package:equatable/equatable.dart';

/// Authentication events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Load captcha event
class AuthCaptchaRequested extends AuthEvent {
  const AuthCaptchaRequested();
}

/// Login event
class AuthLoginRequested extends AuthEvent {
  final String username;
  final String password;
  final String captchaAnswer;

  const AuthLoginRequested({
    required this.username,
    required this.password,
    required this.captchaAnswer,
  });

  @override
  List<Object?> get props => [username, password, captchaAnswer];
}

/// Logout event
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Check login status event
class AuthStatusChecked extends AuthEvent {
  const AuthStatusChecked();
}

/// Get current user event
class AuthCurrentUserRequested extends AuthEvent {
  const AuthCurrentUserRequested();
}
