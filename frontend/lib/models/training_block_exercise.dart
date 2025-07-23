// lib/models/training_block_exercise.dart
import 'package:json_annotation/json_annotation.dart';

import 'package:gym_notes/models/exercise.dart'; 
import 'package:gym_notes/models/training_block.dart'; 

part 'training_block_exercise.g.dart'; 

@JsonSerializable()
class TrainingBlockExercise {
  final String id;
  @JsonKey(name: 'training_block_id')
  final String trainingBlockId;
  @JsonKey(name: 'exercise_id')
  final String exerciseId;
  @JsonKey(name: 'order_in_block')
  final int orderInBlock; 
  final String? notes; 
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

  factory TrainingBlockExercise.fromJson(Map<String, dynamic> json) => _$TrainingBlockExerciseFromJson(json);
  
  Map<String, dynamic> toJson() => _$TrainingBlockExerciseToJson(this);
}

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

@JsonSerializable()
class TrainingBlockExerciseWithDetails extends TrainingBlockExercise {
  final Exercise? exercise; 
  @JsonKey(name: 'training_block')
  final TrainingBlock? trainingBlock; 

  TrainingBlockExerciseWithDetails({
    required String id,
    required String trainingBlockId,
    required String exerciseId,
    required int orderInBlock,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.exercise,
    this.trainingBlock,
  }) : super(
          id: id,
          trainingBlockId: trainingBlockId,
          exerciseId: exerciseId,
          orderInBlock: orderInBlock,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory TrainingBlockExerciseWithDetails.fromJson(Map<String, dynamic> json) => _$TrainingBlockExerciseWithDetailsFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$TrainingBlockExerciseWithDetailsToJson(this);
}