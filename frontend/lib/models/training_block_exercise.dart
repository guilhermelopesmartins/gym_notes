// lib/models/training_block_exercise.dart
import 'package:json_annotation/json_annotation.dart';

// Importe os modelos Exercise e TrainingBlock se você planeja usar o
// schemas.TrainingBlockExerciseWithDetails do seu backend.
import 'package:gym_notes/models/exercise.dart'; 
import 'package:gym_notes/models/training_block.dart'; 

part 'training_block_exercise.g.dart'; // Parte gerada automaticamente pelo json_serializable

// --- Modelo Principal de TrainingBlockExercise (schemas.TrainingBlockExerciseInDB) ---
@JsonSerializable()
class TrainingBlockExercise {
  final String id;
  @JsonKey(name: 'training_block_id')
  final String trainingBlockId;
  @JsonKey(name: 'exercise_id')
  final String exerciseId;
  @JsonKey(name: 'order_in_block')
  final int orderInBlock; // Posição do exercício dentro do bloco
  final String? notes; // Notas específicas para este exercício neste bloco
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  TrainingBlockExercise({
    required this.id,
    required this.trainingBlockId,
    required this.exerciseId,
    required this.orderInBlock,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor para desserialização JSON
  factory TrainingBlockExercise.fromJson(Map<String, dynamic> json) => _$TrainingBlockExerciseFromJson(json);

  // Método para serialização JSON
  Map<String, dynamic> toJson() => _$TrainingBlockExerciseToJson(this);
}

// --- Modelo para Criação de TrainingBlockExercise (schemas.TrainingBlockExerciseCreate) ---
@JsonSerializable()
class TrainingBlockExerciseCreate {
  @JsonKey(name: 'training_block_id')
  final String trainingBlockId;
  @JsonKey(name: 'exercise_id')
  final String exerciseId;
  @JsonKey(name: 'order_in_block')
  final int orderInBlock;
  final String? notes;

  TrainingBlockExerciseCreate({
    required this.trainingBlockId,
    required this.exerciseId,
    required this.orderInBlock,
    this.notes,
  });

  factory TrainingBlockExerciseCreate.fromJson(Map<String, dynamic> json) => _$TrainingBlockExerciseCreateFromJson(json);
  Map<String, dynamic> toJson() => _$TrainingBlockExerciseCreateToJson(this);
}

// --- Modelo para Atualização de TrainingBlockExercise (schemas.TrainingBlockExerciseUpdate) ---
@JsonSerializable()
class TrainingBlockExerciseUpdate {
  @JsonKey(name: 'training_block_id')
  final String? trainingBlockId;
  @JsonKey(name: 'exercise_id')
  final String? exerciseId;
  @JsonKey(name: 'order_in_block')
  final int? orderInBlock;
  final String? notes;

  TrainingBlockExerciseUpdate({
    this.trainingBlockId,
    this.exerciseId,
    this.orderInBlock,
    this.notes,
  });

  factory TrainingBlockExerciseUpdate.fromJson(Map<String, dynamic> json) => _$TrainingBlockExerciseUpdateFromJson(json);
  Map<String, dynamic> toJson() => _$TrainingBlockExerciseUpdateToJson(this);
}

// --- Modelo para TrainingBlockExerciseWithDetails (se você usar no backend) ---
// Este modelo é útil se o seu backend retorna os objetos relacionados completos.
// Lembre-se de importar os modelos correspondentes (Exercise, TrainingBlock).
@JsonSerializable()
class TrainingBlockExerciseWithDetails extends TrainingBlockExercise {
  final Exercise exercise; // Detalhes completos do exercício
  @JsonKey(name: 'training_block')
  final TrainingBlock trainingBlock; // Detalhes completos do bloco de treino

  TrainingBlockExerciseWithDetails({
    required String id,
    required String trainingBlockId,
    required String exerciseId,
    required int orderInBlock,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
    required this.exercise,
    required this.trainingBlock,
  }) : super(
          id: id,
          trainingBlockId: trainingBlockId,
          exerciseId: exerciseId,
          orderInBlock: orderInBlock,
          notes: notes,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory TrainingBlockExerciseWithDetails.fromJson(Map<String, dynamic> json) => _$TrainingBlockExerciseWithDetailsFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$TrainingBlockExerciseWithDetailsToJson(this);
}