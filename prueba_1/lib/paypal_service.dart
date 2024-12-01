import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class PayPalService {
  final String clientId = 'ARtRW3-xv7ycAXBzU4p738_SB4PMq8vR1FHSYRQnq9zT2ivKSN4ylr7faLSYU7GTg1IXJkPWonOkHGwW';
  final String secret = 'EJH_30orJFJScXNl-QmqPl8eGGr-cAby1upFEYLzs6hj7KR2Lw1WfgDL8F9VWW4MTBChUvJDVB-jL0b0';
  final String payPalUrl = 'https://api-m.sandbox.paypal.com';

  Future<String?> getAccessToken() async {
    try {
      final auth = base64Encode(utf8.encode('$clientId:$secret'));
      final response = await http.post(
        Uri.parse('$payPalUrl/v1/oauth2/token'),
        headers: {
          'Authorization': 'Basic $auth',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'grant_type=client_credentials',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['access_token'];
      }
      debugPrint('Error al obtener el token: ${response.statusCode} - ${response.body}');
      return null;
    } catch (e) {
      debugPrint('Error al obtener el token: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> createOrder(double amount) async {
    try {
      final accessToken = await getAccessToken();
      if (accessToken == null) return null;

      final response = await http.post(
        Uri.parse('$payPalUrl/v2/checkout/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'intent': 'CAPTURE',
          'purchase_units': [
            {
              'amount': {
                'currency_code': 'MXN',
                'value': amount.toStringAsFixed(2)
              }
            }
          ],
          'application_context': {
            'return_url': 'https://example.com/success',
            'cancel_url': 'https://example.com/cancel',
            'user_action': 'PAY_NOW',
            'shipping_preference': 'NO_SHIPPING'
          }
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      debugPrint('Error al crear orden: ${response.statusCode} - ${response.body}');
      return null;
    } catch (e) {
      debugPrint('Error al crear orden: $e');
      return null;
    }
  }

  Future<bool> capturePayment(String orderId) async {
    try {
      final accessToken = await getAccessToken();
      if (accessToken == null) return false;

      final response = await http.post(
        Uri.parse('$payPalUrl/v2/checkout/orders/$orderId/capture'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      return response.statusCode == 201;
    } catch (e) {
      debugPrint('Error al capturar pago: $e');
      return false;
    }
  }
}