// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_block_exercise.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainingBlockExercise _$TrainingBlockExerciseFromJson(
  Map<String, dynamic> json,
) => TrainingBlockExercise(
  id: json['id'] as String,
  trainingBlockId: json['training_block_id'] as String,
  exerciseId: json['exercise_id'] as String,
  orderInBlock: (json['order_in_block'] as num).toInt(),
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$TrainingBlockExerciseToJson(
  TrainingBlockExercise instance,
) => <String, dynamic>{
  'id': instance.id,
  'training_block_id': instance.trainingBlockId,
  'exercise_id': instance.exerciseId,
  'order_in_block': instance.orderInBlock,
  'notes': instance.notes,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

TrainingBlockExerciseCreate _$TrainingBlockExerciseCreateFromJson(
  Map<String, dynamic> json,
) => TrainingBlockExerciseCreate(
  trainingBlockId: json['training_block_id'] as String,
  exerciseId: json['exercise_id'] as String,
  orderInBlock: (json['order_in_block'] as num).toInt(),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$TrainingBlockExerciseCreateToJson(
  TrainingBlockExerciseCreate instance,
) => <String, dynamic>{
  'training_block_id': instance.trainingBlockId,
  'exercise_id': instance.exerciseId,
  'order_in_block': instance.orderInBlock,
  'notes': instance.notes,
};

TrainingBlockExerciseUpdate _$TrainingBlockExerciseUpdateFromJson(
  Map<String, dynamic> json,
) => TrainingBlockExerciseUpdate(
  trainingBlockId: json['training_block_id'] as String?,
  exerciseId: json['exercise_id'] as String?,
  orderInBlock: (json['order_in_block'] as num?)?.toInt(),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$TrainingBlockExerciseUpdateToJson(
  TrainingBlockExerciseUpdate instance,
) => <String, dynamic>{
  'training_block_id': instance.trainingBlockId,
  'exercise_id': instance.exerciseId,
  'order_in_block': instance.orderInBlock,
  'notes': instance.notes,
};

TrainingBlockExerciseWithDetails _$TrainingBlockExerciseWithDetailsFromJson(
  Map<String, dynamic> json,
) => TrainingBlockExerciseWithDetails(
  id: json['id'] as String,
  trainingBlockId: json['training_block_id'] as String,
  exerciseId: json['exercise_id'] as String,
  orderInBlock: (json['order_in_block'] as num).toInt(),
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  exercise: Exercise.fromJson(json['exercise'] as Map<String, dynamic>),
  trainingBlock: TrainingBlock.fromJson(
    json['training_block'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$TrainingBlockExerciseWithDetailsToJson(
  TrainingBlockExerciseWithDetails instance,
) => <String, dynamic>{
  'id': instance.id,
  'training_block_id': instance.trainingBlockId,
  'exercise_id': instance.exerciseId,
  'order_in_block': instance.orderInBlock,
  'notes': instance.notes,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'exercise': instance.exercise,
  'training_block': instance.trainingBlock,
};
