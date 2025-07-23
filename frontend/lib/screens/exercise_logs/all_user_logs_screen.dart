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
      Provider.of<ExerciseLogService>(context, listen: false).fetchExerciseLogs(detail: true); 
    });
  }

  Map<DateTime, List<ExerciseLogWithDetails>> _groupLogsByDate(List<ExerciseLogWithDetails> logs) {
    final Map<DateTime, List<ExerciseLogWithDetails>> groupedLogs = {};
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
          final allLogs = exerciseLogService.exerciseLogsWithDetail;

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
                              Text('Bloco: ${log.trainingBlock?.title}'),
                              Text('Notas: ${log.notes ?? 'N/A'}'),
                              Text('${log.exercise?.name}:'),
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