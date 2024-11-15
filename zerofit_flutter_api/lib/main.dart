import 'package:flutter/material.dart';
import '/services/api_service.dart'; // ApiService 파일을 임포트합니다.

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'API Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ApiTestScreen(),
    );
  }
}

class ApiTestScreen extends StatefulWidget {
  @override
  _ApiTestScreenState createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  final ApiService apiService = ApiService(); // ApiService 인스턴스 생성
  String _response = ''; // 서버 응답을 저장할 변수

  // 서버로부터 데이터 가져오기 (GET 요청)
  Future<void> _fetchData() async {
    try {
      String message = await apiService.fetchData(); // 서버 응답 메시지 가져오기
      setState(() {
        _response = message; // 서버 응답을 화면에 표시
      });
    } catch (e) {
      setState(() {
        _response = 'Failed to fetch data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('API Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _response,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchData,
              child: Text('GET My Image Info'),
            ),
          ],
        ),
      ),
    );
  }
}