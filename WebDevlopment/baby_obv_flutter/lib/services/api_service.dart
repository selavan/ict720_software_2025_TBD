import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://10.0.2.2:5000"; // Update with your Flask API URL

  Future<Map<String, dynamic>> fetchData({int minutes = 10}) async {
    try {
      // Use the new /api/baby_status endpoint and pass the mins parameter
      final response = await http.get(
        Uri.parse('$baseUrl/api/baby_status?mins=$minutes'),
        headers: {
          // 'Authorization': 'Bearer your_token', // Add headers if needed
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        return {'status': 'error', 'message': 'No data found', 'data': []};
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }
}
