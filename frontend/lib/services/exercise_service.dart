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
  Future<void> fetchExercises({int skip = 0, int limit = 100, String? category, String? search}) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        throw Exception("Usuário não autenticado.");
      }

      final uri = Uri.parse('$_baseUrl/exercises/?skip=$skip&limit=$limit&category=$category&search=$search');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      _exercises = (response as List)
          .map((json) => Exercise.fromJson(json as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao buscar exercícios: $e');
      throw Exception('Erro ao buscar exercícios: ${e.toString().replaceFirst('Exception: ', '')}');
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
      final newExercise = Exercise.fromJson(response as Map<String, dynamic>);
      _exercises.add(newExercise); // Adiciona ao cache local
      notifyListeners();
      return newExercise;
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