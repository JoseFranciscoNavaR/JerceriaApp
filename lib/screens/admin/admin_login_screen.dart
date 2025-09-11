
import 'package:flutter/material.dart';
import './admin_panel_screen.dart'; // 1. Importar el panel de admin

class AdminLoginScreen extends StatefulWidget {
  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';

  void _tryLogin() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (isValid) {
      _formKey.currentState?.save();
      
      if (_username == 'admin' && _password == 'admin') {
        // 2. Navegar al panel de admin
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AdminPanelScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuario o contraseña incorrectos')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Acceso de Administrador'),
      ),
      body: Center(
        child: Card(
          margin: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      key: ValueKey('username'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingrese un usuario.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _username = value!;
                      },
                      decoration: InputDecoration(labelText: 'Usuario'),
                    ),
                    TextFormField(
                      key: ValueKey('password'),
                      validator: (value) {
                        if (value == null || value.length < 5) {
                          return 'La contraseña debe tener al menos 5 caracteres.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _password = value!;
                      },
                      decoration: InputDecoration(labelText: 'Contraseña'),
                      obscureText: true,
                    ),
                    SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _tryLogin,
                      child: Text('Iniciar Sesión'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
