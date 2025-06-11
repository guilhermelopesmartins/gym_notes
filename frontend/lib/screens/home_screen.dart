// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym_notes/services/auth_service.dart';
import 'package:gym_notes/screens/auth/login_screen.dart'; // Para redirecionar no logout

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _welcomeMessage = 'Bem-vindo!';

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Tenta buscar os dados do usuário ao iniciar a tela
  }

  Future<void> _fetchUserData() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = await authService.getMe(); // Chama o getMe para obter dados do usuário
      if (user != null) {
        setState(() {
          _welcomeMessage = 'Bem-vindo, ${user.username}!';
        });
      }
    } catch (e) {
      print('Erro ao carregar dados do usuário na Home: $e');
      // Se o token estiver expirado, getMe já fará o logout e o app será redirecionado
      // ou mostre uma mensagem de erro.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível carregar seu perfil. Por favor, faça login novamente.')),
      );
      Navigator.of(context).pushReplacementNamed('/login'); // Redireciona para o login
    }
  }

  Future<void> _logout() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.deleteToken();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gym Notes Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Sair',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _welcomeMessage,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _logout,
              child: Text('Fazer Logout'),
            ),
          ],
        ),
      ),
    );
  }
}