import 'package:flutter/material.dart';
import 'teacher_class_progress_page.dart'; // Impor halaman selanjutnya

class TeacherAllStudentsProgressPage extends StatelessWidget {
  const TeacherAllStudentsProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Data kelas ini nantinya akan diambil dari database
    final List<String> classes = ["Matematika XII", "Fisika XI", "Kimia X"];

    return Scaffold(
      appBar: AppBar(title: const Text("Pilih Kelas untuk Melihat Progres")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: classes.length,
        itemBuilder: (context, index) {
          final className = classes[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(className),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TeacherClassProgressPage(className: className)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
