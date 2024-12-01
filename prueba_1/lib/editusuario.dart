import 'package:flutter/material.dart';
import 'db_helper.dart';

class EditUsuarioScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const EditUsuarioScreen({Key? key, required this.user}) : super(key: key);

  @override
  _EditUsuarioScreenState createState() => _EditUsuarioScreenState();
}

class _EditUsuarioScreenState extends State<EditUsuarioScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _rollController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Carga los datos actuales del usuario en los controladores
  void _loadUserData() {
    _nameController.text = widget.user['user_name'];
    _correoController.text = widget.user['correo'];
    _rollController.text = widget.user['roll'].toString();
  }

  // Actualizar usuario
  Future<void> _updateUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        int roll = int.parse(_rollController.text);
        if (roll != 1 && roll != 2) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('El rol debe ser 1 o 2')),
          );
          return;
        }

        int result = await SQLHelper.updateUser(
          id: widget.user['id'],
          nombre: _nameController.text,
          correo: _correoController.text,
          roll: roll,
        );

        if (!mounted) return;

        if (result > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuario actualizado exitosamente')),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo actualizar el usuario')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Usuario'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nombre del Usuario'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre del usuario';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _correoController,
                decoration: InputDecoration(labelText: 'Correo del Usuario'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el correo';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Por favor ingresa un correo válido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _rollController,
                decoration: const InputDecoration(labelText: 'Rol (1:Visitante, 2:Admin)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el rol';
                  }
                  int? rollValue = int.tryParse(value);
                  if (rollValue == null || (rollValue != 1 && rollValue != 2)) {
                    return 'El rol debe ser 1 (Visitante) o 2 (Admin)';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _updateUser,
                child: Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _correoController.dispose();
    _rollController.dispose();
    super.dispose();
  }
}
