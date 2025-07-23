// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_block.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainingBlock _$TrainingBlockFromJson(Map<String, dynamic> json) =>
    TrainingBlock(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      colorHex: json['color_hex'] as String,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      user:
          json['user'] == null
              ? null
              : User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TrainingBlockToJson(TrainingBlock instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'color_hex': instance.colorHex,
      'user_id': instance.userId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'user': instance.user,
    };

TrainingBlockCreate _$TrainingBlockCreateFromJson(Map<String, dynamic> json) =>
    TrainingBlockCreate(
      title: json['title'] as String,
      description: json['description'] as String?,
      colorHex: json['color_hex'] as String? ?? '#FFFFFF',
    );

Map<String, dynamic> _$TrainingBlockCreateToJson(
  TrainingBlockCreate instance,
) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'color_hex': instance.colorHex,
};

TrainingBlockUpdate _$TrainingBlockUpdateFromJson(Map<String, dynamic> json) =>
    TrainingBlockUpdate(
      title: json['title'] as String?,
      description: json['description'] as String?,
      colorHex: json['color_hex'] as String?,
    );

Map<String, dynamic> _$TrainingBlockUpdateToJson(
  TrainingBlockUpdate instance,
) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'color_hex': instance.colorHex,
};
