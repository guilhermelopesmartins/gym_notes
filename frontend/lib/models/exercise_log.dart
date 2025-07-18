// lib/models/exercise_log.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart'; 

import 'package:gym_notes/models/exercise.dart';
import 'package:gym_notes/models/training_block.dart';
import 'package:gym_notes/models/user.dart'; 

part 'exercise_log.g.dart'; 

@JsonSerializable()
class SetData {
  final int set; 
  final int reps;
  final double weight; 
  final String? unit;
  final int? rpe;
  final String? notes; 

  SetData({
    required this.set,
    required this.reps,
    required this.weight, 
    this.unit = 'kg', 
    this.rpe,
    this.notes,
  });

  factory SetData.fromJson(Map<String, dynamic> json) => _$SetDataFromJson(json);
  Map<String, dynamic> toJson() => _$SetDataToJson(this);
}

@JsonSerializable()
class ExerciseLog {
  final String id;
  @JsonKey(name: 'training_block_id')
  final String trainingBlockId;
  @JsonKey(name: 'exercise_id')
  final String exerciseId;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
  final DateTime logDate;
  @JsonKey(name: 'sets_reps_data')
  final List<SetData> setsRepsData;
  final String? notes;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  ExerciseLog({
    required this.id,
    required this.trainingBlockId,
    required this.exerciseId,
    required this.userId,
    required this.logDate,
    required this.setsRepsData,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory ExerciseLog.fromJson(Map<String, dynamic> json) => _$ExerciseLogFromJson(json);
  
  Map<String, dynamic> toJson() => _$ExerciseLogToJson(this);
  
  static DateTime _dateFromJson(String date) => DateTime.parse(date);
  static String _dateToJson(DateTime date) => date.toIso8601String().split('T')[0]; 
}

@JsonSerializable()
class ExerciseLogCreateUpdate {
  @JsonKey(name: 'training_block_id')
  final String trainingBlockId;
  @JsonKey(name: 'exercise_id')
  final String exerciseId;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'log_date', fromJson: _dateFromJson, toJson: _dateToJson)
  final DateTime logDate;
  @JsonKey(name: 'sets_reps_data')
  final List<SetData> setsRepsData;
  final String? notes;

  ExerciseLogCreateUpdate({
    required this.trainingBlockId,
    required this.exerciseId,
    required this.userId,
    required this.logDate,
    required this.setsRepsData,
    this.notes,
  });

  factory ExerciseLogCreateUpdate.fromJson(Map<String, dynamic> json) => _$ExerciseLogCreateUpdateFromJson(json);
  Map<String, dynamic> toJson() => _$ExerciseLogCreateUpdateToJson(this);

  static DateTime _dateFromJson(String date) => DateTime.parse(date);
  static String _dateToJson(DateTime date) => date.toIso8601String().split('T')[0];
}

@JsonSerializable()
class ExerciseLogWithDetails extends ExerciseLog {
  final Exercise exercise;
  @JsonKey(name: 'training_block')
  final TrainingBlock trainingBlock; 
  final User user; 

  ExerciseLogWithDetails({
    required super.id,
    required super.trainingBlockId,
    required super.exerciseId,
    required super.userId,
    required super.logDate,
    required super.setsRepsData,
    super.notes,
    required super.createdAt,
    required super.updatedAt,
    required this.exercise,
    required this.trainingBlock,
    required this.user,
  });

  factory ExerciseLogWithDetails.fromJson(Map<String, dynamic> json) => _$ExerciseLogWithDetailsFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ExerciseLogWithDetailsToJson(this);
}