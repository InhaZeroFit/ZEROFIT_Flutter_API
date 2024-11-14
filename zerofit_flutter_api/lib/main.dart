import 'package:flutter/material.dart';
import 'services/api_service.dart';  // ApiService 파일을 임포트합니다.

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
  String _response = '';  // 서버 응답을 저장할 변수

  // 서버로부터 데이터 가져오기 (GET 요청)
  Future<void> _fetchData() async {
    try {
      await apiService.fetchData();
      setState(() {
        _response = 'Data fetched successfully';
      });
    } catch (e) {
      setState(() {
        _response = 'Failed to fetch data: $e';
      });
    }
  }

  // 서버로 데이터 전송하기 (POST 요청)
  Future<void> _sendData() async {
    try {
      await apiService.sendData({'message': 'Hello from Flutter'});
      setState(() {
        _response = 'Data sent successfully';
      });
    } catch (e) {
      setState(() {
        _response = 'Failed to send data: $e';
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
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchData,
              child: Text('Fetch Data'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _sendData,
              child: Text('Send Data'),
            ),
          ],
        ),
      ),
    );
  }
}