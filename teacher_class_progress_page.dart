import 'package:flutter/material.dart';
import 'teacher_student_detail_progress_page.dart'; // Impor halaman detail

class TeacherClassProgressPage extends StatelessWidget {
  final String className;
  const TeacherClassProgressPage({super.key, required this.className});

  @override
  Widget build(BuildContext context) {
    // Data siswa ini nantinya akan diambil dari database berdasarkan kelas
    final List<Map<String, dynamic>> students = [
      {"name": "Anissa Armaylita", "color": Colors.blue},
      {"name": "Ivan Tri Fajar", "color": Colors.orange},
      {"name": "Selara Waruwu", "color": Colors.blue},
    ];

    return Scaffold(
      appBar: AppBar(title: Text("Progres Kelas $className")),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];
          return Card(
            color: student['color'],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student['name'], style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                         Navigator.push(
                           context,
                           MaterialPageRoute(builder: (context) => TeacherStudentDetailProgressPage(studentName: student['name'])),
                         );
                      },
                      child: const Text("Lihat Progress ->", style: TextStyle(color: Colors.white70)),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
