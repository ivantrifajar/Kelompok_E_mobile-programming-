import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_config.dart';

class TeacherAddEditCardPage extends StatefulWidget {
  final String topicId;
  final Map<String, dynamic>? cardData; // Nullable for adding new card

  const TeacherAddEditCardPage({super.key, required this.topicId, this.cardData});

  @override
  State<TeacherAddEditCardPage> createState() => _TeacherAddEditCardPageState();
}

class _TeacherAddEditCardPageState extends State<TeacherAddEditCardPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.cardData != null) {
      _isEditing = true;
      _questionController.text = widget.cardData!['question'];
      _answerController.text = widget.cardData!['answer'];
    }
  }

  Future<void> _saveFlashcard() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });

      final url = _isEditing
          ? Uri.parse('$baseUrl/flashcards/${widget.cardData!['_id']}')
          : Uri.parse('$baseUrl/flashcards');

      final body = jsonEncode({
        'question': _questionController.text,
        'answer': _answerController.text,
        'topicId': widget.topicId,
      });

      try {
        final response = _isEditing
            ? await http.put(url, headers: {'Content-Type': 'application/json'}, body: body)
            : await http.post(url, headers: {'Content-Type': 'application/json'}, body: body);
        
        final data = jsonDecode(response.body);
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
          if (data['success'] == true) {
            Navigator.pop(context);
          }
        }
      } catch (e) {
        // handle error
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? "Edit Kartu" : "+ Topik")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(
                  labelText: "Judul Topik (Pertanyaan)",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFFBBDEFB)
                ),
                validator: (value) => value!.isEmpty ? 'Judul tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _answerController,
                decoration: const InputDecoration(
                  labelText: "Materi (Jawaban)",
                   border: OutlineInputBorder(),
                   filled: true,
                   fillColor: Color(0xFFFFE0B2)
                ),
                maxLines: 5,
                validator: (value) => value!.isEmpty ? 'Materi tidak boleh kosong' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveFlashcard,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isLoading ? const CircularProgressIndicator() : const Text("Simpan"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

