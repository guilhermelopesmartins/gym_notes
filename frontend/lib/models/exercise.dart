// lib/models/exercise.dart
import 'package:json_annotation/json_annotation.dart';

part 'exercise.g.dart'; 

@JsonSerializable()
class Exercise {
  final String id;
  final String name;
  final String? description;
  @JsonKey(name: 'category')
  final String category;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Exercise({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) => _$ExerciseFromJson(json);
  
  Map<String, dynamic> toJson() => _$ExerciseToJson(this);
}

@JsonSerializable()
class ExerciseCreate {
  final String name;
  final String? description;
  @JsonKey(name: 'category')
  final String? category;

  ExerciseCreate({
    required this.name,
    this.description,
    this.category,
  });

  factory ExerciseCreate.fromJson(Map<String, dynamic> json) => _$ExerciseCreateFromJson(json);
  Map<String, dynamic> toJson() => _$ExerciseCreateToJson(this);
}

@JsonSerializable()
class ExerciseUpdate {
  final String? name;
  final String? description;
  @JsonKey(name: 'category')
  final String? category;

  ExerciseUpdate({
    this.name,
    this.description,
    this.category,
  });

  factory ExerciseUpdate.fromJson(Map<String, dynamic> json) => _$ExerciseUpdateFromJson(json);
  Map<String, dynamic> toJson() => _$ExerciseUpdateToJson(this);
}