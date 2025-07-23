// lib/screens/exercise_logs/exercise_logs_by_exercise_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:gym_notes/models/exercise_log.dart';
import 'package:gym_notes/services/exercise_log_service.dart';

class ExerciseLogsByExerciseScreen extends StatefulWidget {

  const ExerciseLogsByExerciseScreen({Key? key}) : super(key: key);

  @override
  State<ExerciseLogsByExerciseScreen> createState() => _ExerciseLogsByExerciseScreenState();
}

class _ExerciseLogsByExerciseScreenState extends State<ExerciseLogsByExerciseScreen> {
  String? _currentTrainingBlockId;
  String? _currentExerciseId;

  @override
  void initState() {
    super.initState();    
    final exerciseLogService = Provider.of<ExerciseLogService>(context, listen: false);
    _currentTrainingBlockId = exerciseLogService.currentTrainingBlockId;
    _currentExerciseId = exerciseLogService.currentExerciseId;
    
    if (_currentTrainingBlockId != null && _currentExerciseId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        exerciseLogService.fetchExerciseLogs(
          trainingBlockId: _currentTrainingBlockId,
          exerciseId: _currentExerciseId,
        );
      });
    } else {      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro: IDs de bloco/exercício não encontrados.")),
        );
      });
    }
  }

  Map<DateTime, List<ExerciseLog>> _groupLogsByDate(List<ExerciseLog> logs) {
    final Map<DateTime, List<ExerciseLog>> groupedLogs = {};
    for (var log in logs) {
      final dateOnly = DateTime(log.logDate.year, log.logDate.month, log.logDate.day);
      if (!groupedLogs.containsKey(dateOnly)) {
        groupedLogs[dateOnly] = [];
      }
      groupedLogs[dateOnly]!.add(log);
    }
    final sortedDates = groupedLogs.keys.toList()..sort((a, b) => b.compareTo(a));
    return { for (var date in sortedDates) date : groupedLogs[date]! };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logs do Exercício'),
      ),
      body: Consumer<ExerciseLogService>( 
        builder: (context, exerciseLogService, child) {          
          final filteredLogs = exerciseLogService.exerciseLogs.where(
            (log) => log.trainingBlockId == _currentTrainingBlockId &&
                     log.exerciseId == _currentExerciseId
          ).toList();

          if (filteredLogs.isEmpty) {
            return const Center(child: Text('Nenhum log encontrado para este exercício neste bloco.'));
          }
          
          final groupedLogs = _groupLogsByDate(filteredLogs);

          return ListView.builder(
            itemCount: groupedLogs.length,
            itemBuilder: (context, index) {
              final date = groupedLogs.keys.elementAt(index);
              final logsForDate = groupedLogs[date]!;

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('dd/MM/yyyy').format(date),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const Divider(),
                      ...logsForDate.map((log) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Séries:'),
                              ...log.setsRepsData.map((set) =>
                                Text('  ${set.set}º Série: ${set.reps} reps @ ${set.weight}${set.unit ?? ''} (Dificuldade: ${set.rpe ?? 'N/A'}) - ${set.notes ?? 'N/A'}')
                              ).toList(),
                              log.notes != null ? Text('Notas: ${log.notes ?? 'N/A'}') : const SizedBox(height: 0.0),
                              const SizedBox(height: 8.0),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}