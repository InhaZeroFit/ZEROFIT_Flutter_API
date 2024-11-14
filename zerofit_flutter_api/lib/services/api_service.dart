import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const int port = 8005;
  final String baseUrl = 'http://localhost:$port'; // Node.js 서버 URL

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('$baseUrl/data'));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print(data);
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> sendData(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/data'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode == 200) {
      print('Data sent successfully');
    } else {
      throw Exception('Failed to send data');
    }
  }
}