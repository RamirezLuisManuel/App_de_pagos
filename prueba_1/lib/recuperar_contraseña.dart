import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:prueba_1/db_helper.dart';
import 'package:prueba_1/form_login.dart';

class RecuperarContrasena extends StatefulWidget {
  final int userId;
  const RecuperarContrasena({super.key, required this.userId});

  @override
  _RecuperarContrasena createState() => _RecuperarContrasena();
}

class _RecuperarContrasena extends State<RecuperarContrasena> {
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _passConfirmacionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Variables para validar la contraseña
  bool _hasMinLength = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  void _validatePassword(String password) {
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasNumber = password.contains(RegExp(r'\d'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  // Función para encriptar la contraseña usando SHA-256
  String generateSha256Hash(String password) {
    var bytes = utf8.encode(password);  // Convierte la contraseña a bytes
    var digest = sha256.convert(bytes);  // Aplica el algoritmo SHA-256
    return digest.toString();  // Devuelve el hash en formato hexadecimal
  }

  // Método para validar y guardar la nueva contraseña
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Verifica que las contraseñas coincidan
      if (_passController.text != _passConfirmacionController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Las contraseñas no coinciden')),
        );
        return;
      }

      // Hasheamos la nueva contraseña
      String hashedPassword = generateSha256Hash(_passController.text);

      // Actualizamos la contraseña
      int? result = await SQLHelper.saveNewPass(id: widget.userId, password: hashedPassword);

      if (result != null && result > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Contraseña actualizada correctamente')),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginForm()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar la contraseña')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nueva Contraseña")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _passController,
                decoration: InputDecoration(labelText: "Nueva contraseña"),
                obscureText: true,
                onChanged: _validatePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
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
              SizedBox(height: 16),
              TextFormField(
                controller: _passConfirmacionController,
                decoration: InputDecoration(labelText: "Confirmar nueva contraseña"),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor confirme su contraseña';
                  }
                  if (value != _passController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text("Guardar nueva contraseña"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
