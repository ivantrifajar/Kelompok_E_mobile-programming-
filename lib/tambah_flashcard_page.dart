// Mengimpor paket-paket yang diperlukan dari Flutter dan Dart.
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_config.dart'; // Mengimpor konfigurasi base URL API.

// TambahFlashcardPage adalah StatefulWidget karena UI-nya bisa berubah (misalnya, saat dialog ditampilkan).
class TambahFlashcardPage extends StatefulWidget {
  const TambahFlashcardPage({super.key});
  @override
  State<TambahFlashcardPage> createState() => _TambahFlashcardPageState();
}

// _TambahFlashcardPageState berisi state dan logika untuk halaman TambahFlashcardPage.
class _TambahFlashcardPageState extends State<TambahFlashcardPage> {
  // Controller untuk mengelola input teks pada dialog "Buat Topik Baru".
  final TextEditingController _topicNameController = TextEditingController();

  // Fungsi untuk menampilkan dialog pembuatan topik baru.
  void _showCreateTopicDialog() {
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

  // Fungsi asinkron untuk membuat topik baru dengan mengirim data ke API.
  Future<void> _createTopic() async {
    final topicName = _topicNameController.text.trim();
    if (topicName.isEmpty) return; // Jangan lakukan apa-apa jika nama topik kosong.
    
    Navigator.pop(context); // Tutup dialog setelah tombol "Buat" ditekan.

    try {
      // Mengirim POST request ke endpoint API untuk membuat topik flashcard.
      final response = await http.post(
        Uri.parse("$baseUrl/flashcard-topics"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"topicName": topicName}),
      );

      if (!mounted) return;
      final data = jsonDecode(response.body);
      // Menampilkan notifikasi (SnackBar) dengan pesan dari server.
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
      // Jika berhasil, bersihkan field input.
      if(data['success'] == true) _topicNameController.clear();

    } catch (e) {
      // Menangani error koneksi.
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Koneksi error.")));
    }
  }

  @override
  // dispose dipanggil saat widget akan dihancurkan.
  void dispose() {
    // Membersihkan controller untuk mencegah kebocoran memori.
    _topicNameController.dispose();
    super.dispose();
  }

  @override
  // Method build untuk membangun antarmuka pengguna (UI).
  Widget build(BuildContext context) {
    // Mendefinisikan gaya tombol agar konsisten dan berbentuk seperti kapsul/pil.
    final ButtonStyle pillButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF00B8D4), // Warna latar belakang cyan terang.
      foregroundColor: Colors.white, // Warna teks putih.
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      shape: const StadiumBorder(), // Menggunakan StadiumBorder untuk mendapatkan bentuk kapsul.
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Flashcard"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Memposisikan item di tengah secara vertikal.
          crossAxisAlignment: CrossAxisAlignment.stretch, // Membuat item memenuhi lebar layar.
          children: [
            // Tombol pertama untuk membuat topik baru.
            ElevatedButton.icon(
              onPressed: _showCreateTopicDialog,
              icon: const Icon(Icons.add, size: 20),
              label: const Text("Topik"),
              style: pillButtonStyle, // Menerapkan gaya tombol yang sudah didefinisikan.
            ),
            const SizedBox(height: 16), // Memberi jarak antar tombol.
            // Tombol kedua untuk melihat daftar flashcard.
            ElevatedButton(
              onPressed: () {
                // TODO: Implementasi navigasi ke halaman daftar flashcard.
              },
              style: pillButtonStyle, // Menerapkan gaya tombol yang sama.
              child: const Text("Daftar Flashcard"),
            ),
          ],
        ),
      ),
    );
  }
}
