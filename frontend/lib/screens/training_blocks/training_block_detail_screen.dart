// lib/screens/training_blocks/training_block_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym_notes/models/training_block.dart'; // Importe seu modelo TrainingBlock
import 'package:gym_notes/models/training_block_exercise.dart'; // Importe o modelo TrainingBlockExercise
import 'package:gym_notes/services/training_block_exercise_service.dart'; // Importe o novo serviço
import 'package:gym_notes/screens/exercise_logs/add_edit_exercise_log_screen.dart'; // Para adicionar logs
import 'package:gym_notes/screens/exercises/exercise_selection_screen.dart'; // Para selecionar exercícios para adicionar
import 'package:gym_notes/services/exercise_log_service.dart';

class TrainingBlockDetailScreen extends StatefulWidget {
  final TrainingBlock trainingBlock;

  const TrainingBlockDetailScreen({super.key, required this.trainingBlock});

  @override
  State<TrainingBlockDetailScreen> createState() => _TrainingBlockDetailScreenState();
}

class _TrainingBlockDetailScreenState extends State<TrainingBlockDetailScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Carrega os exercícios do bloco quando a tela é inicializada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTrainingBlockExercises();
    });
  }

  Future<void> _loadTrainingBlockExercises() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await Provider.of<TrainingBlockExerciseService>(context, listen: false)
          .fetchTrainingBlockExercises(widget.trainingBlock.id);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      if (mounted) { // Verifica se o widget ainda está montado antes de mostrar o SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar exercícios do bloco: ${e.toString().replaceFirst('Exception: ', '')}')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addExerciseToBlock(String exerciseId) async {
    try {
      final tbeCreate = TrainingBlockExerciseCreate(
        trainingBlockId: widget.trainingBlock.id,
        exerciseId: exerciseId,
        orderInBlock: 0, // Defina uma ordem padrão ou implemente lógica para determinar a próxima ordem
        notes: null,
      );
      await Provider.of<TrainingBlockExerciseService>(context, listen: false)
          .addExerciseToTrainingBlock(tbeCreate);
      await _loadTrainingBlockExercises(); // Recarrega a lista para mostrar o novo exercício
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao adicionar exercício: ${e.toString().replaceFirst('Exception: ', '')}')),
        );
      }
    }
  }

  Future<void> _deleteTrainingBlockExercise(String tbeId) async {
    try {
      await Provider.of<TrainingBlockExerciseService>(context, listen: false)
          .deleteTrainingBlockExercise(tbeId);
      // A lista será atualizada automaticamente via notifyListeners() do service
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exercício removido do bloco com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao remover exercício: ${e.toString().replaceFirst('Exception: ', '')}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final exerciseLogService = Provider.of<ExerciseLogService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.trainingBlock.title),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Erro: $_errorMessage'))
              : Consumer<TrainingBlockExerciseService>(
                  builder: (context, tbeService, child) {
                    if (tbeService.blockExercises.isEmpty) {
                      return const Center(
                          child: Text('Nenhum exercício adicionado a este bloco ainda.'));
                    }
                    return ListView.builder(
                      itemCount: tbeService.blockExercises.length,
                      itemBuilder: (context, index) {
                        final tbe = tbeService.blockExercises[index];
                        final exercise = tbe.exercise;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                          child: ListTile(
                            title: Text(
                              exercise?.name ?? 'Exercício Desconhecido',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Categoria: ${exercise?.category ?? 'N/A'}'),
                                Text('Ordem no Bloco: ${tbe.orderInBlock}')
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.add_task, color: Colors.blue),
                                  tooltip: 'Registrar Log',
                                  onPressed: () {
                                    // Navega para a tela de registro de log
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AddEditExerciseLogScreen(
                                          trainingBlockId: widget.trainingBlock.id,
                                          exerciseId: exercise?.id ?? '', // ID do Exercise
                                          // Você pode passar dados do TBE para pré-preencher o log
                                          // initialSetsReps: tbe.defaultSetsReps,
                                          // initialNotes: tbe.defaultNotes,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.history),
                                  onPressed: () {
                                    if (exercise != null) {
                                      // 1. Defina os IDs no serviço ANTES de navegar
                                        exerciseLogService.setContextualLogIds(
                                          trainingBlockId: widget.trainingBlock.id,
                                          exerciseId:exercise.id,
                                        );
                                      // 2. Navegue para a tela de logs específica
                                      Navigator.of(context).pushNamed('/exercise_logs_by_exercise');
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Exercício não encontrado para ver logs.')),
                                      );
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  tooltip: 'Remover do Bloco',
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Confirmar Remoção'),
                                        content: Text('Tem certeza que deseja remover "${exercise?.name ?? 'Exercício Desconhecido'}" deste bloco?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(ctx).pop(),
                                            child: const Text('Cancelar'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(ctx).pop();
                                              _deleteTrainingBlockExercise(tbe.id);
                                            },
                                            child: const Text('Remover'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                floatingActionButton:  FloatingActionButton(
                  child: const Icon(Icons.add),
                  tooltip: 'Adicionar Exercício ao Bloco',
                  onPressed: () async {
                    // Navega para uma tela de seleção de exercícios
                    final selectedExerciseId = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ExerciseSelectionScreen(), // Crie esta tela se ainda não tiver
                      ),
                    );
                    if (selectedExerciseId != null && selectedExerciseId is String) {
                      await _addExerciseToBlock(selectedExerciseId);
                    }
                  },
                ),
    );
  }
}