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
        // Remova todos os asteriscos daqui!
        scaffoldBackgroundColor: Colors.black,

        primaryColor: Colors.yellow[700],
        colorScheme: ColorScheme.dark(
          primary: Colors.yellow[700]!,
          onPrimary: Colors.white,
          secondary: Colors.yellow[400]!,
          onSecondary: Colors.black,
          surface: Colors.black,
          onSurface: Colors.white,
          background: Colors.black,
          onBackground: Colors.white,
          error: Colors.red,
          onError: Colors.white,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: Colors.yellow[700],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.yellow[400],
          ),
        ),

        cardTheme: CardTheme(
          color: Colors.grey[900],
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.yellow[700]!, width: 1.5),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),

        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Colors.white),
          displayMedium: TextStyle(color: Colors.white),
          displaySmall: TextStyle(color: Colors.white),
          headlineLarge: TextStyle(color: Colors.white),
          headlineMedium: TextStyle(color: Colors.white),
          headlineSmall: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white),
          titleSmall: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.white),
          labelLarge: TextStyle(color: Colors.white),
          labelMedium: TextStyle(color: Colors.white),
          labelSmall: TextStyle(color: Colors.white),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[850],
          hintStyle: TextStyle(color: Colors.grey[500]),
          labelStyle: const TextStyle(color: Colors.white),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[700]!, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.yellow[700]!, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),

        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.yellow[700],
          foregroundColor: Colors.black,
        ),

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