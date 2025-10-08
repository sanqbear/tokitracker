import 'package:equatable/equatable.dart';

/// User entity
/// Represents an authenticated user
class User extends Equatable {
  final String username;
  final String sessionCookie;
  final DateTime? loginTime;

  const User({
    required this.username,
    required this.sessionCookie,
    this.loginTime,
  });

  /// Check if session is valid
  bool get isValid => sessionCookie.isNotEmpty;

  /// Copy with new values
  User copyWith({
    String? username,
    String? sessionCookie,
    DateTime? loginTime,
  }) {
    return User(
      username: username ?? this.username,
      sessionCookie: sessionCookie ?? this.sessionCookie,
      loginTime: loginTime ?? this.loginTime,
    );
  }

  @override
  List<Object?> get props => [username, sessionCookie, loginTime];

  @override
  String toString() =>
      'User(username: $username, sessionCookie: ${sessionCookie.substring(0, sessionCookie.length.clamp(0, 10))}..., loginTime: $loginTime)';
}
