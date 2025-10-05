import 'package:flutter/material.dart';
import 'login_page.dart'; // Impor halaman login

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Edu Flip App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Poppins', // Contoh penggunaan font yang lebih modern
      ),
      debugShowCheckedModeBanner: false, // Menghilangkan banner debug
      // --- PERBAIKAN UTAMA DI SINI ---
      // Pastikan aplikasi selalu dimulai dari LoginPage
      home: const LoginPage(),
    );
  }
}
