// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importe o Provider
import 'package:gym_notes/services/auth_service.dart';
import 'package:gym_notes/screens/home_screen.dart'; // Tela de destino após o login
import 'package:gym_notes/screens/auth/register_screen.dart'; // Para o link de registro

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Chave para validar o formulário
  bool _isLoading = false; // Estado para mostrar indicador de carregamento

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return; // Não prossegue se o formulário for inválido
    }

    setState(() {
      _isLoading = true; // Ativa o indicador de carregamento
    });

    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      // Chama o método de login do AuthService
      final user = await authService.login(
        _usernameController.text,
        _passwordController.text,
      );

      if (user != null) {
        // Login bem-sucedido, navega para a HomeScreen e remove a LoginScreen da pilha
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      // Trata erros de login (ex: credenciais inválidas)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de login: ${e.toString().replaceFirst('Exception: ', '')}')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Desativa o indicador de carregamento
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Bem-vindo de volta!',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Nome de Usuário',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira seu nome de usuário.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true, // Esconde a senha
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira sua senha.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                _isLoading
                    ? Center(child: CircularProgressIndicator()) // Mostra indicador de carregamento
                    : ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Entrar',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    // Navegar para a tela de registro
                    // Navigator.of(context).pushNamed('/register');
                    print('Navegar para tela de registro (ainda não implementada)');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Tela de registro ainda não implementada.')),
                    );
                  },
                  child: Text(
                    'Não tem uma conta? Registre-se aqui.',
                    style: TextStyle(color: Colors.blueGrey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}