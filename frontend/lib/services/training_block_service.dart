// lib/services/training_block_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gym_notes/models/training_block.dart';
import 'package:gym_notes/models/user.dart';
import 'package:gym_notes/utils/constants.dart';
import 'package:gym_notes/services/auth_service.dart';

class TrainingBlockService extends ChangeNotifier {
  final String _baseUrl = Constants.BASE_URL;

  List<TrainingBlock> _trainingBlocks = [];
  List<TrainingBlock> get trainingBlocks => _trainingBlocks;
  
  // Método auxiliar para obter o token de autenticação
  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constants.TOKEN_KEY);
  }

  // --- Método para Criar um Novo Bloco de Treino ---
  Future<TrainingBlock> createTrainingBlock(TrainingBlockCreate newBlock) async {
    final token = await _getAccessToken();
    if (token == null) {
      throw Exception('Token de autenticação não encontrado. Faça login novamente.');
    }

    final uri = Uri.parse('$_baseUrl/training_blocks/');
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(newBlock.toJson()),
    );

  if (response.statusCode == 201) {
      final createdBlock = TrainingBlock.fromJson(jsonDecode(response.body));
      _trainingBlocks.add(createdBlock);
      notifyListeners();
      return createdBlock;
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['detail'] ?? 'Falha ao criar bloco de treino.');
    }
  }

  // --- Método para Listar Blocos de Treino ---
  Future<List<TrainingBlock>> fetchTrainingBlocks({int skip = 0, int limit = 100}) async {
    final token = await _getAccessToken();
    if (token == null) {
      throw Exception('Token de autenticação não encontrado. Faça login novamente.');
    }

    final uri = Uri.parse('$_baseUrl/training_blocks/?skip=$skip&limit=$limit');
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      _trainingBlocks = body.map((dynamic item) => TrainingBlock.fromJson(item)).toList();
      notifyListeners();
      return _trainingBlocks;
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['detail'] ?? 'Falha ao buscar blocos de treino.');
    }
  }

  // --- Método para Obter um Bloco de Treino por ID ---
  Future<TrainingBlock> getTrainingBlockById(String id) async {
    final token = await _getAccessToken();
    if (token == null) {
      throw Exception('Token de autenticação não encontrado. Faça login novamente.');
    }

    final uri = Uri.parse('$_baseUrl/training_blocks/$id');
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return TrainingBlock.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Bloco de treino não encontrado.');
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['detail'] ?? 'Falha ao buscar bloco de treino.');
    }
  }

  // --- Método para Atualizar um Bloco de Treino ---
  Future<TrainingBlock> updateTrainingBlock(String id, TrainingBlockUpdate updatedBlock) async {
    final token = await _getAccessToken();
    if (token == null) {
      throw Exception('Token de autenticação não encontrado. Faça login novamente.');
    }

    final uri = Uri.parse('$_baseUrl/training_blocks/$id');
    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(updatedBlock.toJson()),
    );

    if (response.statusCode == 200) {
      final updatedData = TrainingBlock.fromJson(jsonDecode(response.body));
      final index = _trainingBlocks.indexWhere((block) => block.id == id);
      if (index != -1) {
        _trainingBlocks[index] = updatedData;
        notifyListeners();
      }
      return updatedData;
    } else if (response.statusCode == 404) {
      throw Exception('Bloco de treino não encontrado.');
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['detail'] ?? 'Falha ao atualizar bloco de treino.');
    }
  }

  // --- Método para Deletar um Bloco de Treino ---
  Future<void> deleteTrainingBlock(String id) async {
    final token = await _getAccessToken();
    if (token == null) {
      throw Exception('Token de autenticação não encontrado. Faça login novamente.');
    }

    final uri = Uri.parse('$_baseUrl/training_blocks/$id');
    final response = await http.delete(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 204) {
      _trainingBlocks.removeWhere((block) => block.id == id);
      notifyListeners();
    } else if (response.statusCode == 404) {
      throw Exception('Bloco de treino não encontrado.');
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['detail'] ?? 'Falha ao deletar bloco de treino.');
    }
  }
}