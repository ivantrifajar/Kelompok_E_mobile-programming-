import 'package:flutter/material.dart';
// Untuk grafik, Anda perlu menambahkan package `fl_chart` ke pubspec.yaml
// import 'package:fl_chart/fl_chart.dart';

class TeacherStudentDetailProgressPage extends StatelessWidget {
  final String studentName;
  const TeacherStudentDetailProgressPage({super.key, required this.studentName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Data Progress")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Kartu Informasi Siswa
            Card(
              color: Colors.orange,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Nama Siswa: $studentName", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const Text("Kelas: XII", style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Kartu Progress Topik
            const Card(
              color: Colors.blue,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Progress membaca topik", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
            // Placeholder untuk Grafik
            Container(
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  "Grafik akan ditampilkan di sini.\n\nTambahkan package 'fl_chart' untuk grafik.",
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
