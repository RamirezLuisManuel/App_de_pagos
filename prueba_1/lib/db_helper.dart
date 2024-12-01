import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqflite.dart';

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE user(
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    user_name TEXT,
    pass TEXT,
    correo TEXT,
    roll INT CHECK (roll IN (1,2)) DEFAULT 1,
    createdAT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )""");

    await database.execute("""CREATE TABLE producto(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      nombre_product TEXT,
      precio DOUBLE,
      cantida_producto INTEGER,
      imagen TEXT,
      createdAT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )""");
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase("Database", version: 1,
        onCreate: (sql.Database database, int versiob) async {
      await createTables(database);
    });
  }

  Future<List<String>> getPermissionsForUser(int userId) async {
    final db = await SQLHelper.db();
    List<Map<String, dynamic>> permiso_user = await db.query('rol_permiso',
        columns: ['rol'], where: 'userId = ?', whereArgs: [userId]);

    return List.generate(permiso_user.length, (index) {
      return permiso_user[index]['rol'].toString();
    });
  }

  //Crear usuario
  static Future<int?> createUser(String user, String pass, String correo) async {
    final db = await SQLHelper.db();

    // Verifica si el usuario o correo ya existen en la base de datos
    final List<Map<String, dynamic>> existingUser = await db.rawQuery(
      'SELECT id FROM user WHERE user_name = ? OR correo = ?',
      [user, correo],
    );

    // Si existe un usuario con el mismo nombre o correo, retorna null para indicar que no se puede crear
    if (existingUser.isNotEmpty) {
      return null;
    }

    // Determina el rol del nuevo usuario: si es el primer usuario, será Admin (roll = 2), si no, será Visitante (roll = 1).
    int roll = 1; // Por defecto, "Visitante"
    final userCount = sql.Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM user'));
    if (userCount == 0) {
    roll = 2; // Asigna "Admin" si es el primer usuario
  }

  // Crea el nuevo usuario con el rol determinado
  final user_app = {
    'user_name': user,
    'pass': pass,
    'correo': correo,
    'roll': roll,
    'createdAT': DateTime.now().toString(),
  };
  
  final id = await db.insert('user', user_app, conflictAlgorithm: sql.ConflictAlgorithm.replace);
  return id;
  }

  //Atualizar usuario
  static Future<int> updateUser({required int id, required String nombre, required String correo, required int roll}) async { 
  final db = await SQLHelper.db();
  final user = {
    'user_name': nombre,
    'correo': correo,
    'roll': roll,
  };

  final result = 
      await db.update('user',user, where: "id = ?", whereArgs: [id]);
  return result;
  }

//Eliminar usuario
  static Future<void> deleteUser(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete('user', where: "id=?", whereArgs: [id]);
    }catch (e) {
      print('Error al eliminar el usario:$id, a causa de: {},$e');
    }
  }

  //Loguear usuario
  Future<Map<String, dynamic>?> login_User(String user_name, String pass) async {
    final db = await SQLHelper.db();
    List<Map<String, dynamic>> user = await db.query(
      'user',
      where: 'user_name = ? AND pass = ?' ,
      whereArgs: [user_name, pass],
    );
    if (user.isNotEmpty) {
      return {
        'id': user[0]['id'] as int,
        'roll': user[0]['roll'] as int,
        'correo': user[0]['correo'] as String
      };
    }else{
      return null;
    }
  }

  //Obtener correo
  static Future<String?> getUserEmail(int userId) async {
  final db = await SQLHelper.db();
  List<Map<String, dynamic>> result = await db.query(
    'user',
    where: 'id = ?',
    whereArgs: [userId],
    limit: 1,
  );
  if (result.isNotEmpty) {
    return result.first['correo'];
  }
  return null;
  }

  //Recuperar contraseña
  static Future<int> saveNewPass({required int id, required String password}) async {
    final db = await SQLHelper.db();
    final updateData = {'pass': password};

    final result = await db.update(
      'user',
      updateData,
      where: "id = ?",
      whereArgs: [id]);
    return result;
  }

  //Comparar correos
  static Future<int?> correoTrue({required String correo}) async {
    final db = await SQLHelper.db();

    //Consulta de ID
    final iduser = sql.Sqflite.firstIntValue(await db.rawQuery('SELECT id FROM user WHERE correo = ?', [correo]));
    if (iduser == null) {
      return null;
    }else{
      return iduser;
    }
  }  

  //Obtener usuarios
  static Future<List<Map<String, dynamic>>> getAllUser() async {
    final db = await SQLHelper.db();
    return db.query('user', orderBy: 'id');
  }

  //Obtener usuario
  static Future<List<Map<String, dynamic>>> getSingleUser(int id) async {
    final db = await SQLHelper.db();
    return db.query('user', where: 'id=?', whereArgs: [id], limit: 1);
  }

  //Método para verificar si un usuario ya existe en la base de datos
  static Future<bool> userExists(String userName) async {
    final db = await SQLHelper.db();
    List<Map<String, dynamic>> result = await db.query(
      'user',
      where: 'user_name = ?',
      whereArgs: [userName],
    );
    return result.isNotEmpty;
  }

  //Tabla productos
  // Crear producto
  static Future<int> createProduct({
    required String nombreProducto,
    required double precio,
    required int cantidadProducto,
    String? imagen,
  }) 
  async {
    final db = await SQLHelper.db();
    final data = {
      'nombre_product': nombreProducto,
      'precio': precio,
      'cantida_producto': cantidadProducto,
      'imagen': imagen,
      'createdAT': DateTime.now().toString(),
    };
    final id = await db.insert('producto', data, conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  // Obtener productos
  static Future<List<Map<String, dynamic>>> getAllProducts() async {
    final db = await SQLHelper.db();
    return db.query('producto', orderBy: 'id');
  }

  // Obtener producto
  static Future<Map<String, dynamic>?> getProduct(int id) async {
    final db = await SQLHelper.db();
    final result = await db.query('producto', where: 'id = ?', whereArgs: [id], limit: 1);
    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  // Actualizar producto
  static Future<int> updateProduct({
    required int id,
    required String nombreProducto,
    required double precio,
    required int cantidadProducto,
    String? imagen,
  }) async {
    final db = await SQLHelper.db();
    final data = {
      'nombre_product': nombreProducto,
      'precio': precio,
      'cantida_producto': cantidadProducto,
      'imagen': imagen,
      'createdAT': DateTime.now().toString(),
    };
    final result = await db.update('producto', data, where: 'id = ?', whereArgs: [id]);
    return result;
  }

  // Eliminar producto
  static Future<void> deleteProduct(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete('producto', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('Error al eliminar el producto: $id. Causa: $e');
    }
  }
 }