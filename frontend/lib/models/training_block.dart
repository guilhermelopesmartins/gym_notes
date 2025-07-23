// lib/models/training_block.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:gym_notes/models/user.dart'; 
part 'training_block.g.dart'; 

@JsonSerializable()
class TrainingBlock {
  final String id;
  final String title;
  final String? description;
  @JsonKey(name: 'color_hex')
  final String colorHex;
  @JsonKey(name: 'user_id')
  final String userId; 
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  final User? user; 

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
  
  factory TrainingBlock.fromJson(Map<String, dynamic> json) => _$TrainingBlockFromJson(json);

  Map<String, dynamic> toJson() => _$TrainingBlockToJson(this);
}

@JsonSerializable()
class TrainingBlockCreate {
  final String title;
  final String? description;
  @JsonKey(name: 'color_hex')
  final String colorHex;

  TrainingBlockCreate({
    required this.title,
    this.description,
    this.colorHex = '#FFFFFF', 
  });

  factory TrainingBlockCreate.fromJson(Map<String, dynamic> json) => _$TrainingBlockCreateFromJson(json);
  Map<String, dynamic> toJson() => _$TrainingBlockCreateToJson(this);
}

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