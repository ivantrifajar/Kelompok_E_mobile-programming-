import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_config.dart';
import 'flashcard_view_page.dart';

class StudentTopicListPage extends StatefulWidget {
  final String classId;
  final String className;
  const StudentTopicListPage({super.key, required this.classId, required this.className});

  @override
  State<StudentTopicListPage> createState() => _StudentTopicListPageState();
}

class _StudentTopicListPageState extends State<StudentTopicListPage> {
  List<dynamic> _topics = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTopics();
  }

  Future<void> _fetchTopics() async {
    setState(() { _isLoading = true; });
    try {
      final response = await http.get(Uri.parse('$baseUrl/topics/${widget.classId}'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && mounted) {
          setState(() {
            _topics = data['topics'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal memuat topik.")));
      }
    }
  }
  
  Future<void> _viewFlashcards(String topicId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/flashcards/$topicId'));
      final data = jsonDecode(response.body);
      if (data['success'] == true && mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => FlashcardViewPage(flashcards: data['flashcards'])));
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'] ?? "Gagal memuat kartu.")));
      }
    } catch (e) {
       if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Koneksi Error.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pilih Topik di ${widget.className}")),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
          onRefresh: _fetchTopics,
          child: _topics.isEmpty
            ? const Center(child: Text("Guru belum menambahkan topik di kelas ini."))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _topics.length,
                itemBuilder: (context, index) {
                  final topic = _topics[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(topic['topicName']),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _viewFlashcards(topic['_id']),
                    ),
                  );
                },
              ),
        ),
    );
  }
}

