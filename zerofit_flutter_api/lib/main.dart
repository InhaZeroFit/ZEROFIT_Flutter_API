import 'package:flutter/material.dart';
import 'services/api_service.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Signup',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Roboto',
      ),
      home: SignupScreen(),
    );
  }
}

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final ApiService _apiService = ApiService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _paymentController = TextEditingController();

  String _gender = "Other";
  String _responseMessage = '';

  Future<void> _signup() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final phoneNumber = _phoneNumberController.text.trim();
    final name = _nameController.text.trim();
    final nickname = _nicknameController.text.trim();
    final address = _addressController.text.trim();
    final payment = _paymentController.text.trim();

    if (email.isEmpty || password.isEmpty || phoneNumber.isEmpty || name.isEmpty) {
      setState(() {
        _responseMessage = 'Required fields cannot be empty!';
      });
      return;
    }

    final result = await _apiService.signup(
      email: email,
      password: password,
      phoneNumber: phoneNumber,
      name: name,
      gender: _gender,
      nickname: nickname.isNotEmpty ? nickname : "noname",
      address: address.isNotEmpty ? address : null,
      payment: payment.isNotEmpty ? payment : null,
    );

    setState(() {
      _responseMessage = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          '회원가입',
          style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: Colors.teal),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text(
              '회원 정보를 입력해주세요',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            SizedBox(height: 10),
            _buildTextField(
              controller: _emailController,
              labelText: '이메일',
              icon: Icons.email,
            ),
            _buildTextField(
              controller: _passwordController,
              labelText: '비밀번호',
              icon: Icons.lock,
              obscureText: true,
            ),
            _buildTextField(
              controller: _phoneNumberController,
              labelText: '전화번호',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            _buildTextField(
              controller: _nameController,
              labelText: '이름',
              icon: Icons.person,
            ),
            DropdownButtonFormField<String>(
              value: _gender,
              onChanged: (value) {
                setState(() {
                  _gender = value!;
                });
              },
              items: ["Male", "Female", "Other"].map((gender) {
                return DropdownMenuItem<String>(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: '성별',
                prefixIcon: Icon(Icons.wc),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(height: 10),
            _buildTextField(
              controller: _nicknameController,
              labelText: '닉네임',
              icon: Icons.tag,
            ),
            _buildTextField(
              controller: _addressController,
              labelText: '주소',
              icon: Icons.home,
            ),
            _buildTextField(
              controller: _paymentController,
              labelText: '결제 정보',
              icon: Icons.payment,
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _signup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  '가입하기',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                _responseMessage,
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}