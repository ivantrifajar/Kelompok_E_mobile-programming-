import 'package:flutter/material.dart';
import '../../services/kelas_service.dart';
import '../../services/flashcard_service.dart';

class TambahFlashcardPage extends StatefulWidget {
  const TambahFlashcardPage({super.key});

  @override
  State<TambahFlashcardPage> createState() => _TambahFlashcardPageState();
}

class _TambahFlashcardPageState extends State<TambahFlashcardPage> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _topikController = TextEditingController();
  final _deskripsiController = TextEditingController();

  String? _selectedKelasId;
  final List<Map<String, String>> _flashcards = [];
  List<Map<String, dynamic>> _availableKelas = [];
  bool _isLoadingKelas = false;

  // Controllers for individual flashcard
  final _pertanyaanController = TextEditingController();
  final _jawabanController = TextEditingController();

  final _kelasService = KelasService();
  final _flashcardService = FlashcardService();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadAvailableKelas();
  }

  @override
  void dispose() {
    _judulController.dispose();
    _topikController.dispose();
    _deskripsiController.dispose();
    _pertanyaanController.dispose();
    _jawabanController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableKelas() async {
    setState(() {
      _isLoadingKelas = true;
    });

    try {
      final result = await _kelasService.getAllKelas();

      if (mounted) {
        setState(() {
          _isLoadingKelas = false;
          if (result['success'] == true) {
            final dataList = result['data'] as List? ?? [];
            _availableKelas = dataList.map<Map<String, dynamic>>((kelas) {
              final kelasMap = kelas as Map<String, dynamic>? ?? {};
              return {
                'id': kelasMap['_id']?.toString() ?? '',
                'nama': kelasMap['nama']?.toString() ?? '',
                'tahun_ajaran': kelasMap['tahun_ajaran']?.toString() ?? '',
              };
            }).toList();
          } else {
            _availableKelas = [];
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Gagal memuat kelas: ${result['message'] ?? 'Unknown error'}',
                  ),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingKelas = false;
          _availableKelas = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Buat Flashcard Baru',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: _isSaving 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.save, color: Colors.white),
            onPressed: _isSaving ? null : _saveFlashcard,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1976D2), Color(0xFF64B5F6)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    // Progress Indicator
                    Row(
                      children: [
                        Expanded(
                          child: _buildProgressCard(
                            icon: Icons.info_outline,
                            title: 'Info Dasar',
                            isActive: true,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildProgressCard(
                            icon: Icons.quiz,
                            title: 'Kartu (${_flashcards.length})',
                            isActive: false,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Information Section
                    _buildSectionTitle('Informasi Dasar'),
                    const SizedBox(height: 12),
                    _buildBasicInfoCard(),
                    const SizedBox(height: 20),

                    // Flashcard Content Section
                    _buildSectionTitle('Konten Flashcard'),
                    const SizedBox(height: 12),
                    _buildFlashcardContentCard(),
                    const SizedBox(height: 20),

                    // Added Flashcards List
                    if (_flashcards.isNotEmpty) ...[
                      _buildSectionTitle(
                        'Kartu yang Ditambahkan (${_flashcards.length})',
                      ),
                      const SizedBox(height: 12),
                      _buildFlashcardsList(),
                      const SizedBox(height: 20),
                    ],

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _saveFlashcard,
                        icon: _isSaving 
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.save, size: 24),
                        label: Text(
                          _isSaving ? 'Menyimpan...' : 'Simpan Flashcard',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isSaving ? Colors.grey : const Color(0xFF1976D2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard({
    required IconData icon,
    required String title,
    required bool isActive,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFF1976D2) : Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isActive ? const Color(0xFF1976D2) : Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1976D2),
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Judul
          TextFormField(
            controller: _judulController,
            decoration: InputDecoration(
              labelText: 'Judul Flashcard',
              hintText: 'Minimal 3 karakter, contoh: Matematika Dasar',
              prefixIcon: const Icon(Icons.title, color: Color(0xFF1976D2)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF1976D2),
                  width: 2,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Judul tidak boleh kosong';
              }
              if (value.length < 3) {
                return 'Judul minimal 3 karakter';
              }
              if (value.length > 200) {
                return 'Judul maksimal 200 karakter';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Topik
          TextFormField(
            controller: _topikController,
            decoration: InputDecoration(
              labelText: 'Topik/Materi',
              hintText: 'Minimal 3 karakter, contoh: Operasi Bilangan dan Aljabar',
              prefixIcon: const Icon(Icons.topic, color: Color(0xFF1976D2)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF1976D2),
                  width: 2,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Topik tidak boleh kosong';
              }
              if (value.length < 3) {
                return 'Topik minimal 3 karakter';
              }
              if (value.length > 200) {
                return 'Topik maksimal 200 karakter';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Deskripsi
          TextFormField(
            controller: _deskripsiController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Deskripsi',
              hintText: 'Minimal 10 karakter, deskripsi singkat tentang materi flashcard',
              prefixIcon: const Icon(
                Icons.description,
                color: Color(0xFF1976D2),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF1976D2),
                  width: 2,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Deskripsi tidak boleh kosong';
              }
              if (value.length < 10) {
                return 'Deskripsi minimal 10 karakter';
              }
              if (value.length > 1000) {
                return 'Deskripsi maksimal 1000 karakter';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Kelas
          _isLoadingKelas
              ? Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text('Memuat kelas...'),
                    ],
                  ),
                )
              : DropdownButtonFormField<String>(
                  value: _selectedKelasId,
                  decoration: InputDecoration(
                    labelText: 'Kelas',
                    hintText: 'Pilih Kelas',
                    prefixIcon: const Icon(
                      Icons.class_,
                      color: Color(0xFF1976D2),
                    ),
                    suffixIcon: _availableKelas.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.refresh, size: 20),
                            onPressed: _loadAvailableKelas,
                            tooltip: 'Refresh',
                          ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF1976D2),
                        width: 2,
                      ),
                    ),
                  ),
                  items: _availableKelas.isEmpty
                      ? []
                      : _availableKelas.map((kelas) {
                          final nama = kelas['nama'] ?? '';
                          final tahunAjaran = kelas['tahun_ajaran'] ?? '';
                          final displayText = tahunAjaran.isNotEmpty
                              ? '$nama ($tahunAjaran)'
                              : nama;
                          return DropdownMenuItem<String>(
                            value: kelas['id'],
                            child: Text(
                              displayText,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedKelasId = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Pilih kelas';
                    }
                    return null;
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildFlashcardContentCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.quiz, color: Colors.blue.shade700, size: 24),
              const SizedBox(width: 10),
              const Text(
                'Tambah Kartu Flashcard',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Pertanyaan/Depan Kartu
          TextFormField(
            controller: _pertanyaanController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Pertanyaan / Depan Kartu',
              hintText: 'Minimal 3 karakter, masukkan pertanyaan atau konten depan kartu',
              prefixIcon: const Icon(
                Icons.help_outline,
                color: Color(0xFF1976D2),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF1976D2),
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Jawaban/Belakang Kartu
          TextFormField(
            controller: _jawabanController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Jawaban / Belakang Kartu',
              hintText: 'Masukkan jawaban atau konten belakang kartu',
              prefixIcon: const Icon(
                Icons.lightbulb_outline,
                color: Color(0xFF1976D2),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF1976D2),
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),

          // Add Card Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addFlashcard,
              icon: const Icon(Icons.add, size: 20),
              label: const Text(
                'Tambah Kartu',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcardsList() {
    return Column(
      children: _flashcards.asMap().entries.map((entry) {
        int index = entry.key;
        Map<String, String> card = entry.value;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF1976D2),
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              card['pertanyaan']!.length > 50
                  ? '${card['pertanyaan']!.substring(0, 50)}...'
                  : card['pertanyaan']!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removeFlashcard(index),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pertanyaan:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(card['pertanyaan']!),
                    const SizedBox(height: 12),
                    const Text(
                      'Jawaban:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(card['jawaban']!),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _addFlashcard() {
    final pertanyaan = _pertanyaanController.text.trim();
    final jawaban = _jawabanController.text.trim();

    // Validasi sesuai dengan requirement backend
    if (pertanyaan.isEmpty || jawaban.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pertanyaan dan jawaban tidak boleh kosong!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (pertanyaan.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pertanyaan minimal 3 karakter!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (pertanyaan.length > 1000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pertanyaan maksimal 1000 karakter!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (jawaban.length > 1000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jawaban maksimal 1000 karakter!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Jika semua validasi lolos, tambahkan kartu
    setState(() {
      _flashcards.add({
        'pertanyaan': pertanyaan,
        'jawaban': jawaban,
      });
      _pertanyaanController.clear();
      _jawabanController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kartu berhasil ditambahkan!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _removeFlashcard(int index) {
    setState(() {
      _flashcards.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kartu berhasil dihapus!'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _saveFlashcard() async {
    if (_formKey.currentState!.validate() && _flashcards.isNotEmpty) {
      setState(() {
        _isSaving = true;
      });

      try {
        // TODO: Get actual guru_id from user session/auth
        // For now using a placeholder - you should replace this with actual logged-in teacher ID
        const String guruId = '68e630667aa27040bcb95fed'; // Replace with actual guru ID from login

        final result = await _flashcardService.createFlashcard(
          judul: _judulController.text,
          topik: _topikController.text,
          deskripsi: _deskripsiController.text,
          kelasId: _selectedKelasId!,
          guruId: guruId,
          kartu: _flashcards,
        );

        if (mounted) {
          setState(() {
            _isSaving = false;
          });

          if (result['success'] == true) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'Flashcard berhasil disimpan!'),
                backgroundColor: Colors.green,
              ),
            );

            // Return success result to previous screen
            Navigator.pop(context, {
              'success': true,
              'data': result['data'],
            });
          } else {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'Gagal menyimpan flashcard'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Terjadi kesalahan: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else if (_flashcards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tambahkan minimal satu kartu flashcard!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
