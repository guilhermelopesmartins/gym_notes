// lib/utils/constants.dart
class Constants {
  // Para Android Emulator, 'localhost' do seu PC é acessível via 10.0.2.2
  // Para iOS Simulator, 'localhost' ou 127.0.0.1 funciona
  // Para testes no navegador Flutter Web, 'localhost' ou 127.0.0.1 funciona
  // Certifique-se que o backend FastAPI está rodando em http://localhost:8000
  static const String BASE_URL = 'http://10.0.2.2:8000'; // 'http://127.0.0.1:8000';
  // static const String BASE_URL = 'http://localhost:8000'; // Para iOS Simulator ou Web
  // static const String BASE_URL = 'http://192.168.1.100:8000'; // Para dispositivo físico (substitua pelo IP do seu PC)

  static const String TOKEN_KEY = 'jwt_token';
  static const String USER_ID_KEY = 'user_id';
}