import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_config.dart';
import 'dashboard_page.dart';
import 'register_page.dart';
import 'student_dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscure = true;
  bool _isLoading = false;

  void _showDialog(String title, String content) {
    if (!mounted) return;
    showDialog(context: context, builder: (_) => AlertDialog(title: Text(title), content: Text(content), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))]));
  }

  Future<void> _login() async {
    if (_isLoading) return;
    setState(() { _isLoading = true; });

    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showDialog("Error", "Username dan Password wajib diisi!");
      setState(() { _isLoading = false; });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      ).timeout(const Duration(seconds: 15));

      if (!mounted) return;

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final user = data['user'];
        final loggedInUsername = user['username'];
        final role = user['role']; 

        if (role == 'Guru') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DashboardPage(username: loggedInUsername, role: role)));
        } else if (role == 'Siswa') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => StudentDashboardPage(username: loggedInUsername, role: role)));
        } else {
          _showDialog("Login Gagal", "Peran pengguna tidak dikenali. Hubungi administrator.");
        }

      } else {
        _showDialog("Login Gagal", data['message'] ?? "Cek kembali username & password Anda.");
      }
    } catch (e) {
      if (mounted) _showDialog("Koneksi Error", "Tidak dapat terhubung ke server.");
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', height: 120),
              const SizedBox(height: 20),
              const Text("Welcome Edu Flip", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Silakan masuk untuk melanjutkan", style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              const SizedBox(height: 40),
              TextField(controller: _usernameController, decoration: const InputDecoration(labelText: "Username", prefixIcon: Icon(Icons.person_outline), border: OutlineInputBorder())),
              const SizedBox(height: 20),
              TextField(controller: _passwordController, obscureText: _isObscure, decoration: InputDecoration(labelText: "Password", prefixIcon: const Icon(Icons.lock_outline), border: const OutlineInputBorder(), suffixIcon: IconButton(icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _isObscure = !_isObscure)))),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15), backgroundColor: Colors.blue, foregroundColor: Colors.white),
                  child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)) : const Text("Login", style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Belum punya akun?"),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage())),
                    child: const Text("Daftar di sini"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

