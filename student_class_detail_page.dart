import 'package:flutter/material.dart';
import 'student_flip_materi_page.dart';

class StudentClassDetailPage extends StatelessWidget {
  final String className;
  const StudentClassDetailPage({super.key, required this.className});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(className),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                 // Menghapus 'const' untuk memperbaiki error build
                 Navigator.push(context, MaterialPageRoute(builder: (context) => const StudentFlipMateriPage()));
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Aritmetika adalah cabang ilmu matematika yang mempelajari operasi-operasi dasar bilangan mulai dari penjumlahan, pengurangan, perkalian, dan pembagian, hingga penerapan hasilnya dalam kehidupan sehari-hari.",
                      style: TextStyle(color: Colors.grey.shade800, fontSize: 16, height: 1.5),
                    ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.bottomRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Next", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

