// lib/screens/training_blocks/training_block_form_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym_notes/services/training_block_service.dart';
import 'package:gym_notes/models/training_block.dart';

class TrainingBlockFormScreen extends StatefulWidget {
  final TrainingBlock? block; 

  const TrainingBlockFormScreen({super.key, this.block});

  @override
  State<TrainingBlockFormScreen> createState() => _TrainingBlockFormScreenState();
}

class _TrainingBlockFormScreenState extends State<TrainingBlockFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedColorHex = '#FFFFFF'; 
  bool _isLoading = false;
  
  final List<String> _availableColors = [
    '#FFFFFF',
    '#FFC107',
    '#4CAF50',
    '#2196F3',
    '#9C27B0',
    '#FF5722',
    '#E91E63',
    '#607D8B',
  ];

  @override
  void initState() {
    super.initState();    
    if (widget.block != null) {
      _titleController.text = widget.block!.title;
      _descriptionController.text = widget.block!.description ?? '';
      _selectedColorHex = widget.block!.colorHex;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveBlock() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final trainingBlockService = Provider.of<TrainingBlockService>(context, listen: false);

    try {
      if (widget.block == null) {
        final newBlock = TrainingBlockCreate(
          title: _titleController.text,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
          colorHex: _selectedColorHex,
        );
        await trainingBlockService.createTrainingBlock(newBlock);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bloco de treino criado com sucesso!')),
        );
      } else {
        final updatedBlock = TrainingBlockUpdate(
          title: _titleController.text,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
          colorHex: _selectedColorHex,
        );
        await trainingBlockService.updateTrainingBlock(widget.block!.id, updatedBlock);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bloco de treino atualizado com sucesso!')),
        );
      }
      Navigator.of(context).pop(true); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar bloco: ${e.toString().replaceFirst('Exception: ', '')}')),
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
        title: Text(widget.block == null ? 'Criar Bloco de Treino' : 'Editar Bloco de Treino'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título do Bloco',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um título.';
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
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 16),
              InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Cor do Bloco',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.color_lens),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedColorHex,
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedColorHex = newValue;
                        });
                      }
                    },
                    items: _availableColors.map<DropdownMenuItem<String>>((String hexColor) {
                      return DropdownMenuItem<String>(
                        value: hexColor,
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              color: Color(int.parse(hexColor.replaceFirst('#', '0xFF'))),
                              margin: const EdgeInsets.only(right: 8),
                            ),
                            Text(hexColor),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveBlock,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        widget.block == null ? 'Criar Bloco' : 'Salvar Alterações',
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