import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/auth.dart'; // 회원가입 창
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'screens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // 1번코드
  await dotenv.load(fileName: ".env");    // 2번코드
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

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
    String nodeHost = dotenv.get("NODE_HOST");
    String nodePort = dotenv.get("NODE_PORT");
    String nodeUrl = 'http://$nodeHost:$nodePort';
    final url = Uri.parse('$nodeUrl/auth/login');
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
        title: const Text('Login'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock)),
              obscureText: true,
              textInputAction: TextInputAction.done, // 키보드에 'Done' 버튼 추가
              onSubmitted: (value) {
                _login(); // 엔터를 누르면 로그인 버튼과 동일한 동작 수행
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Login', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignupScreen()),
                );
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Signup', style: TextStyle(fontSize: 18, color: Colors.teal)),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                _responseMessage,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}