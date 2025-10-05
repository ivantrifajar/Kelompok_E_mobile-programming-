import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_config.dart';
import 'student_class_detail_page.dart'; // Pastikan impor ini ada

class StudentKelasPage extends StatefulWidget {
  final String username;
  const StudentKelasPage({super.key, required this.username});

  @override
  State<StudentKelasPage> createState() => _StudentKelasPageState();
}

class _StudentKelasPageState extends State<StudentKelasPage> {
  List<dynamic> _enrolledClasses = [];
  bool _isLoading = true;
  final TextEditingController _classCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMyClasses();
  }

  Future<void> _fetchMyClasses() async {
    setState(() { _isLoading = true; });
    try {
      final response = await http.get(Uri.parse("$baseUrl/my-classes/${widget.username}"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if(data['success'] == true && mounted) {
          setState(() {
            _enrolledClasses = data['classes'];
          });
        }
      }
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal memuat kelas.")));
    } finally {
      if(mounted) setState(() { _isLoading = false; });
    }
  }

  Future<void> _joinClass() async {
    final classCode = _classCodeController.text.trim();
    if (classCode.isEmpty) return;
    
    Navigator.pop(context);

    try {
        final response = await http.post(
            Uri.parse('$baseUrl/join-class'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'username': widget.username, 'classCode': classCode}),
        );
        final data = jsonDecode(response.body);
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
            if (data['success'] == true) {
                _fetchMyClasses(); 
            }
        }
    } catch (e) {
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Koneksi Error.")));
    }
    _classCodeController.clear();
  }

  void _showJoinClassDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Gabung Kelas Baru"),
        content: TextField(controller: _classCodeController, decoration: const InputDecoration(hintText: "Masukkan Kode Kelas")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(onPressed: _joinClass, child: const Text("Gabung")),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _classCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kelas Saya"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _enrolledClasses.isEmpty
                    ? const Center(child: Text("Anda belum bergabung dengan kelas manapun."))
                    : ListView.builder(
                        itemCount: _enrolledClasses.length,
                        itemBuilder: (context, index) {
                          final className = _enrolledClasses[index]['className'];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => StudentClassDetailPage(className: className)));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00B8D4),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: const StadiumBorder(),
                              ),
                              child: Text(className, style: const TextStyle(fontSize: 16)),
                            ),
                          );
                        },
                      ),
                ),
                const Text(
                  "Belum Punya Kelas?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _showJoinClassDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text("Gabung", style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
    );
  }
}

