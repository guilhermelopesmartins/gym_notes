// lib/screens/exercise_logs/exercise_logs_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym_notes/models/exercise_log.dart';
import 'package:gym_notes/services/exercise_log_service.dart';
import 'package:gym_notes/screens/exercise_logs/exercise_log_form_screen.dart';

class ExerciseLogsListScreen extends StatefulWidget {
  final String trainingBlockId;
  final String exerciseId;
  final String exerciseName; 

  const ExerciseLogsListScreen({
    super.key,
    required this.trainingBlockId,
    required this.exerciseId,
    required this.exerciseName,
  });

  @override
  State<ExerciseLogsListScreen> createState() => _ExerciseLogsListScreenState();
}

class _ExerciseLogsListScreenState extends State<ExerciseLogsListScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchExerciseLogs();
  }

  Future<void> _fetchExerciseLogs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await Provider.of<ExerciseLogService>(context, listen: false).fetchExerciseLogs(
        trainingBlockId: widget.trainingBlockId,
        exerciseId: widget.exerciseId,
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar logs: ${e.toString().replaceFirst('Exception: ', '')}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmAndDeleteLog(ExerciseLog log) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: const Text('Tem certeza que deseja excluir este registro de treino?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        setState(() {
          _isLoading = true; 
        });
        await Provider.of<ExerciseLogService>(context, listen: false).deleteExerciseLog(log.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro de treino excluído com sucesso!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir registro: ${e.toString().replaceFirst('Exception: ', '')}')),
        );
      } finally {
        setState(() {
          _isLoading = false; 
        });
      }
    }
  }

  void _editExerciseLog(ExerciseLog log) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExerciseLogFormScreen(
          trainingBlockId: log.trainingBlockId,
          exerciseId: log.exerciseId,
          exerciseName: widget.exerciseName,
          exerciseLog: log,
        ),
      ),
    );
    if (result == true) {
      _fetchExerciseLogs(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logs de ${widget.exerciseName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchExerciseLogs,
            tooltip: 'Atualizar Logs',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 40),
                        const SizedBox(height: 10),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _fetchExerciseLogs,
                          child: const Text('Tentar Novamente'),
                        ),
                      ],
                    ),
                  ),
                )
              : Consumer<ExerciseLogService>(
                  builder: (context, exerciseLogService, child) {
                    final logs = exerciseLogService.exerciseLogs.where((log) =>
                        log.trainingBlockId == widget.trainingBlockId &&
                        log.exerciseId == widget.exerciseId).toList();                   

                    if (logs.isEmpty) {
                      return Center(
                        child: Text(
                          'Nenhum registro encontrado para ${widget.exerciseName} neste bloco.',
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    
                    final Map<DateTime, List<ExerciseLog>> logsByDate = {};
                    for (var log in logs) {
                      final date = DateTime(log.logDate.year, log.logDate.month, log.logDate.day); 
                      logsByDate.putIfAbsent(date, () => []).add(log);
                    }

                    final sortedDates = logsByDate.keys.toList()
                      ..sort((a, b) => b.compareTo(a)); 

                    return ListView.builder(
                      itemCount: sortedDates.length,
                      itemBuilder: (context, dateIndex) {
                        final date = sortedDates[dateIndex];
                        final logsForDate = logsByDate[date]!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Text(
                                '${date.day}/${date.month}/${date.year}',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: logsForDate.length,
                              itemBuilder: (context, logIndex) {
                                final log = logsForDate[logIndex];
                                return ExerciseLogCard(
                                  exerciseLog: log,
                                  onEdit: () => _editExerciseLog(log),
                                  onDelete: () => _confirmAndDeleteLog(log),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ExerciseLogFormScreen(
                trainingBlockId: widget.trainingBlockId,
                exerciseId: widget.exerciseId,
                exerciseName: widget.exerciseName,
              ),
            ),
          ).then((value) {
            if (value == true) {
              _fetchExerciseLogs(); 
            }
          });
        },
        child: const Icon(Icons.add),
        tooltip: 'Registrar novo treino',
      ),
    );
  }
}

class ExerciseLogCard extends StatelessWidget {
  final ExerciseLog exerciseLog;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ExerciseLogCard({
    super.key,
    required this.exerciseLog,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(                  
                  'Treino de ${exerciseLog.logDate.day}/${exerciseLog.logDate.month}/${exerciseLog.logDate.year}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                      onPressed: onEdit,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (exerciseLog.setsRepsData.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: exerciseLog.setsRepsData.map((setData) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Text(
                      'Set ${setData.set}: ${setData.reps} reps @ ${setData.weight} ${setData.unit ?? ''} ${setData.rpe != null ? '(RPE ${setData.rpe})' : ''}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
              ),
            if (exerciseLog.notes != null && exerciseLog.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Notas: ${exerciseLog.notes!}',
                style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}