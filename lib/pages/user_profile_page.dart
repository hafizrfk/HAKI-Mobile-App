import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'edit_profile_page.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const UserProfilePage({
    super.key,
    required this.userData,
  });

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late Map<String, dynamic> _userData;

  @override
  void initState() {
    super.initState();
    _userData = Map<String, dynamic>.from(widget.userData);
  }

  Future<void> _deleteProfile() async {
    try {
      // Tampilkan dialog konfirmasi
      final bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Hapus Akun'),
          content: const Text(
              'Anda yakin ingin menghapus akun? Aksi ini tidak dapat dibatalkan.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      // Tampilkan loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Dapatkan key dari data user
      final String? key = _userData['key']
          ?.toString(); // Menggunakan 'key' dari response Firebase
      if (key == null) throw Exception('User ID tidak ditemukan');

      // Gunakan HTTP DELETE request
      final response = await http.delete(
        Uri.parse(
            'https://nyoba-2e635-default-rtdb.asia-southeast1.firebasedatabase.app/users/$key.json'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Gagal menghapus user: ${response.statusCode}');
      }

      print('User berhasil dihapus');

      if (mounted) {
        // Tutup loading dialog
        Navigator.pop(context);

        // Tampilkan pesan sukses
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Akun berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );

        // Kembali ke halaman login
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/auth',
          (route) => false,
        );
      }
    } catch (e) {
      print('Error deleting user: $e');
      // Tutup loading jika masih terbuka
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Tampilkan pesan error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus akun: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, _userData),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push<Map<String, dynamic>>(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(
                    userData: _userData,
                  ),
                ),
              );
              if (result != null) {
                setState(() {
                  _userData = result;
                });
              }
            },
          ),
          // Tambahkan tombol hapus
          IconButton(
            icon: const Icon(Icons.delete),
            color: Colors.red,
            onPressed: _deleteProfile,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue,
                child: Text(
                  _userData['nama']?.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildProfileItem('Nama', _userData['nama'] ?? 'Tidak ada'),
            _buildProfileItem('Email', _userData['email'] ?? 'Tidak ada'),
            _buildProfileItem('Alamat', _userData['alamat'] ?? 'Tidak ada'),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
