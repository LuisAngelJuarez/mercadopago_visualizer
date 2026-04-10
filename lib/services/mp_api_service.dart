import 'dart:convert';
import 'package:http/http.dart' as http;

class MpApiService {
  static const String _baseUrl = 'https://api.mercadopago.com/v1';

  Future<List<dynamic>> getTransactions(String token) async {
    final url = Uri.parse('$_baseUrl/payments/search?limit=100&sort=date_created&criteria=desc');
    
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['results'] ?? [];
    } else {
      String msg = 'Fallo al cargar transacciones: ${response.body}';
      try {
        final errorMap = json.decode(response.body);
        if (errorMap['status'] == 401 || errorMap['message'].toString().contains('invalid_token')) {
          msg = 'El token es inválido o ha expirado. Por favor, verifica en Configuración (asegúrate de copiarlo sin comillas).';
        } else if (errorMap['message'] != null) {
          msg = 'Error de MercadoPago: ${errorMap['message']}';
        }
      } catch (_) {}
      
      throw Exception(msg);
    }
  }
}
