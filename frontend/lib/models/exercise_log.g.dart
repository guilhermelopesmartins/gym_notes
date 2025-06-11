// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExerciseLog _$ExerciseLogFromJson(Map<String, dynamic> json) => ExerciseLog(
  id: json['id'] as String,
  trainingBlockId: json['training_block_id'] as String,
  exerciseId: json['exercise_id'] as String,
  userId: json['user_id'] as String,
  logDate: ExerciseLog._dateFromJson(json['logDate'] as String),
  setsRepsData: json['sets_reps_data'] as Map<String, dynamic>?,
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ExerciseLogToJson(ExerciseLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'training_block_id': instance.trainingBlockId,
      'exercise_id': instance.exerciseId,
      'user_id': instance.userId,
      'logDate': ExerciseLog._dateToJson(instance.logDate),
      'sets_reps_data': instance.setsRepsData,
      'notes': instance.notes,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

ExerciseLogCreateUpdate _$ExerciseLogCreateUpdateFromJson(
  Map<String, dynamic> json,
) => ExerciseLogCreateUpdate(
  trainingBlockId: json['training_block_id'] as String,
  exerciseId: json['exercise_id'] as String,
  logDate: ExerciseLogCreateUpdate._dateFromJson(json['log_date'] as String),
  setsRepsData: json['sets_reps_data'] as Map<String, dynamic>?,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$ExerciseLogCreateUpdateToJson(
  ExerciseLogCreateUpdate instance,
) => <String, dynamic>{
  'training_block_id': instance.trainingBlockId,
  'exercise_id': instance.exerciseId,
  'log_date': ExerciseLogCreateUpdate._dateToJson(instance.logDate),
  'sets_reps_data': instance.setsRepsData,
  'notes': instance.notes,
};
