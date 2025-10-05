import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_config.dart';
import 'teacher_topic_list_page.dart';
import 'student_topic_list_page.dart';

class SelectClassFlashcardPage extends StatefulWidget {
  final String username;
  final String role;
  const SelectClassFlashcardPage({super.key, required this.username, required this.role});

  @override
  State<SelectClassFlashcardPage> createState() => _SelectClassFlashcardPageState();
}

class _SelectClassFlashcardPageState extends State<SelectClassFlashcardPage> {
  List<dynamic> _classes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  Future<void> _fetchClasses() async {
    // Tentukan endpoint berdasarkan peran pengguna
    String endpoint = widget.role == 'Guru' 
        ? '/teacher-classes/${widget.username}' 
        : '/my-classes/${widget.username}';
        
    try {
      final response = await http.get(Uri.parse('$baseUrl$endpoint'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && mounted) {
          setState(() {
            _classes = data['classes'];
            _isLoading = false;
          });
        } else {
           if (mounted) setState(() => _isLoading = false);
        }
      } else {
         if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal memuat daftar kelas.")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pilih Kelas")),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _classes.isEmpty
          ? const Center(child: Text("Anda belum memiliki atau tergabung dalam kelas manapun."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _classes.length,
              itemBuilder: (context, index) {
                final aClass = _classes[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(aClass['className']),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      if (widget.role == 'Guru') {
                        // Navigasi ke halaman manajemen topik untuk Guru
                        Navigator.push(context, MaterialPageRoute(builder: (context) => TeacherTopicListPage(classId: aClass['_id'], className: aClass['className'])));
                      } else {
                        // Navigasi ke halaman daftar topik untuk Siswa
                        Navigator.push(context, MaterialPageRoute(builder: (context) => StudentTopicListPage(classId: aClass['_id'], className: aClass['className'])));
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}