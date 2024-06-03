import 'package:catatanpengeluaran/hive_database.dart';
import 'package:catatanpengeluaran/add_notes.dart';
import 'package:catatanpengeluaran/loginpage.dart';
import 'package:catatanpengeluaran/registerpage.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi database Hive saat aplikasi dimulai
  await HiveDatabase.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}