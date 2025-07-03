// lib/screens/exercises/exercise_form_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym_notes/models/exercise.dart';
import 'package:gym_notes/services/exercise_service.dart';

class ExerciseFormScreen extends StatefulWidget {
  final Exercise? exercise; // Opcional: Se for para editar um exercício existente

  const ExerciseFormScreen({super.key, this.exercise});

  @override
  State<ExerciseFormScreen> createState() => _ExerciseFormScreenState();
}

class _ExerciseFormScreenState extends State<ExerciseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController(); // NOVO

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.exercise != null) {
      _nameController.text = widget.exercise!.name;
      _descriptionController.text = widget.exercise!.description ?? '';
      _categoryController.text = widget.exercise!.category ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _saveExercise() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final exerciseService = Provider.of<ExerciseService>(context, listen: false);

    try {
      if (widget.exercise == null) {
        // Lógica para CRIAR uma nova DEFINIÇÃO de exercício
        final newExercise = ExerciseCreate(
          name: _nameController.text,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
          category: _categoryController.text.isEmpty ? null : _categoryController.text,
        );
        await exerciseService.createExercise(newExercise);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Definição de Exercício criada com sucesso!')),
        );
      } else {
        // Lógica para ATUALIZAR uma DEFINIÇÃO de exercício existente
        final updatedExercise = ExerciseUpdate(
          name: _nameController.text, // Assume que nome é sempre preenchido, mas verifique validação
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
          category: _categoryController.text.isEmpty ? null : _categoryController.text,
        );
        await exerciseService.updateExercise(widget.exercise!.id, updatedExercise);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Definição de Exercício atualizada com sucesso!')),
        );
      }
      Navigator.of(context).pop(true); // Retorna true para indicar sucesso e recarregar lista
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar definição de exercício: ${e.toString().replaceFirst('Exception: ', '')}')),
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
        title: Text(widget.exercise == null ? 'Adicionar Exercício (Definição)' : 'Editar Exercício (Definição)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Exercício',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.fitness_center),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome do exercício.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descrição (Opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Grupo Muscular (Opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.accessibility_new),
                ),
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveExercise,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        widget.exercise == null ? 'Adicionar Definição' : 'Salvar Alterações',
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