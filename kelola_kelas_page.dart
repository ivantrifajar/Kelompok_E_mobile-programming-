import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_config.dart';

class KelolaKelasPage extends StatefulWidget {
  final String username;
  const KelolaKelasPage({super.key, required this.username});

  @override
  State<KelolaKelasPage> createState() => _KelolaKelasPageState();
}

class _KelolaKelasPageState extends State<KelolaKelasPage> {
  final TextEditingController _classNameController = TextEditingController();

  void _showCreateClassDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Buat Kelas Baru"),
        content: TextField(controller: _classNameController, decoration: const InputDecoration(hintText: "Nama Kelas")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(onPressed: _createClass, child: const Text("Buat")),
        ],
      ),
    );
  }

  Future<void> _createClass() async {
    final className = _classNameController.text.trim();
    if (className.isEmpty) return;

    Navigator.pop(context); 

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/classes"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "className": className,
          "createdBy": widget.username,
        }),
      );

      if (!mounted) return;
      final data = jsonDecode(response.body);
      
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
              title: Text(data['success'] == true ? "Kelas Berhasil Dibuat" : "Gagal"),
              content: Text(data['message']),
              actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
          ),
      );
      if(data['success'] == true) _classNameController.clear();

    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Koneksi error.")));
    }
  }

  @override
  void dispose() {
    _classNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kelola Kelas")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _showCreateClassDialog,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text("Buat Kelas Baru", style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text("Daftar Siswa", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

