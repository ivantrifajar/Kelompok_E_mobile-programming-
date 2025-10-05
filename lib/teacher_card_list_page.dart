import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_config.dart';
import 'teacher_add_edit_card_page.dart';

class TeacherCardListPage extends StatefulWidget {
  final String topicId;
  final String topicName;
  const TeacherCardListPage({super.key, required this.topicId, required this.topicName});

  @override
  State<TeacherCardListPage> createState() => _TeacherCardListPageState();
}

class _TeacherCardListPageState extends State<TeacherCardListPage> {
    List<dynamic> _flashcards = [];
    bool _isLoading = true;

    @override
    void initState() {
      super.initState();
      _fetchFlashcards();
    }

    Future<void> _fetchFlashcards() async {
      setState(() { _isLoading = true; });
      try {
        final response = await http.get(Uri.parse('$baseUrl/flashcards/${widget.topicId}'));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['success'] == true && mounted) {
            setState(() {
              _flashcards = data['flashcards'];
              _isLoading = false;
            });
          }
        }
      } catch (e) {
        // handle error
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }

    Future<void> _deleteCard(String cardId) async {
        try {
            final response = await http.delete(Uri.parse('$baseUrl/flashcards/$cardId'));
            final data = jsonDecode(response.body);
            if(mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
                if(data['success'] == true) _fetchFlashcards();
            }
        } catch(e) {
            // handle error
        }
    }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.topicName)),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => TeacherAddEditCardPage(topicId: widget.topicId)))
            .then((_) => _fetchFlashcards());
        },
        child: const Icon(Icons.add),
        tooltip: 'Tambah Kartu',
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _fetchFlashcards,
            child: _flashcards.isEmpty
              ? const Center(child: Text("Belum ada kartu di topik ini."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _flashcards.length,
                  itemBuilder: (context, index) {
                    final card = _flashcards[index];
                    return Card(
                      child: ListTile(
                        title: Text(card['question']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => TeacherAddEditCardPage(topicId: widget.topicId, cardData: card)))
                                  .then((_) => _fetchFlashcards());
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteCard(card['_id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
    );
  }
}

