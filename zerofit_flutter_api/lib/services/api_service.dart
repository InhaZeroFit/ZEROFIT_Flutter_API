import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const int port = 8005;
  final String base_url = 'http://localhost:$port'; // NodeJS Server

  // GET /my-image
  Future<String> fetchData() async {
    final response = await http.get(Uri.parse('$base_url/my-image'));
    if (response.statusCode == 200) {
      var data = json.decode(response.body); // Parsing in JSON foramt
      return data['message']; // return 'message'
    } else {
      throw Exception('Failed to load data');
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
    final url = Uri.parse('$base_url/auth/join');
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