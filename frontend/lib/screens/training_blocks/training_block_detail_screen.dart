// lib/screens/training_blocks/training_block_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym_notes/models/training_block.dart';
import 'package:gym_notes/models/exercise.dart'; // Importa o modelo de Exercício
import 'package:gym_notes/services/training_block_service.dart'; // Para acessar o bloco, se necessário, ou atualizar a lista
import 'package:gym_notes/screens/training_blocks/training_block_form_screen.dart'; // Para editar
import 'package:gym_notes/screens/exercises/exercise_form_screen.dart'; // Ainda vamos criar esta tela (para adicionar/editar exercícios)
import 'package:gym_notes/screens/exercise_logs/exercise_log_form_screen.dart';
import 'package:gym_notes/screens/exercise_logs/exercise_logs_list_screen.dart';


class TrainingBlockDetailScreen extends StatefulWidget {
  final TrainingBlock block;

  const TrainingBlockDetailScreen({super.key, required this.block});

  @override
  State<TrainingBlockDetailScreen> createState() => _TrainingBlockDetailScreenState();
}

class _TrainingBlockDetailScreenState extends State<TrainingBlockDetailScreen> {
  // Poderíamos carregar exercícios aqui se tivéssemos um ExerciseService
  // Por enquanto, vamos mockar alguns exercícios para demonstração.
  List<Exercise> _exercisesInBlock = [];
  bool _isLoadingExercises = true;
  String? _exercisesErrorMessage;

  @override
  void initState() {
    super.initState();
    _fetchExercisesForBlock();
  }

