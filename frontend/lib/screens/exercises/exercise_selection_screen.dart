// lib/screens/exercises/exercise_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym_notes/models/exercise.dart';
import 'package:gym_notes/services/exercise_service.dart';

class ExerciseSelectionScreen extends StatefulWidget {
  const ExerciseSelectionScreen({super.key});

  @override
  State<ExerciseSelectionScreen> createState() => _ExerciseSelectionScreenState();
}

class _ExerciseSelectionScreenState extends State<ExerciseSelectionScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await Provider.of<ExerciseService>(context, listen: false).fetchExercises();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar exercícios: ${e.toString().replaceFirst('Exception: ', '')}')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecionar Exercício'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Erro: $_errorMessage'))
              : Consumer<ExerciseService>(
                  builder: (context, exerciseService, child) {
                    if (exerciseService.exercises.isEmpty) {
                      return const Center(
                        child: Text('Nenhum exercício disponível. Crie um primeiro!'),
                      );
                    }
                    return ListView.builder(
                      itemCount: exerciseService.exercises.length,
                      itemBuilder: (context, index) {
                        final exercise = exerciseService.exercises[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                          child: ListTile(
                            title: Text(exercise.name),
                            subtitle: Text(exercise.category),
                            onTap: () {
                              // Retorna o ID do exercício selecionado para a tela anterior
                              Navigator.pop(context, exercise.id);
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}