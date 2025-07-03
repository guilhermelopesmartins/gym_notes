// lib/services/exercise_log_service.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:gym_notes/models/exercise_log.dart';
import 'package:gym_notes/services/auth_service.dart';
import 'package:gym_notes/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExerciseLogService extends ChangeNotifier {
  final String _baseUrl = Constants.BASE_URL;

  List<ExerciseLog> _exerciseLogs = [];
  String? _currentTrainingBlockId;
  String? _currentExerciseId;

  List<ExerciseLog> get exerciseLogs => _exerciseLogs;
  String? get currentTrainingBlockId => _currentTrainingBlockId;
  String? get currentExerciseId => _currentExerciseId;

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constants.TOKEN_KEY);
  }

  // Método para buscar logs de exercícios com filtros
  Future<void> fetchExerciseLogs({
    String? trainingBlockId,
    String? exerciseId,
    DateTime? logDate,
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        throw Exception("Usuário não autenticado.");
      }

      final Map<String, dynamic> queryParams = {
        'skip': skip.toString(),
        'limit': limit.toString(),
      };
      if (trainingBlockId != null && trainingBlockId.isNotEmpty) {
        queryParams['training_block_id'] = trainingBlockId;
      }
      if (exerciseId != null && exerciseId.isNotEmpty) {
        queryParams['exercise_id'] = exerciseId;
      }
      if (logDate != null) {
        queryParams['log_date'] = logDate.toIso8601String().split('T')[0]; // Formato YYYY-MM-DD
      }
      final uri = Uri.parse('$_baseUrl/exercise_logs/')
          .replace(queryParameters: queryParams);
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      // Usar ExerciseLogWithDetails se a API retornar os dados aninhados
      _exerciseLogs = (json.decode(response.body) as List)
          .map((json) => ExerciseLog.fromJson(json as Map<String, dynamic>))
          // Ou: .map((json) => ExerciseLogWithDetails.fromJson(json as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao buscar logs de exercícios: $e');
      throw Exception('Erro ao buscar logs de exercícios: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  void setContextualLogIds({String? trainingBlockId, String? exerciseId}) {
    _currentTrainingBlockId = trainingBlockId;
    _currentExerciseId = exerciseId;
  }

  void clearContextualLogIds() {
    _currentTrainingBlockId = null;
    _currentExerciseId = null;
  }

  // Método para criar um novo log de exercício
  Future<ExerciseLog> createExerciseLog(ExerciseLogCreateUpdate logCreate) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        throw Exception("Usuário não autenticado.");
      }
      final uri = Uri.parse('$_baseUrl/exercise_logs/');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(logCreate.toJson()),
      );
      if (response.statusCode == 201 || response.statusCode == 200) { // O FastAPI geralmente retorna 201 Created para POST
        // CORREÇÃO: Decodifique o corpo da resposta JSON
        debugPrint('Response Body (log): ${response.body}');
        final newLog = ExerciseLog.fromJson(json.decode(response.body) as Map<String, dynamic>);
        _exerciseLogs.add(newLog); // Adiciona ao cache local
        notifyListeners();
        return newLog;
      } else {
        // Trate erros HTTP, incluindo mensagens do backend
        final errorData = json.decode(response.body);
        final errorMessage = errorData['detail'] ?? 'Falha ao criar log de exercício.';
        throw Exception('Erro HTTP ${response.statusCode}: $errorMessage');
      }
    } catch (e) {
      debugPrint('Erro ao criar log de exercício: $e');
      throw Exception('Erro ao criar log de exercício: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  // Método para atualizar um log de exercício
  Future<ExerciseLog> updateExerciseLog(String id, ExerciseLogCreateUpdate logUpdate) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        throw Exception("Usuário não autenticado.");
      }
      final uri = Uri.parse('$_baseUrl/exercise_logs/$id');
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(logUpdate.toJson()),
      );
      final updatedLog = ExerciseLog.fromJson(response as Map<String, dynamic>);
      // Atualiza no cache local
      final index = _exerciseLogs.indexWhere((log) => log.id == id);
      if (index != -1) {
        _exerciseLogs[index] = updatedLog;
      }
      notifyListeners();
      return updatedLog;
    } catch (e) {
      debugPrint('Erro ao atualizar log de exercício: $e');
      throw Exception('Erro ao atualizar log de exercício: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  // Método para deletar um log de exercício
  Future<void> deleteExerciseLog(String id) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        throw Exception("Usuário não autenticado.");
      }
      final uri = Uri.parse('$_baseUrl/exercise_logs/$id');
      await http.delete(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      _exerciseLogs.removeWhere((log) => log.id == id); // Remove do cache local
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao deletar log de exercício: $e');
      throw Exception('Erro ao deletar log de exercício: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }
}