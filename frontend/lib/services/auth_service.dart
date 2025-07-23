// lib/services/auth_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gym_notes/models/user.dart';
import 'package:gym_notes/models/token.dart';
import 'package:gym_notes/utils/constants.dart';

class AuthService extends ChangeNotifier {
  final String _baseUrl = Constants.BASE_URL;
  final String _tokenKey = Constants.TOKEN_KEY;
  final String _userIdKey = Constants.USER_ID_KEY;

  String? _token;
  String? _currentUserId;
  User? _currentUser;

  String? get token => _token;
  String? get currentUserId => _currentUserId;
  User? get currentUser => _currentUser;

  AuthService() {
    _loadTokenAndUser();
  }

  Future<void> _loadTokenAndUser() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    _currentUserId = prefs.getString(_userIdKey);
    if (_token != null || _currentUserId != null) {
      notifyListeners();
    }
  }

  Future<void> _saveToken(String token, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userIdKey, userId);
    _token = token;
    _currentUserId = userId;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    _token = null;
    _currentUserId = null;
    notifyListeners();
  }

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
        body: jsonEncode(userCreate.toJson()),
      );

      if (response.statusCode == 201) {
        return User.fromJson(jsonDecode(response.body));
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

  Future<User?> login(String username, String password) async {
    final uri = Uri.parse('$_baseUrl/auth/token');
    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final tokenData = Token.fromJson(jsonDecode(response.body));
        final user = await getMe(tokenData.accessToken);
        if (user != null) {
          await _saveToken(tokenData.accessToken, user.id);
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
      rethrow;
    }
  }

  Future<User?> getMe([String? specificToken]) async {
    final currentToken = specificToken ?? _token; 
    if (currentToken == null) {
      await logout();
      return null;
    }

    final uri = Uri.parse('$_baseUrl/auth/me');
    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $currentToken',
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

  Future<User?> updateUser(UserUpdate userUpdate) async {
    if (_token == null) {
      throw Exception('No authentication token found. Please log in.');
    }

    final uri = Uri.parse('$_baseUrl/auth/me');
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
  
  Future<String?> uploadProfilePicture(File imageFile) async {
    final uri = Uri.parse('$_baseUrl/auth/upload_profile_picture');
    try {
      var request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
        ));

      var response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(respStr);
        final String? imageUrl = responseData['url'];
        if (imageUrl != null) {
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
        rethrow;
      }
    }

    final uri = Uri.parse('$_baseUrl/auth/register');
    final userCreate = UserCreate(
      username: username,
      email: email,
      password: password,
      profilePictureUrl: profilePictureUrl,
    );

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userCreate.toJson()),
      );

      if (response.statusCode == 201) {
        final registeredUser = User.fromJson(jsonDecode(response.body));
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