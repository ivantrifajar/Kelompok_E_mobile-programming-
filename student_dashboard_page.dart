import 'package:flutter/material.dart';
import 'student_kelas_page.dart';
import 'login_page.dart'; 

class StudentDashboardPage extends StatelessWidget {
  final String username;
  final String role;
  const StudentDashboardPage({super.key, required this.username, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Siswa"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(username),
              accountEmail: Text(role),
              currentAccountPicture: const CircleAvatar(
                child: Icon(Icons.person, size: 40),
              ),
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            // Tombol Kelas Saya
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => StudentKelasPage(username: username)));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B8D4), // Cyan
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: const Text("Kelas Saya"),
            ),
            const SizedBox(height: 16),
            // Tombol Flashcard
            ElevatedButton(
              onPressed: () {
                // Navigasi ke halaman flashcard siswa (belum dibuat)
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B8D4), // Cyan
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                 textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: const Text("Flashcard"),
            ),
          ],
        ),
      ),
    );
  }
}

