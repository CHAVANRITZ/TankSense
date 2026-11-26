
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  static const String tankId = '6b03e142ececa4c8db98bc54';

  static Future<Map<String, dynamic>> getDashboard() async {
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard/$tankId'),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);

      if (result['success'] == true) {
        return result['data'];
      }

      throw Exception(result['message'] ?? 'Dashboard request failed');
    }

    throw Exception(
      'Server error: ${response.statusCode}',
    );
  }
  // Update pump mode (AUTO / MANUAL)
static Future<Map<String, dynamic>> updatePumpMode(String mode) async {
  final response = await http.put(
    Uri.parse('$baseUrl/pumps/$tankId/mode'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'mode': mode,
    }),
  );

  final result = jsonDecode(response.body);

  if (response.statusCode == 200 && result['success'] == true) {
    return result['data'];
  }

  throw Exception(
    result['message'] ?? 'Failed to update pump mode',
  );
}


  // Manually control pump (ON / OFF)
  static Future<Map<String, dynamic>> controlPump(String action) async {
    final response = await http.put(
      Uri.parse('$baseUrl/pumps/$tankId/control'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'action': action,
      }),
    );

    final result = jsonDecode(response.body);

    if (response.statusCode == 200 && result['success'] == true) {
      return result['data'];
    }

    throw Exception(
      result['message'] ?? 'Failed to control pump',
    );
  }

// Fetch pump activity history
static Future<Map<String, dynamic>> getPumpHistory({
  int page = 1,
  int limit = 10,
}) async {
  final response = await http.get(
    Uri.parse(
      '$baseUrl/pumps/$tankId/history?page=$page&limit=$limit',
    ),
  );

  final result = jsonDecode(response.body);

  if (response.statusCode == 200 && result['success'] == true) {
    return {
      'data': List<Map<String, dynamic>>.from(result['data']),
      'pagination': result['pagination'],
    };
  }

  throw Exception(
    result['message'] ?? 'Failed to fetch pump history',
  );
}

}
