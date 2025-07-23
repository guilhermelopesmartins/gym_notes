// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String,
  username: json['username'] as String,
  email: json['email'] as String,
  isActive: json['is_active'] as bool,
  profilePictureUrl: json['profile_picture_url'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'email': instance.email,
  'is_active': instance.isActive,
  'profile_picture_url': instance.profilePictureUrl,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

UserCreate _$UserCreateFromJson(Map<String, dynamic> json) => UserCreate(
  username: json['username'] as String,
  email: json['email'] as String,
  password: json['password'] as String,
  profilePictureUrl: json['profile_picture_url'] as String?,
);

Map<String, dynamic> _$UserCreateToJson(UserCreate instance) =>
    <String, dynamic>{
      'username': instance.username,
      'email': instance.email,
      'password': instance.password,
      'profile_picture_url': instance.profilePictureUrl,
    };

UserLogin _$UserLoginFromJson(Map<String, dynamic> json) => UserLogin(
  username: json['username'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$UserLoginToJson(UserLogin instance) => <String, dynamic>{
  'username': instance.username,
  'password': instance.password,
};

UserUpdate _$UserUpdateFromJson(Map<String, dynamic> json) => UserUpdate(
  username: json['username'] as String?,
  email: json['email'] as String?,
  password: json['password'] as String?,
  profilePictureUrl: json['profile_picture_url'] as String?,
  isActive: json['is_active'] as bool?,
);

Map<String, dynamic> _$UserUpdateToJson(UserUpdate instance) =>
    <String, dynamic>{
      'username': instance.username,
      'email': instance.email,
      'password': instance.password,
      'profile_picture_url': instance.profilePictureUrl,
      'is_active': instance.isActive,
    };
