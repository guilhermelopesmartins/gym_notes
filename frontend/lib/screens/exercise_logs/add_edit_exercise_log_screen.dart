import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; 
import 'package:gym_notes/models/exercise_log.dart'; 
import 'package:gym_notes/services/exercise_log_service.dart'; 
import 'package:gym_notes/services/auth_service.dart';

class AddEditExerciseLogScreen extends StatefulWidget {
  final String trainingBlockId;
  final String exerciseId;
  final ExerciseLog? exerciseLog; 

  const AddEditExerciseLogScreen({
    super.key,
    required this.trainingBlockId,
    required this.exerciseId,
    this.exerciseLog,
  });

  @override
  State<AddEditExerciseLogScreen> createState() => _AddEditExerciseLogScreenState();
}

class _AddEditExerciseLogScreenState extends State<AddEditExerciseLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  final List<TextEditingController> _setControllers = [];
  final List<TextEditingController> _repsControllers = [];
  final List<TextEditingController> _weightControllers = [];
  final List<TextEditingController> _unitControllers = [];
  final List<TextEditingController> _rpeControllers = [];
  final List<TextEditingController> _setNotesControllers = [];

  bool get _isEditing => widget.exerciseLog != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _notesController.text = widget.exerciseLog!.notes ?? '';
      _selectedDate = widget.exerciseLog!.logDate;
      
      for (var setData in widget.exerciseLog!.setsRepsData) {
        _setControllers.add(TextEditingController(text: setData.set.toString()));
        _repsControllers.add(TextEditingController(text: setData.reps.toString()));
        _weightControllers.add(TextEditingController(text: setData.weight.toString()));
        _unitControllers.add(TextEditingController(text: setData.unit ?? 'kg'));
        _rpeControllers.add(TextEditingController(text: setData.rpe?.toString()));
        _setNotesControllers.add(TextEditingController(text: setData.notes ?? ''));
      }
    } else {
      _addSetField();
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    for (var controller in _setControllers) controller.dispose();
    for (var controller in _repsControllers) controller.dispose();
    for (var controller in _weightControllers) controller.dispose();
    for (var controller in _unitControllers) controller.dispose();
    for (var controller in _rpeControllers) controller.dispose();
    for (var controller in _setNotesControllers) controller.dispose();
    super.dispose();
  }

  void _addSetField() {
    setState(() {
      _setControllers.add(TextEditingController(text: (_setControllers.length + 1).toString()));
      _repsControllers.add(TextEditingController());
      _weightControllers.add(TextEditingController());
      _unitControllers.add(TextEditingController(text: 'kg')); 
      _rpeControllers.add(TextEditingController());
      _setNotesControllers.add(TextEditingController());
    });
  }

  void _removeSetField(int index) {
    setState(() {
      _setControllers[index].dispose();
      _repsControllers[index].dispose();
      _weightControllers[index].dispose();
      _unitControllers[index].dispose();
      _rpeControllers[index].dispose();
      _setNotesControllers[index].dispose();

      _setControllers.removeAt(index);
      _repsControllers.removeAt(index);
      _weightControllers.removeAt(index);
      _unitControllers.removeAt(index);
      _rpeControllers.removeAt(index);
      _setNotesControllers.removeAt(index);

      
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
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {

    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUserId = authService.currentUserId;
    
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro: Usuário não autenticado. Faça login novamente.")),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final exerciseLogService = Provider.of<ExerciseLogService>(context, listen: false);

      List<SetData> setsRepsDataList = [];
      for (int i = 0; i < _setControllers.length; i++) {
        final setNum = int.tryParse(_setControllers[i].text);
        final reps = int.tryParse(_repsControllers[i].text);
        final weight = double.tryParse(_weightControllers[i].text);
        final rpe = int.tryParse(_rpeControllers[i].text);
      
        if (setNum == null || reps == null || weight == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Por favor, preencha todos os campos obrigatórios (Set, Repetições, Peso) para o Set ${i + 1}.')),
            );
          }
          return;
        }

        setsRepsDataList.add(SetData(
          set: setNum,
          reps: reps,
          weight: weight,
          unit: _unitControllers[i].text.isEmpty ? 'kg' : _unitControllers[i].text,
          rpe: rpe,
          notes: _setNotesControllers[i].text.isEmpty ? null : _setNotesControllers[i].text,
        ));
      }

      try {
        if (_isEditing) {
          final updatedLog = ExerciseLogCreateUpdate(
            trainingBlockId: widget.trainingBlockId,
            exerciseId: widget.exerciseId,
            userId: currentUserId,
            logDate: _selectedDate,
            setsRepsData: setsRepsDataList, 
            notes: _notesController.text.isEmpty ? null : _notesController.text,
          );
          await exerciseLogService.updateExerciseLog(widget.exerciseLog!.id, updatedLog);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Log de exercício atualizado com sucesso!')),
            );
          }
        } else {
          final newLog = ExerciseLogCreateUpdate(
            trainingBlockId: widget.trainingBlockId,
            exerciseId: widget.exerciseId,
            userId: currentUserId,
            logDate: _selectedDate,
            setsRepsData: setsRepsDataList,
            notes: _notesController.text.isEmpty ? null : _notesController.text,
          );
          await exerciseLogService.createExerciseLog(newLog);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Log de exercício criado com sucesso!')),
            );
          }
        }
        if (mounted) {
          Navigator.pop(context, true); 
        }
      } catch (e) {
        debugPrint('Erro ao salvar log de exercício: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao salvar log: ${e.toString().replaceFirst('Exception: ', '')}')),
          );
        }
      }
    }
  }

  Widget _buildSetInputField(int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
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
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                ),
                if (_setControllers.length > 1) 
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () => _removeSetField(index),
                  ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _repsControllers[index],
                    decoration: const InputDecoration(
                      labelText: 'Repetições',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty || int.tryParse(value) == null) {
                        return 'Inválido';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _weightControllers[index],
                    decoration: const InputDecoration(
                      labelText: 'Peso',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty || double.tryParse(value) == null) {
                        return 'Inválido';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: TextFormField(
                    controller: _unitControllers[index],
                    decoration: const InputDecoration(
                      labelText: 'Unid.',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.text,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _rpeControllers[index],
                    decoration: const InputDecoration(
                      labelText: 'RPE (1-10)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final rpe = int.tryParse(value);
                        if (rpe == null || rpe < 1 || rpe > 10) {
                          return 'Inválido';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _setNotesControllers[index],
                    decoration: const InputDecoration(
                      labelText: 'Notas do Set (Opcional)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.text,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Log de Exercício' : 'Registrar Log de Exercício'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[            
              ListTile(
                title: Text(
                  'Data: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16.0),              
              Expanded(
                child: ListView.builder(
                  itemCount: _setControllers.length,
                  itemBuilder: (context, index) {
                    return _buildSetInputField(index);
                  },
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addSetField,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar Set'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40), 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notas Gerais do Log (Opcional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.multiline,
                maxLines: 3,
              ),
              const SizedBox(height: 24.0),              
              SizedBox(
                width: double.infinity, 
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                  ),
                  child: Text(_isEditing ? 'Atualizar Log' : 'Salvar Log'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
