// lib/models/user.dart
import 'package:json_annotation/json_annotation.dart';

// Importe outros modelos que podem ser relacionados, se necessário
// Por exemplo, se você quiser carregar TrainingBlocks ou ExerciseLogs diretamente com o usuário
import 'package:gym_notes/models/training_block.dart';
import 'package:gym_notes/models/exercise_log.dart';

part 'user.g.dart'; // Parte gerada automaticamente pelo json_serializable

// --- Modelo Principal do Usuário (Schemas de Saída como UserInDB ou UserInDBBase) ---
@JsonSerializable()
class User {
  final String id;
  final String username;
  final String email;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'profile_picture_url')
  final String? profilePictureUrl;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  List<TrainingBlock>? trainingBlocks;
  List<ExerciseLog>? exerciseLogs;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.isActive,
    this.profilePictureUrl,
    required this.createdAt,
    required this.updatedAt,
    this.trainingBlocks,
    this.exerciseLogs,
  });

  // Factory constructor para desserialização JSON
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  // Método para serialização JSON
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

// --- Modelo para Criação de Usuário (schemas.UserCreate do FastAPI) ---
@JsonSerializable()
class UserCreate {
  final String username;
  final String email;
  final String password;
  @JsonKey(name: 'profile_picture_url')
  final String? profilePictureUrl;

  UserCreate({
    required this.username,
    required this.email,
    required this.password,
    this.profilePictureUrl,
  });

  factory UserCreate.fromJson(Map<String, dynamic> json) => _$UserCreateFromJson(json);
  Map<String, dynamic> toJson() => _$UserCreateToJson(this);
}

// --- Modelo para Login de Usuário (schemas.UserLogin do FastAPI) ---
// Note: OAuth2PasswordRequestForm no FastAPI espera 'username' e 'password' diretamente,
// e não um JSON com esses campos. No Flutter, você geralmente enviará esses dados como
// `application/x-www-form-urlencoded` ou como JSON para um endpoint que aceita BaseModel.
// Vamos usar um BaseModel simples aqui, mas o serviço de Auth pode precisar de tratamento especial.
@JsonSerializable()
class UserLogin {
  final String username;
  final String password;

  UserLogin({
    required this.username,
    required this.password,
  });

  factory UserLogin.fromJson(Map<String, dynamic> json) => _$UserLoginFromJson(json);
  Map<String, dynamic> toJson() => _$UserLoginToJson(this);
}

// --- Modelo para Atualização de Usuário (schemas.UserUpdate do FastAPI) ---
@JsonSerializable()
class UserUpdate {
  final String? username;
  final String? email;
  final String? password;
  @JsonKey(name: 'profile_picture_url')
  final String? profilePictureUrl;
  @JsonKey(name: 'is_active')
  final bool? isActive;

  UserUpdate({
    this.username,
    this.email,
    this.password,
    this.profilePictureUrl,
    this.isActive,
  });

  factory UserUpdate.fromJson(Map<String, dynamic> json) => _$UserUpdateFromJson(json);
  Map<String, dynamic> toJson() => _$UserUpdateToJson(this);
}