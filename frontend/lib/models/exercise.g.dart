// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Exercise _$ExerciseFromJson(Map<String, dynamic> json) => Exercise(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  category: json['category'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ExerciseToJson(Exercise instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'category': instance.category,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

ExerciseCreate _$ExerciseCreateFromJson(Map<String, dynamic> json) =>
    ExerciseCreate(
      name: json['name'] as String,
      description: json['description'] as String?,
      category: json['category'] as String?,
    );

Map<String, dynamic> _$ExerciseCreateToJson(ExerciseCreate instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'category': instance.category,
    };

ExerciseUpdate _$ExerciseUpdateFromJson(Map<String, dynamic> json) =>
    ExerciseUpdate(
      name: json['name'] as String?,
      description: json['description'] as String?,
      category: json['category'] as String?,
    );

Map<String, dynamic> _$ExerciseUpdateToJson(ExerciseUpdate instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'category': instance.category,
    };
