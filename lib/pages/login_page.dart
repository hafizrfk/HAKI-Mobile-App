import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  final VoidCallback showRegisterPage;
  const LoginPage({
    Key? key,
    required this.showRegisterPage,
  }) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool passwordVisible = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> checkLogin(String email, String password) async {
    var uri =
        "https://nyoba-2e635-default-rtdb.asia-southeast1.firebasedatabase.app/users.json";

    try {
      final response = await http.get(
        Uri.parse(uri),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Iterate through all users to find matching email and password
        for (var entry in data.entries) {
          final user = entry.value;
          if (user['email'] == email && user['password'] == password) {
            return {
              ...user,
              'key': entry.key,
            };
          }
        }

        throw Exception('Invalid email or password');
      }

      throw Exception('Failed to connect to server');
    } catch (e) {
      print('Login error: $e');
      throw Exception('Login failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                Text(
                  'Welcome Back!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Use the form below to access your account.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'Enter your email here...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: !passwordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password here...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          passwordVisible = !passwordVisible;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );

                              final userData = await checkLogin(
                                emailController.text.trim(),
                                passwordController.text.trim(),
                              );

                              if (context.mounted) {
                                Navigator.pop(context); // Close loading dialog

                                // Navigate to home page with user data
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/home_page',
                                  (route) => false,
                                  arguments: userData, // Pass the user data
                                );

                                // Show success message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Login successful!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                Navigator.pop(context); // Close loading
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(e.toString()),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text('Sign In'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?"),
                          TextButton(
                            onPressed: widget.showRegisterPage,
                            child: const Text('Create Account'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
