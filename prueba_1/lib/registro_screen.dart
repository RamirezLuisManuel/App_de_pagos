
  import 'package:flutter/material.dart';
  import 'package:prueba_1/db_helper.dart';
  import 'form_login.dart'; 
  import 'package:crypto/crypto.dart';
  import 'dart:convert';

  class UserForm extends StatefulWidget {
    const UserForm ({super.key});
    @override
    _UserFormState createState() => _UserFormState();
  }

  class _UserFormState extends State<UserForm> {
    final _formKey = GlobalKey<FormState>();
    bool _hasMinLength = false;
    bool _hasUpperCase = false;
    bool _hasNumber = false;
    bool _hasSpecialChar = false;


    final TextEditingController _nombreController = TextEditingController();
    final TextEditingController _passController = TextEditingController();
    final TextEditingController _correoController = TextEditingController();
 
    void _validatePassword(String password) {
      setState(() {
        _hasMinLength = password.length >= 8;
        _hasNumber = password.contains(RegExp(r'\d'));
        _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      });
    }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Crear Usuario'),
    ),
    body: Padding(
      padding: EdgeInsets.all(16.0),
      child: SingleChildScrollView( // Agregado
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor ingresa el nombre';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _correoController,
                decoration: InputDecoration(labelText: 'Correo'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor ingresa el correo';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Ingresa un correo válido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passController,
                decoration: InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                onChanged: _validatePassword,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor ingresa la contraseña';
                  }
                  if (!_hasMinLength || !_hasNumber || !_hasSpecialChar) {
                    return 'La contraseña no cumple con todos los requisitos';
                  }
                  return null;
                },
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Requisitos de la contraseña:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '• Al menos 8 caracteres',
                    style: TextStyle(
                      color: _hasMinLength ? Colors.green : Colors.red,
                    ),
                  ),
                  Text(
                    '• Al menos un número',
                    style: TextStyle(
                      color: _hasNumber ? Colors.green : Colors.red,
                    ),
                  ),
                  Text(
                    '• Al menos un carácter especial (!@#\$%^&*)',
                    style: TextStyle(
                      color: _hasSpecialChar ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Registrar'),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginForm()),
                  );
                },
                child: Text('¿Ya tienes una cuenta? Inicia sesión aquí'),
              ),
            ],
          ),
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

    void _submitForm() async {
  if (_formKey.currentState!.validate()) {
    String nombre = _nombreController.text;
    String pass = generateSha256Hash(_passController.text);
    String correo = _correoController.text;

    int? userId = await SQLHelper.createUser(nombre, pass, correo);

    if (userId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuario creado con ID: $userId')),
      );

      // Navega automáticamente a la pantalla de Login después del registro exitoso
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginForm()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El usuario o correo ya existe, intenta con otro.')),
      );
    }
  }
}


    @override
    void dispose() {
      _nombreController.dispose();
      _passController.dispose();  
      _correoController.dispose();
      super.dispose();
    }
  }

  void main() {
    runApp(MaterialApp(
      title: 'User Form',
      home: UserForm(),
    ));
  }