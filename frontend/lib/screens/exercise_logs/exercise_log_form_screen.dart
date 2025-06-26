// lib/screens/exercise_logs/exercise_log_form_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym_notes/models/exercise_log.dart';
import 'package:gym_notes/services/exercise_log_service.dart';

class ExerciseLogFormScreen extends StatefulWidget {
  final String trainingBlockId;
  final String exerciseId;
  final String exerciseName; // Para exibir no AppBar
  final ExerciseLog? exerciseLog; // Opcional: para edição de um log existente

  const ExerciseLogFormScreen({
    super.key,
    required this.trainingBlockId,
    required this.exerciseId,
    required this.exerciseName,
    this.exerciseLog,
  });

  @override
  State<ExerciseLogFormScreen> createState() => _ExerciseLogFormScreenState();
}

class _ExerciseLogFormScreenState extends State<ExerciseLogFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  // Lista de controladores para os sets, dinâmicos
  final List<TextEditingController> _setControllers = [];
  final List<TextEditingController> _repsControllers = [];
  final List<TextEditingController> _weightControllers = [];
  final List<TextEditingController> _rpeControllers = [];
  final List<TextEditingController> _setNotesControllers = [];
  final List<String> _unitSelections = []; // 'kg' ou 'lbs'

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.exerciseLog != null) {
      // Modo de edição: preenche os campos
      _notesController.text = widget.exerciseLog!.notes ?? '';
      _selectedDate = widget.exerciseLog!.logDate;

      // Preenche os sets existentes
      for (var setData in widget.exerciseLog!.setsRepsData) {
        _setControllers.add(TextEditingController(text: setData.set.toString()));
        _repsControllers.add(TextEditingController(text: setData.reps.toString()));
        _weightControllers.add(TextEditingController(text: setData.weight.toString()));
        _rpeControllers.add(TextEditingController(text: setData.rpe?.toString() ?? ''));
        _setNotesControllers.add(TextEditingController(text: setData.notes ?? ''));
        _unitSelections.add(setData.unit ?? 'kg');
      }
    } else {
      // Modo de criação: adiciona um set inicial vazio
      _addSet();
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    for (var controller in _setControllers) controller.dispose();
    for (var controller in _repsControllers) controller.dispose();
    for (var controller in _weightControllers) controller.dispose();
    for (var controller in _rpeControllers) controller.dispose();
    for (var controller in _setNotesControllers) controller.dispose();
    super.dispose();
  }

  void _addSet() {
    setState(() {
      _setControllers.add(TextEditingController(text: (_setControllers.length + 1).toString()));
      _repsControllers.add(TextEditingController());
      _weightControllers.add(TextEditingController());
      _rpeControllers.add(TextEditingController());
      _setNotesControllers.add(TextEditingController());
      _unitSelections.add('kg'); // Padrão
    });
  }

  void _removeSet(int index) {
    setState(() {
      _setControllers[index].dispose();
      _repsControllers[index].dispose();
      _weightControllers[index].dispose();
      _rpeControllers[index].dispose();
      _setNotesControllers[index].dispose();

      _setControllers.removeAt(index);
      _repsControllers.removeAt(index);
      _weightControllers.removeAt(index);
      _rpeControllers.removeAt(index);
      _setNotesControllers.removeAt(index);
      _unitSelections.removeAt(index);

      // Reajusta os números dos sets
      for (int i = 0; i < _setControllers.length; i++) {
        _setControllers[i].text = (i + 1).toString();
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveExerciseLog() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Coleta os dados de sets
    final List<SetData> setsRepsData = [];
    for (int i = 0; i < _setControllers.length; i++) {
      if (_repsControllers[i].text.isNotEmpty && _weightControllers[i].text.isNotEmpty) {
        setsRepsData.add(
          SetData(
            set: int.parse(_setControllers[i].text),
            reps: int.parse(_repsControllers[i].text),
            weight: double.parse(_weightControllers[i].text),
            unit: _unitSelections[i],
            rpe: int.tryParse(_rpeControllers[i].text),
            notes: _setNotesControllers[i].text.isEmpty ? null : _setNotesControllers[i].text,
          ),
        );
      }
    }

    if (setsRepsData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, adicione pelo menos um set com repetições e peso.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final exerciseLogService = Provider.of<ExerciseLogService>(context, listen: false);

    try {
      final logData = ExerciseLogCreateUpdate(
        trainingBlockId: widget.trainingBlockId,
        exerciseId: widget.exerciseId,
        logDate: _selectedDate,
        setsRepsData: setsRepsData,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      if (widget.exerciseLog == null) {
        await exerciseLogService.createExerciseLog(logData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Log de exercício registrado com sucesso!')),
        );
      } else {
        await exerciseLogService.updateExerciseLog(widget.exerciseLog!.id, logData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Log de exercício atualizado com sucesso!')),
        );
      }
      Navigator.of(context).pop(true); // Retorna true para indicar sucesso e recarregar
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar log: ${e.toString().replaceFirst('Exception: ', '')}')),
      );
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
        title: Text(widget.exerciseLog == null
            ? 'Registrar Treino: ${widget.exerciseName}'
            : 'Editar Log: ${widget.exerciseName}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                title: Text(
                  'Data: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(fontSize: 16),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),
              const Text(
                'Sets e Repetições:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _setControllers.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Set ${index + 1}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              if (_setControllers.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                  onPressed: () => _removeSet(index),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _repsControllers[index],
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Repetições',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty || int.tryParse(value) == null) {
                                      return 'Req.';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: _weightControllers[index],
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Peso',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty || double.tryParse(value) == null) {
                                      return 'Req.';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              DropdownButton<String>(
                                value: _unitSelections[index],
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _unitSelections[index] = newValue;
                                    });
                                  }
                                },
                                items: <String>['kg', 'lbs']
                                    .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _rpeControllers[index],
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'RPE (Opcional, 1-10)',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                final rpe = int.tryParse(value);
                                if (rpe == null || rpe < 1 || rpe > 10) {
                                  return 'Entre 1 e 10.';
                                }
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _setNotesControllers[index],
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Notas do Set (Opcional)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _addSet,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Adicionar Set'),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Notas Gerais do Treino (Opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveExerciseLog,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        widget.exerciseLog == null ? 'Registrar Treino' : 'Salvar Alterações',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}