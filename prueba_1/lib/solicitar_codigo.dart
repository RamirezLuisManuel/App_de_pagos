import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:prueba_1/verificar_correo.dart';
import 'db_helper.dart';
import 'package:mailer/smtp_server.dart';
import 'package:prueba_1/db_helper.dart';
import 'package:mailer/mailer.dart';
import 'dart:math'; //Para generar codigo automaticamente

class EnviarCod extends StatefulWidget{
  @override
  _EnviarCodState createState() => _EnviarCodState();
}

class _EnviarCodState extends State<EnviarCod> {
  final TextEditingController _correoController = TextEditingController();
  String? verificationCode;
  int? idUser;

  //Generar codigo numerico de verificacion
  String generateNumericCode(int length) {
  final random = Random();
  String code = '';
  for (int i = 0; i < length; i++) {
    code += random.nextInt(10).toString(); // Genera un dígito del 0 al 9
  }
  return code;
  }

  Future<void> _enviarCod(BuildContext context) async {
    //Vericamos si _correo no esta vacio 
    if (_correoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor ingrese su correo electrónico')),
      );
      return;
   }

    // Obtiene el ID del usuario según el correo ingresado
    idUser = await SQLHelper.correoTrue(correo: _correoController.text);
    
    if (idUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se encontró el usuario con el correo proporcionado')),
      );
      return;
    }

    // Definimos un codigo numerico de 8 digitos
    verificationCode = generateNumericCode(8);


    //Configuramos el servidor de correos (SMTP) con el correo y su llave de acceso de aplicacion
    final smtpServer = gmail('luismanuelr245@gmail.com', 'ylhk sxtm fhwl pquw');
    //Creamos el mensaje del correo electronico
    final message = Message()
      ..from = Address('luismanuelr245@gmail.com', 'Luis Manuel')
      ..recipients.add(_correoController.text)
      ..subject = 'Codigo de verificación'
      ..html = '''
        <h2>Codigo de verificación para ShopeeFy.</h2>
        <p>Este es su código de verificación: <strong>$verificationCode</strong></p>
        <p>Gracias por utilizar nuestra aplicación.</p>
        <>
      ''';

    try {
      await send(message, smtpServer);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Correo de confirmación enviado')),
      );

      // Navega a la pantalla de verificación con el código generado
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerificarCorreo(verificationCode: verificationCode!, userId: idUser!,),
        ),
      );
      
    } on MailerException catch (e) {
      print('Error al enviar el correo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar el correo')),
      );
    }
  }

  Future<void> _obtnerId() async{
    //Consulta base detos para obtenerel ID del usuario
    idUser = await SQLHelper.correoTrue(correo: _correoController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Recuperar Contraseña")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _correoController,
              decoration: InputDecoration(labelText: "Correo electronico"),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _enviarCod(context);
              },
              child: Text("Eviar código")
            ),
          ],
        )
      ),
    );
  }
}