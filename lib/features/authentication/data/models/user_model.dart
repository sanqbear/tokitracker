import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

/// User model for data layer
@JsonSerializable()
@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  @JsonKey(name: 'username')
  final String username;

  @HiveField(1)
  @JsonKey(name: 'session_cookie')
  final String sessionCookie;

  @HiveField(2)
  @JsonKey(name: 'login_time')
  final DateTime? loginTime;

  UserModel({
    required this.username,
    required this.sessionCookie,
    this.loginTime,
  });

  /// Convert from entity
  factory UserModel.fromEntity(User user) {
    return UserModel(
      username: user.username,
      sessionCookie: user.sessionCookie,
      loginTime: user.loginTime,
    );
  }

  /// Convert to entity
  User toEntity() {
    return User(
      username: username,
      sessionCookie: sessionCookie,
      loginTime: loginTime,
    );
  }

  /// From JSON
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// To JSON
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserModel copyWith({
    String? username,
    String? sessionCookie,
    DateTime? loginTime,
  }) {
    return UserModel(
      username: username ?? this.username,
      sessionCookie: sessionCookie ?? this.sessionCookie,
      loginTime: loginTime ?? this.loginTime,
    );
  }
}
