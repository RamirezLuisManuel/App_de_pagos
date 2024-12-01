import 'package:flutter/material.dart';
import 'package:prueba_1/form_login.dart';


void main() {
  runApp (MyApp());
}

bool isDesktop(){ 
  return !identical(0,0.0);
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi Aplicación Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginForm(),
      debugShowCheckedModeBanner: false,
    );
  }
}