// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetData _$SetDataFromJson(Map<String, dynamic> json) => SetData(
  set: (json['set'] as num).toInt(),
  reps: (json['reps'] as num).toInt(),
  weight: (json['weight'] as num).toDouble(),
  unit: json['unit'] as String? ?? 'kg',
  rpe: (json['rpe'] as num?)?.toInt(),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$SetDataToJson(SetData instance) => <String, dynamic>{
  'set': instance.set,
  'reps': instance.reps,
  'weight': instance.weight,
  'unit': instance.unit,
  'rpe': instance.rpe,
  'notes': instance.notes,
};

ExerciseLog _$ExerciseLogFromJson(Map<String, dynamic> json) => ExerciseLog(
  id: json['id'] as String,
  trainingBlockId: json['training_block_id'] as String,
  exerciseId: json['exercise_id'] as String,
  userId: json['user_id'] as String,
  logDate: ExerciseLog._dateFromJson(json['logDate'] as String),
  setsRepsData:
      (json['sets_reps_data'] as List<dynamic>)
          .map((e) => SetData.fromJson(e as Map<String, dynamic>))
          .toList(),
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
  setsRepsData:
      (json['sets_reps_data'] as List<dynamic>)
          .map((e) => SetData.fromJson(e as Map<String, dynamic>))
          .toList(),
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

ExerciseLogWithDetails _$ExerciseLogWithDetailsFromJson(
  Map<String, dynamic> json,
) => ExerciseLogWithDetails(
  id: json['id'] as String,
  trainingBlockId: json['training_block_id'] as String,
  exerciseId: json['exercise_id'] as String,
  userId: json['user_id'] as String,
  logDate: ExerciseLog._dateFromJson(json['logDate'] as String),
  setsRepsData:
      (json['sets_reps_data'] as List<dynamic>)
          .map((e) => SetData.fromJson(e as Map<String, dynamic>))
          .toList(),
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  exercise: Exercise.fromJson(json['exercise'] as Map<String, dynamic>),
  trainingBlock: TrainingBlock.fromJson(
    json['training_block'] as Map<String, dynamic>,
  ),
  user: User.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ExerciseLogWithDetailsToJson(
  ExerciseLogWithDetails instance,
) => <String, dynamic>{
  'id': instance.id,
  'training_block_id': instance.trainingBlockId,
  'exercise_id': instance.exerciseId,
  'user_id': instance.userId,
  'logDate': ExerciseLog._dateToJson(instance.logDate),
  'sets_reps_data': instance.setsRepsData,
  'notes': instance.notes,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'exercise': instance.exercise,
  'training_block': instance.trainingBlock,
  'user': instance.user,
};
