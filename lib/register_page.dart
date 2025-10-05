import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_config.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedRole = 'Siswa';
  bool _isObscure = true;
  bool _isLoading = false;

  void _showDialog(String title, String content) {
    if (!mounted) return;
    showDialog(context: context, builder: (_) => AlertDialog(title: Text(title), content: Text(content), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))]));
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isLoading) return;
    setState(() { _isLoading = true; });

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": _usernameController.text.trim(),
          "email": _emailController.text.trim(),
          "password": _passwordController.text.trim(),
          "role": _selectedRole,
        }),
      ).timeout(const Duration(seconds: 15));
      
      if(!mounted) return;

      final data = jsonDecode(response.body);
      if(response.statusCode == 201 && data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'] ?? 'Registrasi berhasil! Silakan login.'), backgroundColor: Colors.green,));
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
      } else {
          _showDialog("Registrasi Gagal", data['message'] ?? "Terjadi kesalahan.");
      }
    } catch (e) {
      if (mounted) _showDialog("Koneksi Error", "Tidak dapat terhubung ke server.");
    } finally {
      if(mounted) setState(() { _isLoading = false; });
    }
  }
  
  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Akun Baru")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.person_add_alt_1, size: 80, color: Colors.blue),
                const SizedBox(height: 20),
                const Text("Buat Akun Edu Flip", textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 40),
                TextFormField(controller: _usernameController, validator: (val) => val!.isEmpty ? 'Username tidak boleh kosong' : null, decoration: const InputDecoration(labelText: "Username", prefixIcon: Icon(Icons.person), border: OutlineInputBorder())),
                const SizedBox(height: 20),
                TextFormField(controller: _emailController, keyboardType: TextInputType.emailAddress, validator: (val) => val!.isEmpty ? 'Email tidak boleh kosong' : null, decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email), border: OutlineInputBorder())),
                const SizedBox(height: 20),
                TextFormField(controller: _passwordController, obscureText: _isObscure, validator: (val) => val!.isEmpty ? 'Password tidak boleh kosong' : null, decoration: InputDecoration(labelText: "Password", prefixIcon: const Icon(Icons.lock), border: const OutlineInputBorder(), suffixIcon: IconButton(icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _isObscure = !_isObscure)))),
                const SizedBox(height: 20),
                
                const Text("Daftar sebagai:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                Row(
                  children: [
                    Expanded(child: RadioListTile<String>(title: const Text('Siswa'), value: 'Siswa', groupValue: _selectedRole, onChanged: (value) => setState(() => _selectedRole = value!))),
                    Expanded(child: RadioListTile<String>(title: const Text('Guru'), value: 'Guru', groupValue: _selectedRole, onChanged: (value) => setState(() => _selectedRole = value!))),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15), backgroundColor: Colors.blue, foregroundColor: Colors.white),
                  child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white)) : const Text("Daftar"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

