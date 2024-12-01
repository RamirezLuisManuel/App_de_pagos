import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prueba_1/db_helper.dart';
import 'package:prueba_1/home_admin.dart';
import 'package:prueba_1/home_screen.dart';
import 'package:prueba_1/registro_screen.dart';
import 'package:prueba_1/solicitar_codigo.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Iniciar Sesión'),
        automaticallyImplyLeading: false,  // Esto quita el botón de "Regresar"
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,  // Cambiado a center para centrar los botones
            children: <Widget>[
              TextFormField(
                controller: _userNameController,
                decoration: InputDecoration(labelText: 'Nombre de Usuario'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu nombre de usuario';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu contraseña';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),  // Espacio entre el campo de contraseña y los botones
              Center(
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _login();
                        }
                      },
                      child: Text('Iniciar Sesión'),
                    ),
                    SizedBox(height: 16), 
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EnviarCod()),
                        );
                      },
                      child: Text("¿Olvidaste tu contraseña?"),
                    ),
                    SizedBox(height: 16), 
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UserForm()),
                        );
                      },
                      child: Text('¿No tienes cuenta? Regístrate aquí'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Función para encriptar la contraseña usando SHA-256
  String generateSha256Hash(String password) {
    var bytes = utf8.encode(password);  // Convierte la contraseña a bytes
    var digest = sha256.convert(bytes);  // Aplica el algoritmo SHA-256
    return digest.toString();  // Devuelve el hash en formato hexadecimal
  }
  
  void _login() async {
    String userName = _userNameController.text;
    String password = _passwordController.text;
    String hashedPassword = generateSha256Hash(password);
    
    Map<String, dynamic>? loginResult = await SQLHelper().login_User(userName, hashedPassword);

    if (loginResult != null) {
      int roll = loginResult['roll'];
      int userId = loginResult['id'];

      if (roll == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usted inició sesión como visitante.')),
        );
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                userId: userId,
              ),
            ),
          );
        });
      } else if (roll == 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usted inició sesión como admin.')),
        );
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeAdmin(),
            ),
          );
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nombre de usuario o contraseña incorrectos')),
      );
    }
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
