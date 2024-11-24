import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../screens/home.dart'; // 홈 화면 임포트

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
  // POST /auth/login
  Future<http.Response?> sendLoginRequest(String email, String password) async {
    final url = Uri.parse('$nodeUrl/auth/login');
    final headers = {'Content-Type': 'application/json'};
    final body = {'email': email, 'password': password};
    try {
      final response = await http.post(url, headers: headers, body: jsonEncode(body));
      return response;
    } catch (e) {
      print('Error: Could not connect to server');
      return null;
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