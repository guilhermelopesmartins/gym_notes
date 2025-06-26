// lib/models/exercise_log.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart'; // Para gerar UUIDs se precisar no frontend

// Importe outros modelos se ExerciseLogWithDetails precisar deles.
// Por exemplo, se você quiser incluir detalhes do Exercise ou TrainingBlock diretamente no log.
import 'package:gym_notes/models/exercise.dart';
import 'package:gym_notes/models/training_block.dart';
import 'package:gym_notes/models/user.dart'; // Se o log incluir detalhes do usuário

part 'exercise_log.g.dart'; // Parte gerada automaticamente pelo json_serializable

@JsonSerializable()
class SetData {
  final int set; // Nome do campo 'set' no backend
  final int reps;
  final double weight; // Note: peso é obrigatório no seu SetData do backend
  final String? unit;
  final int? rpe;
  final String? notes; // 'notes' dentro do SetData para notas específicas do set

  SetData({
    required this.set,
    required this.reps,
    required this.weight, // obrigatório
    this.unit = 'kg', // Padrão 'kg' conforme seu backend
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
  final String userId; // Adicionado para refletir a associação do backend
  @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
  final DateTime logDate;
  @JsonKey(name: 'sets_reps_data')
  final List<SetData> setsRepsData;
  final String? notes;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  // Construtor
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

  // Factory constructor para desserialização JSON
  factory ExerciseLog.fromJson(Map<String, dynamic> json) => _$ExerciseLogFromJson(json);

  // Método para serialização JSON
  Map<String, dynamic> toJson() => _$ExerciseLogToJson(this);

  // Métodos estáticos auxiliares para serialização/desserialização de datas
  static DateTime _dateFromJson(String date) => DateTime.parse(date);
  static String _dateToJson(DateTime date) => date.toIso8601String().split('T')[0]; // Apenas a data YYYY-MM-DD
}

// --- Modelo para Criar/Atualizar (sem IDs gerados pelo backend) ---
@JsonSerializable()
class ExerciseLogCreateUpdate {
  @JsonKey(name: 'training_block_id')
  final String trainingBlockId;
  @JsonKey(name: 'exercise_id')
  final String exerciseId;
  @JsonKey(name: 'log_date', fromJson: _dateFromJson, toJson: _dateToJson)
  final DateTime logDate;
  @JsonKey(name: 'sets_reps_data')
  final List<SetData> setsRepsData;
  final String? notes;

  ExerciseLogCreateUpdate({
    required this.trainingBlockId,
    required this.exerciseId,
    required this.logDate,
    required this.setsRepsData,
    this.notes,
  });

  factory ExerciseLogCreateUpdate.fromJson(Map<String, dynamic> json) => _$ExerciseLogCreateUpdateFromJson(json);
  Map<String, dynamic> toJson() => _$ExerciseLogCreateUpdateToJson(this);

  // Reutiliza os mesmos métodos de data
  static DateTime _dateFromJson(String date) => DateTime.parse(date);
  static String _dateToJson(DateTime date) => date.toIso8601String().split('T')[0];
}

@JsonSerializable()
class ExerciseLogWithDetails extends ExerciseLog {
  final Exercise exercise;
  @JsonKey(name: 'training_block')
  final TrainingBlock trainingBlock; // Assumindo que você tem um modelo TrainingBlock no Flutter
  final User user; // Assumindo que você tem um modelo User no Flutter

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