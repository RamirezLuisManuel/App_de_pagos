import 'package:flutter/material.dart';
import 'package:prueba_1/db_helper.dart';
import 'package:prueba_1/editusuario.dart';

class MostrarUsuarios extends StatefulWidget {
  const MostrarUsuarios({Key? key}) : super(key: key);

  @override
  State<MostrarUsuarios> createState() => _MostrarUsuariosState();
}

class _MostrarUsuariosState extends State<MostrarUsuarios> {
  List<Map<String, dynamic>> _allUser = [];
  bool _isLoading = true;

  //Mostar usuarios visitantes
  void _refreshUser() async {
    final users = await SQLHelper.getAllUser();
    // Filtrar solo usuarios con rol de visitante osea '1'
    final filteredUsers = users.where((user) => user['roll'] == 1).toList();
    print(users);
    setState(() {
      _allUser = filteredUsers;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshUser();
  }
  final TextEditingController _nombreEditingController = TextEditingController();
  final TextEditingController _passEditingController = TextEditingController();
  final TextEditingController _rollEditingController = TextEditingController();
  

  //Eliminar usuario
  Future<void> _deleteUser(int id) async {
    await SQLHelper.deleteUser(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: Colors.redAccent,
      content: Text("Registro eliminado"),
    ));
    _refreshUser();
  }

  void muestraDatos(int? id) {
    if (id != null) {
      final existingUser = _allUser.firstWhere((element) => element['id'] == id);
      _nombreEditingController.text = existingUser['user_name'];
      _passEditingController.text = existingUser['pass'];
      _rollEditingController.text = existingUser['roll'].toString();
    } else {
      _nombreEditingController.clear();
      _passEditingController.clear();
      _rollEditingController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFECEAF4),
      appBar: AppBar(
        title: Text("Usuarios Registrados"),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _allUser.length,
              itemBuilder: (context, index) {
                final user= _allUser[index];
              
                return Card(
                  margin: EdgeInsets.all(15),
                  child: ListTile(
                    title: Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        _allUser[index]['user_name'],
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ID: ${_allUser[index]['id']}'),
                        Text('Rol: ${_allUser[index]['roll'] == 1 ? 'Visitante' : 'Admin'}'),
                        Text('Contrasena: ${_allUser[index]['pass']}')
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditUsuarioScreen(user: user),
                              )
                            ).then((_) => _refreshUser()); 
                          },
                          icon: Icon(Icons.edit, color: Colors.amberAccent),
                        ),
                        IconButton(
                          onPressed: () => _deleteUser(user['id']),
                          icon: Icon(Icons.delete, color: Colors.redAccent),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  @override
  void dispose() {
    _nombreEditingController.dispose();
    _passEditingController.dispose();
    _rollEditingController.dispose();
    super.dispose();
  }
} 
