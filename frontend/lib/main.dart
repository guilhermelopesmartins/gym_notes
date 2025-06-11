// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importe o Provider

import 'package:gym_notes/services/auth_service.dart';
import 'package:gym_notes/screens/auth/login_screen.dart';
import 'package:gym_notes/screens/home_screen.dart'; // Tela principal após o login
import 'package:gym_notes/screens/auth/register_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Garante que o Flutter Binding está inicializado

  // Carrega o token inicialmente para verificar o estado do login
  final authService = AuthService();
  await authService.loadToken(); // Carrega o token existente se houver

  runApp(
    ChangeNotifierProvider(
      create: (context) => authService, // Fornece a instância do AuthService
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym Notes App',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Decide qual tela mostrar com base no token existente
      home: Consumer<AuthService>(
        builder: (context, auth, _) {
          if (auth.token != null && auth.currentUserId != null) {
            // Se houver token, tente obter os detalhes do usuário para validar
            // ou vá direto para a Home. Para simplificar, vamos direto para Home aqui.
            // Uma verificação de token mais robusta pode ser feita na Home ou Splash.
            return HomeScreen();
          } else {
            return LoginScreen();
          }
        },
      ),
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/register': (context) => RegisterScreen(), // Adicionaremos depois
      },
    );
  }
}