import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  const RegisterPage({
    Key? key,
    required this.showLoginPage,
  }) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final formkey = GlobalKey<FormState>();
  String _nama = "";
  String _pass = "";
  String _email = "";
  String _alamat = "";
  bool passwordVisible = false;

  Future<bool> registerUser() async {
    var uri =
        "https://nyoba-2e635-default-rtdb.asia-southeast1.firebasedatabase.app/users.json";

    try {
      final response = await http.post(
        Uri.parse(uri),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "id": "ayam_user_${DateTime.now().millisecondsSinceEpoch}",
          "nama": _nama,
          "email": _email,
          "password": _pass,
          "alamat": _alamat,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['name'] != null) {
          return true;
        }
      }

      throw Exception('Registration failed');
    } catch (e) {
      print('Registration error: $e');
      throw Exception('Registration failed: $e');
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
            child: Form(
              key: formkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 50),
                  Text(
                    'Create Account',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please fill the form to continue.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 32),
                  nameField(),
                  const SizedBox(height: 16),
                  emailField(),
                  const SizedBox(height: 16),
                  passwordField(),
                  const SizedBox(height: 16),
                  addressField(),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () async {
                              if (formkey.currentState!.validate()) {
                                formkey.currentState?.save();
                                try {
                                  // Tampilkan loading
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );

                                  final success = await registerUser();

                                  if (success && context.mounted) {
                                    // Tutup loading
                                    Navigator.pop(context);

                                    // Tampilkan pesan sukses
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Registrasi berhasil!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );

                                    // Tunggu sebentar sebelum pindah ke login
                                    await Future.delayed(
                                        const Duration(seconds: 1));
                                    if (context.mounted) {
                                      widget.showLoginPage();
                                    }
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    // Tutup loading
                                    Navigator.pop(context);

                                    // Tampilkan error
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(e.toString()),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                            child: const Text('Sign Up'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Already have an account?"),
                            TextButton(
                              onPressed: widget.showLoginPage,
                              child: const Text('Login here'),
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
      ),
    );
  }

  Widget nameField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Nama Lengkap',
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
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'nama tidak boleh kosong';
        }
        _nama = value;
        return null;
      },
    );
  }

  Widget emailField() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'email@example.com',
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
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'email tidak boleh kosong';
        } else if (!value.contains('@')) {
          return 'email tidak valid';
        }
        _email = value;
        return null;
      },
    );
  }

  Widget passwordField() {
    return TextFormField(
      obscureText: !passwordVisible,
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Enter Password',
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
            passwordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              passwordVisible = !passwordVisible;
            });
          },
        ),
      ),
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'password tidak boleh kosong';
        } else if (value.length < 4) {
          return 'password minimal 4 karakter';
        }
        _pass = value;
        return null;
      },
    );
  }

  Widget addressField() {
    return TextFormField(
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Alamat',
        hintText: 'Masukkan alamat lengkap',
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
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'alamat tidak boleh kosong';
        } else if (value.length > 30) {
          return 'alamat maksimal 30 karakter';
        }
        _alamat = value;
        return null;
      },
    );
  }
}