  Future<void> _fetchExercisesForBlock() async {
    setState(() {
      _isLoadingExercises = true;
      _exercisesErrorMessage = null;
    });
    try {
      // TODO: Use o endpoint do backend /exercises/by_training_block/{id}
      // e um método correspondente no ExerciseService.
      // Por agora, vou simular um fetch com mock data.
      // Exemplo real:
      // await Provider.of<ExerciseService>(context, listen: false).fetchExercisesByTrainingBlock(widget.block.id);
      // _exercisesInBlock = Provider.of<ExerciseService>(context, listen: false).exercises; // Se o serviço gerenciar o estado da lista

      // Simula o fetch e mocka alguns dados de DEFINIÇÃO de exercícios
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _exercisesInBlock = [
          Exercise(
            id: 'ex1_mock_id',
            name: 'Supino Reto',
            description: 'Exercício fundamental para peito.',
            muscleGroup: 'Peito',
            equipmentType: 'Barra',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Exercise(
            id: 'ex2_mock_id',
            name: 'Remada Curvada',
            description: 'Exercício para as costas.',
            muscleGroup: 'Costas',
            equipmentType: 'Barra',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Exercise(
            id: 'ex3_mock_id',
            name: 'Agachamento Livre',
            description: 'Exercício composto para pernas e glúteos.',
            muscleGroup: 'Pernas',
            equipmentType: 'Barra',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
      });
    } catch (e) {
      setState(() {
        _exercisesErrorMessage = 'Erro ao carregar exercícios: ${e.toString().replaceFirst('Exception: ', '')}';
      });
    } finally {
      setState(() {
        _isLoadingExercises = false;
      });
    }
  }

  // Método para editar o bloco de treino
  void _editTrainingBlock() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TrainingBlockFormScreen(block: widget.block),
      ),
    );
    // Após a edição, pode ser necessário recarregar os detalhes do bloco
    // se eles forem dinâmicos e dependessem do widget.block inicial, ou
    // se o provider de TrainingBlockService já notifica.
    // Para simplificar, assumimos que o provider cuida.
  }


  // Método para adicionar um novo exercício
  void _addNewExerciseDefinition() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExerciseFormScreen(), // Não passa o bloco_id aqui
      ),
    );
    if (result == true) {
      // Se uma nova DEFINIÇÃO foi criada, você pode querer recarregar a lista
      // ou ter uma lógica para associar o novo exercício ao bloco.
      // No seu backend, essa associação é via TrainingBlockExercise.
      // Por enquanto, vamos apenas recarregar as definições, mas a associação
      // ao bloco é uma etapa extra (que viria de um form de "adicionar exercício ao bloco").
      _fetchExercisesForBlock(); // Recarrega as definições de exercícios
    }
  }

  void _addExerciseLog(Exercise exercise) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExerciseLogFormScreen(
          trainingBlockId: widget.block.id,
          exerciseId: exercise.id,
          exerciseName: exercise.name, // Passa o nome para exibir no form
        ),
      ),
    );
    if (result == true) {
      // Se um novo log foi adicionado, pode-se querer atualizar algo,
      // como uma prévia do último treino na ExerciseDefinitionCard.
      // Por agora, apenas um SnackBar.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Novo log para ${exercise.name} registrado!')),
      );
    }
  }

  // Método para ver todos os logs de um exercício específico
  void _viewExerciseLogs(Exercise exercise) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExerciseLogsListScreen(
          trainingBlockId: widget.block.id,
          exerciseId: exercise.id,
          exerciseName: exercise.name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color appBarColor = Color(int.parse(widget.block.colorHex.replaceFirst('#', '0xFF')));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.block.title),
        backgroundColor: appBarColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editTrainingBlock,
            tooltip: 'Editar Bloco',
          ),
          // Se você quiser um botão para adicionar uma NOVA DEFINIÇÃO de exercício globalmente:
          // IconButton(
          //   icon: const Icon(Icons.library_add),
          //   onPressed: _addNewExerciseDefinition,
          //   tooltip: 'Adicionar Nova Definição de Exercício',
          // ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.block.title,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: appBarColor),
            ),
            const SizedBox(height: 8),
            if (widget.block.description != null && widget.block.description!.isNotEmpty) ...[
              Text(
                widget.block.description!,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 16),
            ],
            Divider(color: Colors.grey[300]),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Exercícios neste Bloco:', // Mudei o texto
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Aqui você precisará de uma tela para "Adicionar Exercício Existente ao Bloco"
                    // ou "Criar Novo Exercício E Adicionar ao Bloco".
                    // Por enquanto, vamos para a tela de criar NOVA DEFINIÇÃO de exercício.
                    _addNewExerciseDefinition(); // Chamando a função existente, mas pense no fluxo.
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Funcionalidade de Adicionar Exercício ao Bloco (TODO)')),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar Exercício'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _isLoadingExercises
                ? const Center(child: CircularProgressIndicator())
                : _exercisesErrorMessage != null
                    ? Center(child: Text(_exercisesErrorMessage!, style: TextStyle(color: Colors.red)))
                    : _exercisesInBlock.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                'Nenhum exercício associado a este bloco. Adicione um!',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _exercisesInBlock.length,
                            itemBuilder: (context, index) {
                              final exercise = _exercisesInBlock[index];
                              return ExerciseDefinitionCard(
                                exercise: exercise,
                                // TODO: Implementar lógica de exclusão/edição da ASSOCIAÇÃO do exercício ao bloco,
                                // e não da definição do exercício em si (a menos que a intenção seja essa).
                                // Por enquanto, essas callbacks são apenas placeholders.
                                onEditDefinition: () async {
                                  final result = await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => ExerciseFormScreen(exercise: exercise),
                                    ),
                                  );
                                  if (result == true) {
                                    _fetchExercisesForBlock(); // Recarrega se a definição mudou
                                  }
                                },
                                onDeleteAssociation: () {
                                  // TODO: Confirmar e remover a ASSOCIAÇÃO do exercício a este bloco
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Remover ${exercise.name} deste bloco (TODO)')),
                                  );
                                },
                                onViewLogs: () => _viewExerciseLogs(exercise),
                                onAddLog: () => _addExerciseLog(exercise),
                              );
                            },
                          ),
            const SizedBox(height: 20),
            // Informações adicionais do bloco (criado em, atualizado em)
            Align(
              alignment: Alignment.centerRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Criado em: ${widget.block.createdAt.day}/${widget.block.createdAt.month}/${widget.block.createdAt.year}',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    'Última atualização: ${widget.block.updatedAt.day}/${widget.block.updatedAt.month}/${widget.block.updatedAt.year}',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget para exibir um único exercício como um card
class ExerciseDefinitionCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onEditDefinition; // Para editar a DEFINIÇÃO do exercício
  final VoidCallback onDeleteAssociation; // Para remover o exercício DESTE bloco
  final VoidCallback onViewLogs; // Para ver logs deste exercício neste bloco
  final VoidCallback onAddLog; // Para adicionar um novo log para este exercício

  const ExerciseDefinitionCard({
    super.key,
    required this.exercise,
    required this.onEditDefinition,
    required this.onDeleteAssociation,
    required this.onViewLogs,
    required this.onAddLog,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onViewLogs, // Clicar no card pode levar para os logs
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (exercise.muscleGroup != null && exercise.muscleGroup!.isNotEmpty)
                          Text(
                            'Grupo Muscular: ${exercise.muscleGroup!}',
                            style: const TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        if (exercise.equipmentType != null && exercise.equipmentType!.isNotEmpty)
                          Text(
                            'Equipamento: ${exercise.equipmentType!}',
                            style: const TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit_definition') {
                        onEditDefinition();
                      } else if (value == 'delete_association') {
                        onDeleteAssociation();
                      } else if (value == 'view_logs') {
                        onViewLogs();
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'edit_definition',
                        child: Row(
                          children: [Icon(Icons.edit, color: Colors.blue), SizedBox(width: 8), Text('Editar Definição')],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete_association',
                        child: Row(
                          children: [Icon(Icons.remove_circle_outline, color: Colors.orange), SizedBox(width: 8), Text('Remover do Bloco')],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'view_logs',
                        child: Row(
                          children: [Icon(Icons.list_alt, color: Colors.green), SizedBox(width: 8), Text('Ver Logs')],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (exercise.description != null && exercise.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  exercise.description!,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: onAddLog,
                  icon: const Icon(Icons.add),
                  label: const Text('Registrar Treino'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}