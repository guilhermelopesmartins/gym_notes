// lib/services/exercise_service.dart
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:gym_notes/models/exercise.dart';
import 'package:gym_notes/services/auth_service.dart';
import 'package:gym_notes/utils/constants.dart';

class ExerciseService extends ChangeNotifier {
  final String _baseUrl = Constants.BASE_URL;

  List<Exercise> _exercises = [];
  List<Exercise> get exercises => _exercises;

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constants.TOKEN_KEY);
  }

  // Método para buscar todas as definições de exercícios
 Future<void> fetchExercises({
    int skip = 0,
    int limit = 100,
    String? category, // Deixe nullable se o backend permitir, ajuste o uso
    String? search,   // Deixe nullable
  }) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        throw Exception("Usuário não autenticado. Token JWT ausente.");
      }

      // Construa a URI com parâmetros de consulta corretamente
      final Map<String, dynamic> queryParams = {
        'skip': skip.toString(),
        'limit': limit.toString(),
      };
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final uri = Uri.parse('$_baseUrl/exercises/')
          .replace(queryParameters: queryParams);

      debugPrint('Fetching exercises from: $uri'); // Para depuração
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json', // Adicionar Content-Type
        },
      );

      debugPrint('Status Code: ${response.statusCode}'); // Para depuração
      debugPrint('Response Body: ${response.body}'); // Para depuração

      if (response.statusCode == 200) {
        // CORREÇÃO CRUCIAL AQUI: Decodifique o corpo da resposta JSON
        _exercises = (json.decode(response.body) as List)
            .map((json) => Exercise.fromJson(json as Map<String, dynamic>))
            .toList();
        notifyListeners();
      } else {
        // Trate erros HTTP, incluindo mensagens do backend
        final errorData = json.decode(response.body);
        final errorMessage = errorData['detail'] ?? 'Falha ao carregar exercícios.';
        throw Exception('Erro HTTP ${response.statusCode}: $errorMessage');
      }
    } catch (e) {
      debugPrint('Erro no fetchExercises: $e'); // Log completo do erro Dart
      throw Exception('Erro ao buscar exercícios: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

   Future<void> fetchExercisesByTrainingBlock(String trainingBlockId) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        throw Exception("Usuário não autenticado.");
      }
      final uri = Uri.parse('$_baseUrl/exercises/by_training_block/$trainingBlockId');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        _exercises = (json.decode(response.body) as List)
            .map((json) => Exercise.fromJson(json as Map<String, dynamic>))
            .toList();
        notifyListeners();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Falha ao carregar exercícios por bloco de treino.');
      }
    } catch (e) {
      debugPrint('Erro ao buscar exercícios por bloco de treino: $e');
      throw Exception('Erro ao buscar exercícios por bloco de treino: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }


  // Método para criar uma nova definição de exercício
  Future<Exercise> createExercise(ExerciseCreate exerciseCreate) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        throw Exception("Usuário não autenticado.");
      }

      final uri = Uri.parse('$_baseUrl/exercises/');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode( exerciseCreate.toJson()),
      );
      if (response.statusCode == 201) { // Verifique o status code antes de decodificar
        final Map<String, dynamic> responseBodyMap = jsonDecode(response.body) as Map<String, dynamic>;
        final newExercise = Exercise.fromJson(responseBodyMap);
        _exercises.add(newExercise); // Adiciona ao cache local
        notifyListeners();
        return newExercise;
      } else {
        // Tratar erros do backend (ex: 409 Conflict)
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Falha ao criar exercício');
      }
    } catch (e) {
      debugPrint('Erro ao criar exercício: $e');
      throw Exception('Erro ao criar exercício: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  // Método para atualizar uma definição de exercício
  Future<Exercise> updateExercise(String id, ExerciseUpdate exerciseUpdate) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        throw Exception("Usuário não autenticado.");
      }
      final uri = Uri.parse('$_baseUrl/exercises/$id');
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(exerciseUpdate.toJson()),
      );
      final updatedExercise = Exercise.fromJson(response as Map<String, dynamic>);
      // Atualiza no cache local
      final index = _exercises.indexWhere((e) => e.id == id);
      if (index != -1) {
        _exercises[index] = updatedExercise;
      }
      notifyListeners();
      return updatedExercise;
    } catch (e) {
      debugPrint('Erro ao atualizar exercício: $e');
      throw Exception('Erro ao atualizar exercício: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  // Método para deletar uma definição de exercício
  Future<void> deleteExercise(String id) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        throw Exception("Usuário não autenticado.");
      }
      final uri = Uri.parse('$_baseUrl/exercises/$id');
      await http.delete(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      _exercises.removeWhere((e) => e.id == id); // Remove do cache local
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao deletar exercício: $e');
      throw Exception('Erro ao deletar exercício: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  // Método para obter um exercício por ID (útil se você for para uma tela de detalhes de exercício puro)
  Exercise? getExerciseById(String id) {
    return _exercises.firstWhere((e) => e.id == id, orElse: () => throw Exception('Exercício não encontrado no cache.'));
  }
}