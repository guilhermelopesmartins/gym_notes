// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Serviços
import 'package:gym_notes/services/auth_service.dart';
import 'package:gym_notes/services/training_block_service.dart';
import 'package:gym_notes/services/training_block_exercise_service.dart';
import 'package:gym_notes/services/exercise_service.dart';
import 'package:gym_notes/services/exercise_log_service.dart';

// Telas de Autenticação e Home
import 'package:gym_notes/screens/auth/login_screen.dart';
import 'package:gym_notes/screens/auth/register_screen.dart';
import 'package:gym_notes/screens/home_screen.dart'; // Tela principal após o login

// Telas de Bloco de Treino
import 'package:gym_notes/screens/training_blocks/training_blocks_list_screen.dart';
import 'package:gym_notes/screens/training_blocks/training_block_form_screen.dart';
import 'package:gym_notes/screens/training_blocks/training_block_detail_screen.dart'; // Se você for navegar para ela via rota

// NOVAS TELAS DE LOGS
import 'package:gym_notes/screens/exercise_logs/exercise_logs_by_exercise_screen.dart';
import 'package:gym_notes/screens/exercise_logs/all_user_logs_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Garante que o Flutter Binding está inicializado
  await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => TrainingBlockService()),
        ChangeNotifierProvider(create: (context) => ExerciseService()),
        ChangeNotifierProvider(create: (context) => ExerciseLogService()),
        ChangeNotifierProvider(create: (context) => TrainingBlockExerciseService())
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
        '/exercise_logs_by_exercise': (context) => const ExerciseLogsByExerciseScreen(),
        '/all_user_logs': (context) => const AllUserLogsScreen(),
      },
    );
  }
}