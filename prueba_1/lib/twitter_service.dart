import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:oauth1/oauth1.dart' as oauth1;

class TwitterService {
  // Claves y tokens de la app en Twitter Developer
  final String apiKey = '4ELom2xN1V62zkKBb0Zt4xBkA';
  final String apiSecretKey = 'cfKnZgD6j7wp4CiTuDzoxvcjkTHSADyp8rXpqY3a22G4dyR2j8';
  final String accessToken = '1860796853433860097-0l11yRtmo9S8EN3XucRI4JUFvShO3H';
  final String accessTokenSecret = 'NsIMUiNvbWoiLY4h6faFiDr0E6Gr53DxNKRV0yuH2MQ7C';

  final String apiUrl = 'https://api.twitter.com/2/tweets';

  // Configuración de cliente OAuth 1.0a
  final oauth1.Client client;

  TwitterService()
      : client = oauth1.Client(
          oauth1.SignatureMethods.hmacSha1,
          oauth1.ClientCredentials(
            '4ELom2xN1V62zkKBb0Zt4xBkA',  // apiKey
            'cfKnZgD6j7wp4CiTuDzoxvcjkTHSADyp8rXpqY3a22G4dyR2j8',  // apiSecretKey
          ),
          oauth1.Credentials(
            '1860796853433860097-0l11yRtmo9S8EN3XucRI4JUFvShO3H',  // accessToken
            'NsIMUiNvbWoiLY4h6faFiDr0E6Gr53DxNKRV0yuH2MQ7C',  // accessTokenSecret
          ),
        );

  Future<void> postTweet(String message) async {
    try {
      final response = await client.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'text': message,
        }),
      );

      if (response.statusCode == 201) {
        print('Tweet enviado exitosamente');
        print('Respuesta: ${response.body}');
      } else {
        print('Error al enviar el tweet. Código: ${response.statusCode}');
        print('Cuerpo de respuesta: ${response.body}');
        throw Exception('Error al enviar el tweet: ${response.body}');
      }
    } catch (e) {
      print('Excepción al intentar enviar el tweet: $e');
      rethrow;
    }
  }
}
