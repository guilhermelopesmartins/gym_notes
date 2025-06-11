// lib/models/token.dart
import 'package:json_annotation/json_annotation.dart';

part 'token.g.dart'; // Parte gerada automaticamente pelo json_serializable

// --- Modelo Principal do Token (schemas.Token do FastAPI) ---
@JsonSerializable()
class Token {
  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'token_type')
  final String tokenType;

  Token({
    required this.accessToken,
    required this.tokenType,
  });

  // Factory constructor para desserialização JSON
  factory Token.fromJson(Map<String, dynamic> json) => _$TokenFromJson(json);

  // Método para serialização JSON (não é comum serializar Token para enviar, mas é bom ter)
  Map<String, dynamic> toJson() => _$TokenToJson(this);
}

// --- Modelo para TokenData (schemas.TokenData do FastAPI) ---
// Este modelo representa o payload que é *decodificado* do token JWT.
// É mais para uso interno ou se você planeja decodificar o token no frontend
// para extrair informações como o username ou a data de expiração.
// Você não o receberá diretamente da API no login, mas pode criá-lo
// a partir do accessToken se for decodificá-lo.
// Geralmente não é gerado pelo json_serializable pois não é um JSON direto.
/*
class TokenData {
  final String? username;
  // Adicione outros campos se o seu payload JWT incluir (ex: expiracao)

  TokenData({this.username});

  // Não é um factory JsonSerializable pois o payload JWT é diferente de um JSON HTTP.
  // Você decodificaria manualmente ou usaria uma biblioteca JWT para Dart.
  // Exemplo de como você o preencheria após decodificar um JWT:
  // factory TokenData.fromJwtPayload(Map<String, dynamic> payload) {
  //   return TokenData(username: payload['sub']);
  // }
}
*/