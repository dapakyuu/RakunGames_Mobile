import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'home.dart';
import 'store.dart';
import 'transaksi.dart';
import 'main.dart';

class AkunPage extends StatefulWidget {
  final String username;
  final String email;

  const AkunPage({super.key, required this.username, required this.email});

  @override
  _AkunPageState createState() => _AkunPageState();
}

class _AkunPageState extends State<AkunPage> {
  int _currentIndex = 3; // Index untuk navigasi navbar
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final url = Uri.parse('http://localhost/api_pab/get_user.php');
    try {
      final response = await http.post(url, body: {
        'username': widget.username,
        'email': widget.email,
      });
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _usernameController.text = data['data']['username'];
            _emailController.text = data['data']['email'];
            _passwordController.text = data['data']['pass'];
          });
        } else {
          _showError(data['message']);
        }
      } else {
        _showError('Failed to fetch user data.');
      }
    } catch (e) {
      _showError('An error occurred: $e');
    }
  }

  Future<void> _updateUserData() async {
    final url = Uri.parse('http://localhost/api_pab/update_user.php');
    try {
      final response = await http.post(url, body: {
        'username': _usernameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
      });
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          _showSuccess(
              'Data berhasil diperbarui! Anda akan diarahkan ke halaman utama.');

          // Navigasi ke halaman utama
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
            (Route<dynamic> route) =>
                false, // Menghapus semua halaman sebelumnya
          );
        } else {
          _showError(data['message']);
        }
      } else {
        _showError('Failed to update user data.');
      }
    } catch (e) {
      _showError('An error occurred: $e');
    }
  }

  void _logoutUser() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi'),
        content: Text('Apakah kamu yakin ingin mengubah data akun ini?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _updateUserData(); // Panggil fungsi untuk memperbarui data
            },
            child: Text('Ya'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Menutup dialog
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccess(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sukses'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Menutup dialog
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _navigateToPage(int index) {
    setState(() {
      _currentIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                HomePage(username: widget.username, email: widget.email),
          ),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                StorePage(username: widget.username, email: widget.email),
          ),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                TransaksiPage(username: widget.username, email: widget.email),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFDBB5),
        title: Text(
          'Akun Saya',
          style: TextStyle(color: Color(0xFF6C4E31)),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/pattern.png'),
            fit: BoxFit.cover,
          ),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF6C4E31),
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            _buildTextField('Username', _usernameController),
            SizedBox(height: 10),
            _buildTextField('Email', _emailController),
            SizedBox(height: 10),
            _buildTextField('Password', _passwordController, obscureText: true),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _showConfirmationDialog,
              icon: Icon(Icons.save,
                  color: Colors.white), // Ikon untuk tombol Update
              label: Text('Update'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF6C4E31),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _logoutUser,
              icon: Icon(Icons.logout,
                  color: Colors.white), // Ikon untuk tombol Logout
              label: Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _navigateToPage,
        selectedItemColor: Color(0xFF6C4E31),
        unselectedItemColor: Color(0xFF603F26),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Store',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Transaksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Akun',
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
