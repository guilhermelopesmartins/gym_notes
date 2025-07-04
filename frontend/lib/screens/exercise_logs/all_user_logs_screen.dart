// lib/screens/exercise_logs/all_user_logs_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:gym_notes/models/exercise_log.dart';
import 'package:gym_notes/services/exercise_log_service.dart';

class AllUserLogsScreen extends StatefulWidget {
  const AllUserLogsScreen({Key? key}) : super(key: key);

  @override
  State<AllUserLogsScreen> createState() => _AllUserLogsScreenState();
}

class _AllUserLogsScreenState extends State<AllUserLogsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExerciseLogService>(context, listen: false).fetchExerciseLogs(); // Sem parâmetros para todos os logs
    });
  }

  // Função para agrupar logs por data (reutilizável)
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
        title: const Text('Todos os Meus Logs de Treino'),
      ),
      body: Consumer<ExerciseLogService>(
        builder: (context, exerciseLogService, child) {
          final allLogs = exerciseLogService.exerciseLogs;

          if (allLogs.isEmpty) {
            return const Center(child: Text('Nenhum log de treino encontrado.'));
          }

          final groupedLogs = _groupLogsByDate(allLogs);

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
                              // Se você tem ExerciseLogWithDetails, pode usar:
                              // Text('Exercício: ${log.exercise?.name ?? 'Desconhecido'}'),
                              // Text('Bloco: ${log.trainingBlock?.name ?? 'Desconhecido'}'),
                              Text('Exercício ID: ${log.exerciseId.substring(0, 8)}...'),
                              Text('Bloco ID: ${log.trainingBlockId.substring(0, 8)}...'),
                              Text('Notas do Log: ${log.notes ?? 'N/A'}'),
                              const Text('Sets:'),
                              ...log.setsRepsData.map((set) =>
                                Text('  Set ${set.set}: ${set.reps} reps @ ${set.weight}${set.unit ?? ''} (RPE: ${set.rpe ?? 'N/A'}) - ${set.notes ?? 'N/A'}')
                              ).toList(),
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