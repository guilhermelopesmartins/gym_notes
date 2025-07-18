// lib/models/user.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:gym_notes/models/training_block.dart';
import 'package:gym_notes/models/exercise_log.dart';
part 'user.g.dart'; 

@JsonSerializable()
class User {
  final String id;
  final String username;
  final String email;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'profile_picture_url')
  final String? profilePictureUrl;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  List<TrainingBlock>? trainingBlocks;
  List<ExerciseLog>? exerciseLogs;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.isActive,
    this.profilePictureUrl,
    required this.createdAt,
    required this.updatedAt,
    this.trainingBlocks,
    this.exerciseLogs,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class UserCreate {
  final String username;
  final String email;
  final String password;
  @JsonKey(name: 'profile_picture_url')
  final String? profilePictureUrl;

  UserCreate({
    required this.username,
    required this.email,
    required this.password,
    this.profilePictureUrl,
  });

  factory UserCreate.fromJson(Map<String, dynamic> json) => _$UserCreateFromJson(json);
  Map<String, dynamic> toJson() => _$UserCreateToJson(this);
}

@JsonSerializable()
class UserLogin {
  final String username;
  final String password;

  UserLogin({
    required this.username,
    required this.password,
  });

  factory UserLogin.fromJson(Map<String, dynamic> json) => _$UserLoginFromJson(json);
  Map<String, dynamic> toJson() => _$UserLoginToJson(this);
}

@JsonSerializable()
class UserUpdate {
  final String? username;
  final String? email;
  final String? password;
  @JsonKey(name: 'profile_picture_url')
  final String? profilePictureUrl;
  @JsonKey(name: 'is_active')
  final bool? isActive;

  UserUpdate({
    this.username,
    this.email,
    this.password,
    this.profilePictureUrl,
    this.isActive,
  });

  factory UserUpdate.fromJson(Map<String, dynamic> json) => _$UserUpdateFromJson(json);
  Map<String, dynamic> toJson() => _$UserUpdateToJson(this);
}