import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  late final String nodeUrl;
  final _storage = const FlutterSecureStorage();

  ApiService() {
    nodeUrl = 'http://${dotenv.get("NODE_HOST")}:${dotenv.get("NODE_PORT")}';
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
      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {

        // JWT 토큰 저장
        if (responseBody['token'] != null) {
          await _storage.write(key: 'jwt_token', value: responseBody['token']);
        }
        print(responseBody['token']);
        return 'Signup successful!';
      } else {
        return 'Successfully: ${responseBody['message']}';
      }
    } catch (e) {
      return 'Error: Could not connect to server';
    }
  }
  // POST /auth/login
  Future<Map<String, dynamic>> sendLoginRequest(String email, String password) async {
    final url = Uri.parse('$nodeUrl/auth/login');
    final headers = {'Content-Type': 'application/json'};
    final body = {'email': email, 'password': password};
    try {
      final response = await http.post(url, headers: headers, body: jsonEncode(body));
      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        print(responseBody['message']);
        return {
          'status': true, // 요청 성공 여부
          'message': responseBody['message'], // 메시지
        };
      }
      return {
        'status': false, // 요청 성공 여부
        'message': 'Error: ${responseBody['message']}' // 메시지
      };
    } catch (e) {
      print('Error: Could not connect to server');
      return {
        'status': false, // 요청 성공 여부
        'message': 'Error: Could not connect to server', // 메시지
      };
    }
  }


  // POST /clothes/upload_image
  Future<Map<String, dynamic>?> uploadImage({
    required File image,
    required int clothesId,
  }) async {
    try {
      // 이미지를 Base64로 인코딩
      String base64Image = base64Encode(await image.readAsBytesSync());
      // JSON 데이터 생성
      final body = jsonEncode({
        'clothes_id': clothesId,
        'image': base64Image,
      });
      /*
      final body = jsonEncode({
        'user_id' : userId,
        'base64Image' : base64Image,
        'name' : name,
        'clothes_type' : clothesType,
        'score' : score,
        'size' : size,
        'brand' : brand,
        'memo' : memo,
      });
      */
      // 요청 전송
      final response = await http.post(
        Uri.parse('$nodeUrl/clothes/upload_image'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body); // 성공 시 JSON 데이터 반환
      } else {
        // 실패한 경우 응답 로그
        print("Failed to upload. Status code: ${response.statusCode}");
        try {
          final responseBody = jsonDecode(response.body);
          print("Error message: ${responseBody['message']}");
        } catch (e) {
          print("Error decoding response: $e");
        }
        return null;
      }
    } catch (e) {
      // 네트워크 오류 또는 기타 에러 처리
      print("Error occurred while uploading: $e");
      return null;
    }
  }
}