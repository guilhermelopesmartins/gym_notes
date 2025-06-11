// lib/models/exercise.dart
import 'package:json_annotation/json_annotation.dart';

part 'exercise.g.dart'; // Parte gerada automaticamente pelo json_serializable

// --- Modelo Principal do Exercício (schemas.ExerciseInDB ou ExerciseBase) ---
@JsonSerializable()
class Exercise {
  final String id;
  final String name;
  final String? description;
  @JsonKey(name: 'muscle_group')
  final String? muscleGroup;
  @JsonKey(name: 'equipment_type')
  final String? equipmentType;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Exercise({
    required this.id,
    required this.name,
    this.description,
    this.muscleGroup,
    this.equipmentType,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor para desserialização JSON
  factory Exercise.fromJson(Map<String, dynamic> json) => _$ExerciseFromJson(json);

  // Método para serialização JSON
  Map<String, dynamic> toJson() => _$ExerciseToJson(this);
}

// --- Modelo para Criação de Exercício (schemas.ExerciseCreate) ---
@JsonSerializable()
class ExerciseCreate {
  final String name;
  final String? description;
  @JsonKey(name: 'muscle_group')
  final String? muscleGroup;
  @JsonKey(name: 'equipment_type')
  final String? equipmentType;

  ExerciseCreate({
    required this.name,
    this.description,
    this.muscleGroup,
    this.equipmentType,
  });

  factory ExerciseCreate.fromJson(Map<String, dynamic> json) => _$ExerciseCreateFromJson(json);
  Map<String, dynamic> toJson() => _$ExerciseCreateToJson(this);
}

// --- Modelo para Atualização de Exercício (schemas.ExerciseUpdate) ---
@JsonSerializable()
class ExerciseUpdate {
  final String? name;
  final String? description;
  @JsonKey(name: 'muscle_group')
  final String? muscleGroup;
  @JsonKey(name: 'equipment_type')
  final String? equipmentType;

  ExerciseUpdate({
    this.name,
    this.description,
    this.muscleGroup,
    this.equipmentType,
  });

  factory ExerciseUpdate.fromJson(Map<String, dynamic> json) => _$ExerciseUpdateFromJson(json);
  Map<String, dynamic> toJson() => _$ExerciseUpdateToJson(this);
}