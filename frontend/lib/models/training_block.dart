// lib/models/training_block.dart
import 'package:json_annotation/json_annotation.dart';

// Se você quiser incluir os detalhes do usuário que possui este bloco, importe User
import 'package:gym_notes/models/user.dart'; 

part 'training_block.g.dart'; // Parte gerada automaticamente pelo json_serializable

// --- Modelo Principal do Bloco de Treino (schemas.TrainingBlockInDB) ---
@JsonSerializable()
class TrainingBlock {
  final String id;
  final String title;
  final String? description;
  @JsonKey(name: 'color_hex')
  final String colorHex;
  @JsonKey(name: 'user_id')
  final String userId; // O ID do usuário dono do bloco
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  final User? user; // Detalhes do usuário dono

  TrainingBlock({
    required this.id,
    required this.title,
    this.description,
    required this.colorHex,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  // Factory constructor para desserialização JSON
  factory TrainingBlock.fromJson(Map<String, dynamic> json) => _$TrainingBlockFromJson(json);

  // Método para serialização JSON
  Map<String, dynamic> toJson() => _$TrainingBlockToJson(this);
}

// --- Modelo para Criação de Bloco de Treino (schemas.TrainingBlockCreate) ---
@JsonSerializable()
class TrainingBlockCreate {
  final String title;
  final String? description;
  @JsonKey(name: 'color_hex')
  final String colorHex;

  TrainingBlockCreate({
    required this.title,
    this.description,
    this.colorHex = '#FFFFFF', // Valor padrão, como no backend
  });

  factory TrainingBlockCreate.fromJson(Map<String, dynamic> json) => _$TrainingBlockCreateFromJson(json);
  Map<String, dynamic> toJson() => _$TrainingBlockCreateToJson(this);
}

// --- Modelo para Atualização de Bloco de Treino (schemas.TrainingBlockUpdate) ---
@JsonSerializable()
class TrainingBlockUpdate {
  final String? title;
  final String? description;
  @JsonKey(name: 'color_hex')
  final String? colorHex;

  TrainingBlockUpdate({
    this.title,
    this.description,
    this.colorHex,
  });

  factory TrainingBlockUpdate.fromJson(Map<String, dynamic> json) => _$TrainingBlockUpdateFromJson(json);
  Map<String, dynamic> toJson() => _$TrainingBlockUpdateToJson(this);
}