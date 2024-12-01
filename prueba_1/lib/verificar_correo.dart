import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:prueba_1/recuperar_contrase%C3%B1a.dart';

class VerificarCorreo extends StatefulWidget{
  final int userId;
  final String verificationCode;
  const VerificarCorreo ({super.key, required this.verificationCode, required this.userId});

  @override
  _VerificarCorreo createState() => _VerificarCorreo();
}

class _VerificarCorreo extends State<VerificarCorreo>{
  final TextEditingController _codigoController = TextEditingController();

  void _verificarCorreo(BuildContext context){
    String codigo = _codigoController.text.trim();

    //Logica para verificar codigo
    if(codigo == widget.verificationCode){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RecuperarContrasena(userId: widget.userId))
      );
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Código incorrecto. Intente de nuevo.'))
      );
    }
  }  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Verificar Código")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _codigoController,
              decoration: InputDecoration(labelText: "Código de verificación"),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _verificarCorreo(context),
              child: Text("Verificar"),
            ),
          ],
        ),
      ),
    );
  }
}