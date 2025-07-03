// lib/screens/training_blocks/training_blocks_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym_notes/services/training_block_service.dart';
import 'package:gym_notes/models/training_block.dart';
import 'package:gym_notes/screens/training_blocks/training_block_form_screen.dart';
import 'package:gym_notes/services/auth_service.dart';
import 'package:gym_notes/screens/auth/login_screen.dart';
import 'package:gym_notes/screens/training_blocks/training_block_detail_screen.dart';

class TrainingBlocksListScreen extends StatefulWidget {
  const TrainingBlocksListScreen({super.key});

  @override
  State<TrainingBlocksListScreen> createState() => _TrainingBlocksListScreenState();
}
enum MenuOption { refresh, logout }
class _TrainingBlocksListScreenState extends State<TrainingBlocksListScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchTrainingBlocks();
    });
  }

  Future<void> _fetchTrainingBlocks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await Provider.of<TrainingBlockService>(context, listen: false).fetchTrainingBlocks();
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar blocos de treino: ${e.toString().replaceFirst('Exception: ', '')}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Método para confirmar e deletar um bloco de treino
  Future<void> _confirmAndDeleteBlock(String blockId) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: const Text('Tem certeza que deseja excluir este bloco de treino?'),
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
        await Provider.of<TrainingBlockService>(context, listen: false).deleteTrainingBlock(blockId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bloco de treino excluído com sucesso!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir bloco: ${e.toString().replaceFirst('Exception: ', '')}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _confirmAndLogout() async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Logout'),
          content: const Text('Tem certeza que deseja sair da sua conta?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await Provider.of<AuthService>(context, listen: false).logout();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logout realizado com sucesso!')),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao fazer logout: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Blocos de Treino'),
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<MenuOption>(
            icon: const Icon(Icons.settings),
            onSelected: (MenuOption result) {
              if (result == MenuOption.refresh) {
                _fetchTrainingBlocks();
              } else if (result == MenuOption.logout) {
                _confirmAndLogout();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<MenuOption>>[
              const PopupMenuItem<MenuOption>(
                value: MenuOption.refresh,
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: Colors.blueGrey),
                    SizedBox(width: 8),
                    Text('Atualizar'),
                  ],
                ),
              ),
              const PopupMenuItem<MenuOption>(
                value: MenuOption.logout,
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Sair'),
                  ],
                ),
              ),
            ],
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
                        Icon(Icons.error_outline, color: Colors.red, size: 40),
                        SizedBox(height: 10),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _fetchTrainingBlocks,
                          child: const Text('Tentar Novamente'),
                        ),
                      ],
                    ),
                  ),
                )
              : Consumer<TrainingBlockService>(
                  builder: (context, trainingBlockService, child) {
                    final trainingBlocks = trainingBlockService.trainingBlocks;
                    if (trainingBlocks.isEmpty) {
                      return const Center(
                        child: Text(
                          'Nenhum bloco de treino encontrado. Crie um novo!',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: trainingBlocks.length,
                      itemBuilder: (context, index) {
                        final block = trainingBlocks[index];
                        return TrainingBlockCard(
                          block: block,
                          onEdit: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => TrainingBlockFormScreen(block: block),
                              ),
                            ).then((value) {
                              if (value == true) {
                                _fetchTrainingBlocks();
                              }
                            });
                          },
                          onDelete: () => _confirmAndDeleteBlock(block.id),
                        );
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TrainingBlockFormScreen(),
            ),
          ).then((value) {
            if (value == true) {
              _fetchTrainingBlocks();
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Widget para exibir um único bloco de treino como um card
class TrainingBlockCard extends StatelessWidget {
  final TrainingBlock block;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TrainingBlockCard({
    super.key,
    required this.block,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final Color cardColor = Color(int.parse(block.colorHex.replaceFirst('#', '0xFF')));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TrainingBlockDetailScreen(trainingBlock: block),
            ),
          ).then((value) {
            // TODO: Se a tela de detalhes tiver alguma edição que afete a lista,
            // você pode querer atualizar a lista aqui.
            // Por exemplo, se um exercício é adicionado/removido e isso altera a "prévia" do bloco.
            // Para mudanças no bloco em si (título/descrição), o `onEdit` já cuida.
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      block.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: cardColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: onEdit,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: onDelete,
                      ),
                    ],
                  ),
                ],
              ),
              if (block.description != null && block.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  block.description!,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Text(
                'Criado em: ${block.createdAt.day}/${block.createdAt.month}/${block.createdAt.year}',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                'Última atualização: ${block.updatedAt.day}/${block.updatedAt.month}/${block.updatedAt.year}',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}