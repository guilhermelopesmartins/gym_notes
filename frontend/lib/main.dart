// lib/main.dart
import 'package:flutter/material.dart';
import 'package:gym_notes/models/training_block.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gym_notes/services/auth_service.dart';
import 'package:gym_notes/screens/auth/login_screen.dart';
import 'package:gym_notes/screens/home_screen.dart'; // Tela principal após o login
import 'package:gym_notes/screens/auth/register_screen.dart';
import 'package:gym_notes/services/training_block_service.dart';
import 'package:gym_notes/screens/training_blocks/training_blocks_list_screen.dart'; // NOVO IMPORT
import 'package:gym_notes/screens/training_blocks/training_block_form_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Garante que o Flutter Binding está inicializado
  await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => TrainingBlockService()),
      ],
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
            return TrainingBlocksListScreen();
          } else {
            return LoginScreen();
          }
        },
      ),
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/register': (context) => RegisterScreen(),
        '/training_blocks': (context) => const TrainingBlocksListScreen(),
      },
    );
  }
}