import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiService {
  late final String nodeHost;
  late final String nodePort;
  late final String nodeUrl;
  ApiService() {
    nodeHost = dotenv.get("NODE_HOST");
    nodePort = dotenv.get("NODE_PORT");
    nodeUrl = 'http://$nodeHost:$nodePort';
  }

  // GET /my-image
  Future<String> fetchData() async {
    try {
      final response = await http.get(Uri.parse('$nodeUrl/my-image'));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return data['message'];
      } else {
        final error = json.decode(response.body);
        throw Exception('Failed to load data: ${error['message']}');
      }
    } catch (e) {
      print('Error fetching data: $e');
      return 'Error fetching data';
    }
  }

  // POST /auth/join
  Future<String> signup({
    required String email,
    required String password,
    required String phoneNumber,
    required String name,
    required String gender,
    required String nickname,
    String? profilePhoto,
    String? address,
    String? payment,
  }) async {
    final url = Uri.parse('$nodeUrl/auth/join');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'email': email,
      'password': password,
      'phone_number': phoneNumber,
      'name': name,
      'gender': gender,
      'nick': nickname,
      'profile_photo': profilePhoto ?? "/public/default_image.png",
      'address': address,
      'payment': payment,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        return 'Signup successful!';
      } else {
        final responseBody = jsonDecode(response.body);
        return 'Successfully: ${responseBody['message']}';
      }
    } catch (e) {
      return 'Error: Could not connect to server';
    }
  }
}