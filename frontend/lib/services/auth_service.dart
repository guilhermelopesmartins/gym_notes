// lib/services/auth_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Importa o pacote http
import 'package:shared_preferences/shared_preferences.dart'; // Para armazenamento local

import 'package:gym_notes/models/user.dart'; // Modelos de usuário
import 'package:gym_notes/models/token.dart'; // Modelo de token
import 'package:gym_notes/utils/constants.dart'; // Constantes de URL e chaves

class AuthService extends ChangeNotifier {
  final String _baseUrl = Constants.BASE_URL;
  final String _tokenKey = Constants.TOKEN_KEY;
  final String _userIdKey = Constants.USER_ID_KEY; // Chave para o ID do usuário

  String? _token; // Armazena o token na memória para acesso rápido
  String? _currentUserId; // Armazena o ID do usuário na memória
  User? _currentUser;

  // Getter para o token. Outras classes podem usá-lo.
  String? get token => _token;
  String? get currentUserId => _currentUserId;
  User? get currentUser => _currentUser;

  AuthService() {
    _loadTokenAndUser();
  }


  // --- Métodos de Leitura/Escrita de Token no SharedPreferences ---
  Future<void> _loadTokenAndUser() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    _currentUserId = prefs.getString(_userIdKey);
    if (_token != null || _currentUserId != null) {
      notifyListeners();
    }
  }

  // Salva o token JWT e o ID do usuário no armazenamento local
  Future<void> _saveToken(String token, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userIdKey, userId);
    _token = token;
    _currentUserId = userId;
    notifyListeners();
  }

  // Remove o token JWT e o ID do usuário do armazenamento local (logout)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    _token = null;
    _currentUserId = null;
    notifyListeners();
  }

  // --- Métodos de Autenticação e API ---

  // Método de Registro de Usuário
  Future<User?> register(String username, String email, String password) async {
    final uri = Uri.parse('$_baseUrl/auth/register');
    final userCreate = UserCreate(
      username: username,
      email: email,
      password: password,
    );
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userCreate.toJson()), // Converte o objeto Dart para JSON string
      );

      if (response.statusCode == 201) {
        // Registro bem-sucedido, retorna o usuário registrado
        return User.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 409) {
        // Conflito (usuário/email já existe)
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['detail'] ?? 'Nome de usuário ou email já em uso.');
      } else {
        // Outros erros
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['detail'] ?? 'Falha no registro.');
      }
    } catch (e) {
      print('Erro durante o registro: $e');
      rethrow; // Exception('Failed to connect to the server or process registration: $e');
    }
  }

  // Método de Login de Usuário
  Future<User?> login(String username, String password) async {
    final uri = Uri.parse('$_baseUrl/auth/token');
    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded', // Essencial para OAuth2PasswordRequestForm
        },
        // OAuth2PasswordRequestForm espera 'username' e 'password' no corpo do formulário
        body: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final tokenData = Token.fromJson(jsonDecode(response.body));
        // Após o login, queremos os detalhes completos do usuário logado
        // Fazemos uma requisição para /auth/me usando o token recém-obtido
        final user = await getMe(tokenData.accessToken);
        if (user != null) {
          await _saveToken(tokenData.accessToken, user.id); // Salva o token e o ID do usuário
        }
        return user;
      } else if (response.statusCode == 401) {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['detail'] ?? 'Invalid username or password.');
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['detail'] ?? 'Login failed');
      }
    } catch (e) {
      print('Error during login: $e');
      rethrow; // Exception('Failed to connect to the server or process login: $e');
    }
  }

  // Método para obter os detalhes do usuário logado (usando um token)
  Future<User?> getMe([String? specificToken]) async {
    // Usa o token passado como argumento ou o token armazenado
    final currentToken = specificToken ?? _token; 
    if (currentToken == null) {
      //throw Exception('No authentication token found.');
      await logout();
      return null;
    }

    final uri = Uri.parse('$_baseUrl/auth/me');
    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $currentToken', // Anexa o token para autenticação
        },
      );

      if (response.statusCode == 200) {
        final user = User.fromJson(jsonDecode(response.body));
        _currentUser = user;
        if (_currentUserId == null || _currentUserId != user.id) {
          _currentUserId = user.id;
          notifyListeners();
        }
        return user;
      } else if (response.statusCode == 401) {
        await logout();
        throw Exception('Authentication expired. Please log in again.');
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['detail'] ?? 'Failed to fetch user data');
      }
    } catch (e) {
      print('Error fetching user data: $e');
      throw Exception('Failed to connect to the server or fetch user data: $e');
    }
  }

  // Método para atualizar o perfil do usuário
  Future<User?> updateUser(UserUpdate userUpdate) async {
    if (_token == null) {
      throw Exception('No authentication token found. Please log in.');
    }

    final uri = Uri.parse('$_baseUrl/auth/me'); // Endpoint PUT /auth/me
    try {
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(userUpdate.toJson()),
      );

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        await logout();
        throw Exception('Authentication expired. Please log in again.');
      } else if (response.statusCode == 409) {
         final errorBody = jsonDecode(response.body);
         throw Exception(errorBody['detail'] ?? 'Update failed: Conflict.');
      }
      else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['detail'] ?? 'Failed to update user data');
      }
    } catch (e) {
      print('Error updating user data: $e');
      throw Exception('Failed to connect to the server or update user data: $e');
    }
  }
  
  // Retorna a URL da imagem no backend ou null em caso de falha
  Future<String?> uploadProfilePicture(File imageFile) async {
    final uri = Uri.parse('$_baseUrl/auth/upload_profile_picture');
    try {
      var request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath(
          'file', // O nome do campo do formulário no backend (definido em @router.post("/upload_profile_picture") como `file: UploadFile = File(...)`)
          imageFile.path,
        ));

      var response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(respStr);
        final String? imageUrl = responseData['url']; // URL relativa do backend
        if (imageUrl != null) {
          // Construir a URL completa para ser salva no banco de dados e usada pelo frontend
          return '$_baseUrl$imageUrl';
        }
        return null;
      } else {
        print('Erro no upload da imagem: ${response.statusCode} - $respStr');
        throw Exception('Falha ao fazer upload da imagem: ${jsonDecode(respStr)['detail'] ?? 'Erro desconhecido'}');
      }
    } catch (e) {
      print('Exceção durante o upload da imagem: $e');
      rethrow;
    }
  }

  Future<User?> registerWithProfilePicture(
    String username, String email, String password, File? profilePicture) async {
    String? profilePictureUrl;

    if (profilePicture != null) {
      try {
        profilePictureUrl = await uploadProfilePicture(profilePicture);
        if (profilePictureUrl == null) {
          throw Exception("Falha ao carregar a imagem de perfil.");
        }
      } catch (e) {
        print('Erro ao carregar imagem para registro: $e');
        rethrow; // Rejoga a exceção para que a UI possa lidar com ela
      }
    }

    final uri = Uri.parse('$_baseUrl/auth/register');
    final userCreate = UserCreate(
      username: username,
      email: email,
      password: password,
      profilePictureUrl: profilePictureUrl, // Passa a URL obtida do upload
    );

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userCreate.toJson()),
      );

      if (response.statusCode == 201) {
        final registeredUser = User.fromJson(jsonDecode(response.body));
        // Opcional: Logar o usuário automaticamente após o registro bem-sucedido
        // await login(username, password); 
        return registeredUser;
      } else if (response.statusCode == 409) {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['detail'] ?? 'Nome de usuário ou email já em uso.');
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['detail'] ?? 'Falha no registro.');
      }
    } catch (e) {
      print('Erro durante o registro: $e');
      rethrow;
    }
  }

  Future<void> refreshCurrentUser() async {
    await getMe();
  }
}