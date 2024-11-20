import 'package:flutter/material.dart';
import 'screens/auth.dart'; // 회원가입 창
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'screens/home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _responseMessage = '';

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _responseMessage = 'Email and password cannot be empty!';
      });
      return;
    }

    // Node.js 서버로 로그인 요청
    final response = await _sendLoginRequest(email, password);

    _passwordController.clear();

    setState(() {
      _responseMessage = response;
    });
  }

  Future<String> _sendLoginRequest(String email, String password) async {
    final url = Uri.parse('http://localhost:10103/auth/login');
    final headers = {'Content-Type': 'application/json'};
    final body = {'email': email, 'password': password};

    try {
      final response = await http.post(url, headers: headers, body: jsonEncode(body));
      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(email: email), // 이메일 전달
          ),
        );

        return 'Login successful!';
      } else {
        final responseBody = jsonDecode(response.body);
        return 'Error: ${responseBody['message']}';
      }
    } catch (e) {
      return 'Error: Could not connect to server';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock)),
              obscureText: true,
              textInputAction: TextInputAction.done, // 키보드에 'Done' 버튼 추가
              onSubmitted: (value) {
                _login(); // 엔터를 누르면 로그인 버튼과 동일한 동작 수행
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Login', style: TextStyle(fontSize: 18)),
            ),
            SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignupScreen()),
                );
              },
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Signup', style: TextStyle(fontSize: 18, color: Colors.teal)),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                _responseMessage,
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}