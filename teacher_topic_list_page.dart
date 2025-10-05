import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_config.dart';
import 'teacher_card_list_page.dart';

class TeacherTopicListPage extends StatefulWidget {
  final String classId;
  final String className;
  const TeacherTopicListPage({super.key, required this.classId, required this.className});

  @override
  State<TeacherTopicListPage> createState() => _TeacherTopicListPageState();
}

class _TeacherTopicListPageState extends State<TeacherTopicListPage> {
  List<dynamic> _topics = [];
  bool _isLoading = true;
  final TextEditingController _topicNameController = TextEditingController();

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
      // Handle error
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createTopic() async {
    final topicName = _topicNameController.text.trim();
    if (topicName.isEmpty) return;
    Navigator.pop(context);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/topics'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'topicName': topicName, 'classId': widget.classId}),
      );
      final data = jsonDecode(response.body);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
        if(data['success'] == true) {
          _fetchTopics();
          _topicNameController.clear();
        }
      }
    } catch (e) {
      // handle error
    }
  }
  
  void _showAddTopicDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Buat Topik Baru"),
        content: TextField(controller: _topicNameController, decoration: const InputDecoration(hintText: "Nama Topik")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(onPressed: _createTopic, child: const Text("Buat")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Daftar Flashcard di ${widget.className}"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTopicDialog,
        child: const Icon(Icons.add),
        tooltip: 'Tambah Topik',
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
          onRefresh: _fetchTopics,
          child: _topics.isEmpty
            ? const Center(child: Text("Belum ada topik. Tekan tombol '+' untuk membuat."))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _topics.length,
                itemBuilder: (context, index) {
                  final topic = _topics[index];
                  return Card(
                     color: (index % 3 == 0) ? Colors.blue.shade300 : (index % 3 == 1) ? Colors.orange.shade300 : Colors.green.shade300,
                    child: ListTile(
                      title: Text(topic['topicName'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => TeacherCardListPage(topicId: topic['_id'], topicName: topic['topicName'])))
                          .then((_) => _fetchTopics());
                      },
                    ),
                  );
                },
              ),
        ),
    );
  }
}

