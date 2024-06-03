import 'dart:convert';
import 'package:catatanpengeluaran/add_notes.dart';
import 'package:catatanpengeluaran/hive_database.dart';
import 'package:catatanpengeluaran/registerpage.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'transaction_model.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    // Ambil data pengguna dari database berdasarkan username
    User? user = await HiveDatabase.getUserByUsername(username);

    if (user != null) {
      // Enkripsi password yang dimasukkan oleh pengguna dengan MD5
      String hashedPassword = md5.convert(utf8.encode(password)).toString();

      // Cocokkan password yang dienkripsi dengan password yang sudah tersimpan
      if (user.password == hashedPassword) {
        // Jika pengguna ditemukan dan kredensial cocok, beri akses
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login successful!')),
        );

        // Navigasi ke halaman AddNotePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AddNotePage(username: username)),
        );
      } else {
        // Jika password salah, beri pesan kesalahan
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password salah!')),
        );
      }
    } else {
      // Jika username tidak ditemukan, beri pesan kesalahan
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Username tidak ditemukan!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
              inputFormatters: [
                LengthLimitingTextInputFormatter(10),
              ],
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
              inputFormatters: [
                LengthLimitingTextInputFormatter(10),
              ],
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage()),
                );
              },
              child: Text(
                'Don\'t have an account? Register here!',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
