import 'dart:convert';
import 'dart:io';
import 'dart:ui';
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

      // JWT 토큰 저장
      if (responseBody['token'] != null) {
        await _storage.write(key: 'jwt_token', value: responseBody['token']);
      }

      if (response.statusCode == 200) {
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
  Future<bool> uploadImage({
    required File image,
    required String clothingName,
    required int rating,
    required List<String> clothingTypes, // 다중 선택
    required List<String> clothingStyles, // 다중 선택
    required String memo,
    required Offset includePoint, // 추가된 포함 좌표
    required Offset excludePoint, // 추가된 제외 좌표
  }) async {
    try {
      // JWT 토큰 읽기
      final token = await _storage.read(key: 'jwt_token');

      if (token == null) {
        throw Exception('User not authenticated');
      }

      // JWT에서 이메일 추출 (옵션)
      final userId = await _getUserIdFromJwt(token);

      // 이미지를 Base64로 인코딩
      String base64Image = base64Encode(await image.readAsBytesSync());

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // JWT 인증 헤더 추가
      };
      // JSON 데이터 생성
      final body = jsonEncode({
        'userId' : userId,
        'base64Image': base64Image,
        'clothingName' : clothingName,
        'rating' : rating,
        'clothingType' : clothingTypes,
        'clothingStyle' : clothingStyles,
        'imageMemo' : memo,
        'includePoint': {'x': includePoint.dx, 'y': includePoint.dy}, // 포함 좌표
        'excludePoint': {'x': excludePoint.dx, 'y': excludePoint.dy}, // 제외 좌표
      });

      // 요청 전송
      final response = await http.post(
        Uri.parse('$nodeUrl/clothes/upload_image'),
        headers: headers,
        body: body,
      );
      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        print("${responseBody['message']}");
        return true;
      } else {
        // 실패한 경우 응답 로그
        print("Failed to upload. Status code: ${response.statusCode}");
        try {
          final responseBody = jsonDecode(response.body);
          print("Error message: ${responseBody['message']}");
        } catch (e) {
          print("Error decoding response: $e");
        }
        return false;
      }
    } catch (e) {
      // 네트워크 오류 또는 기타 에러 처리
      print("Error occurred while uploading: $e");
      return false;
    }
  }

// JWT 디코딩 및 유저 ID 추출
  Future <int> _getUserIdFromJwt(String token) async {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('Invalid JWT');
      }

      // JWT의 payload 부분 디코딩
      final payload = jsonDecode(
        utf8.decode(
          base64Url.decode(
            base64Url.normalize(parts[1]),
          ),
        ),
      );

      // 'user_id' 필드 반환
      return payload['user_id'];
    } catch (e) {
      print('Error decoding JWT: $e');
      return 0;
    }
  }
}