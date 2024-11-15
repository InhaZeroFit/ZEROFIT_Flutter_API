import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const int port = 8005;
  final String baseUrl = 'http://localhost:$port'; // NodeJS Server

  Future<String> fetchData() async {
    final response = await http.get(Uri.parse('$baseUrl/my-image'));
    if (response.statusCode == 200) {
      var data = json.decode(response.body); // Parsing in JSON foramt
      return data['message']; // return 'message'
    } else {
      throw Exception('Failed to load data');
    }
  }
}