import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfilePage({
    super.key,
    required this.userData,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _emailController;
  late TextEditingController _alamatController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.userData['nama']);
    _emailController = TextEditingController(text: widget.userData['email']);
    _alamatController = TextEditingController(text: widget.userData['alamat']);
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final String? key = widget.userData['key']?.toString();
      if (key == null) throw Exception('User ID tidak ditemukan');

      // Buat map untuk update
      final Map<String, dynamic> updates = {};
      updates['/users/$key/nama'] = _namaController.text;
      updates['/users/$key/email'] = _emailController.text;
      updates['/users/$key/alamat'] = _alamatController.text;

      // Update data menggunakan update()
      await FirebaseDatabase.instance
          .ref()
          .update(updates)
          .then((_) => print('Profile updated successfully'))
          .catchError((error) {
        print('Error updating profile: $error');
        throw error;
      });

      if (mounted) {
        Navigator.pop(context, {
          ...widget.userData,
          'nama': _namaController.text,
          'email': _emailController.text,
          'alamat': _alamatController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _alamatController,
                decoration: const InputDecoration(
                  labelText: 'Alamat',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Update Profile'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
