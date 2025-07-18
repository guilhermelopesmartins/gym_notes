// lib/services/training_block_exercise_service.dart
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gym_notes/models/training_block_exercise.dart'; 
import 'package:gym_notes/services/auth_service.dart';
import 'package:gym_notes/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrainingBlockExerciseService extends ChangeNotifier {
  final String _baseUrl = Constants.BASE_URL;

  List<TrainingBlockExerciseWithDetails> _blockExercises = [];
  List<TrainingBlockExerciseWithDetails> get blockExercises => _blockExercises;

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constants.TOKEN_KEY);
  }

  Future<void> fetchTrainingBlockExercises(String trainingBlockId) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        throw Exception('Token de autenticação não encontrado. Faça login novamente.');
      }

      final uri = Uri.parse('$_baseUrl/training_block_exercises/by_block/$trainingBlockId');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        _blockExercises = (json.decode(response.body) as List)
            .map((json) => TrainingBlockExerciseWithDetails.fromJson(json as Map<String, dynamic>))
            .toList();
        notifyListeners();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Falha ao carregar exercícios do bloco de treino.');
      }
    } catch (e) {
      debugPrint('Erro ao buscar exercícios do bloco de treino: $e');
      throw Exception('Erro ao buscar exercícios do bloco de treino: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  Future<TrainingBlockExercise> addExerciseToTrainingBlock(TrainingBlockExerciseCreate newTBE) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        throw Exception('Token de autenticação não encontrado. Faça login novamente.');
      }

      final uri = Uri.parse('$_baseUrl/training_block_exercises/');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(newTBE.toJson()),
      );


      if (response.statusCode == 201) {
        final createdTBE = TrainingBlockExercise.fromJson(json.decode(response.body) as Map<String, dynamic>);
        notifyListeners();
        return createdTBE;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Falha ao adicionar exercício ao bloco de treino.');
      }
    } catch (e) {
      debugPrint('Erro ao adicionar exercício ao bloco: $e');
      throw Exception('Erro ao adicionar exercício ao bloco: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  Future<TrainingBlockExercise> updateTrainingBlockExercise(String tbeId, TrainingBlockExerciseUpdate updatedTBE) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        throw Exception('Token de autenticação não encontrado. Faça login novamente.');
      }
      final uri = Uri.parse('$_baseUrl/training_block_exercises/$tbeId');
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updatedTBE.toJson()),
      );

      if (response.statusCode == 200) {
        final returnedTBE = TrainingBlockExercise.fromJson(json.decode(response.body) as Map<String, dynamic>);
        final index = _blockExercises.indexWhere((element) => element.id == tbeId);
        if (index != -1) {
          final currentExercise = _blockExercises[index].exercise;
          final currentTrainigBlock = _blockExercises[index].trainingBlock;
          _blockExercises[index] = TrainingBlockExerciseWithDetails(
            id: returnedTBE.id,
            trainingBlockId: returnedTBE.trainingBlockId,
            exerciseId: returnedTBE.exerciseId,
            orderInBlock: returnedTBE.orderInBlock,
            trainingBlock: currentTrainigBlock,
            createdAt: returnedTBE.createdAt,
            updatedAt: returnedTBE.updatedAt,
            exercise: currentExercise,
          );
          _blockExercises.sort((a, b) => a.orderInBlock.compareTo(b.orderInBlock));
        }
        notifyListeners();
        return returnedTBE;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Falha ao atualizar exercício no bloco de treino.');
      }
    } catch (e) {
      debugPrint('Erro ao atualizar exercício no bloco: $e');
      throw Exception('Erro ao atualizar exercício no bloco: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  Future<void> deleteTrainingBlockExercise(String tbeId) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        throw Exception('Token de autenticação não encontrado. Faça login novamente.');
      }
      final uri = Uri.parse('$_baseUrl/training_block_exercises/$tbeId');
      final response = await http.delete(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 204) {
        _blockExercises.removeWhere((tbe) => tbe.id == tbeId);
        notifyListeners();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Falha ao remover exercício do bloco de treino.');
      }
    } catch (e) {
      debugPrint('Erro ao deletar exercício do bloco: $e');
      throw Exception('Erro ao deletar exercício do bloco: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }
}