import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

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

  String _gender = "Other"; // Default value for gender
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
        title: const Text('Signup', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Create Your Account',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email, color: Colors.teal),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock, color: Colors.teal),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: const Icon(Icons.phone, color: Colors.teal),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                prefixIcon: const Icon(Icons.person, color: Colors.teal),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 15),
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
                labelText: 'Gender',
                prefixIcon: const Icon(Icons.person_outline, color: Colors.teal),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _nicknameController,
              decoration: InputDecoration(
                labelText: 'Nickname',
                prefixIcon: const Icon(Icons.tag, color: Colors.teal),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Address',
                prefixIcon: const Icon(Icons.home, color: Colors.teal),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _paymentController,
              decoration: InputDecoration(
                labelText: 'Payment Info',
                prefixIcon: const Icon(Icons.credit_card, color: Colors.teal),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _signup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Signup', style: TextStyle(fontSize: 18)),
              ),
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