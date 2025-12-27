import 'package:flutter/material.dart';
import 'tambah-flashcaard.dart';
import '../../services/flashcard_service.dart';

class KelolaFlashcardPage extends StatefulWidget {
  const KelolaFlashcardPage({super.key});

  @override
  State<KelolaFlashcardPage> createState() => _KelolaFlashcardPageState();
}

class _KelolaFlashcardPageState extends State<KelolaFlashcardPage> {
  final _flashcardService = FlashcardService();
  List<Map<String, dynamic>> _flashcardList = [];
  bool _isLoading = false;
  String _searchQuery = '';
  final _searchController = TextEditingController();
  
  // TODO: Get actual guru_id from user session/auth
  // For now using a placeholder - you should replace this with actual logged-in teacher ID
  final String _guruId = '68e630667aa27040bcb95fed';

  @override
  void initState() {
    super.initState();
    _loadFlashcards();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFlashcards() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _flashcardService.getAllFlashcards(
        guruId: _guruId,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (result['success'] == true) {
            final dataList = result['data'] as List? ?? [];
            _flashcardList = dataList.map<Map<String, dynamic>>((flashcard) {
              final flashcardMap = flashcard as Map<String, dynamic>? ?? {};
              return {
                '_id': flashcardMap['_id']?.toString() ?? '',
                'judul': flashcardMap['judul']?.toString() ?? '',
                'topik': flashcardMap['topik']?.toString() ?? '',
                'deskripsi': flashcardMap['deskripsi']?.toString() ?? '',
                'jumlahKartu': flashcardMap['jumlahKartu'] ?? 0,
                'kelas_id': flashcardMap['kelas_id'],
                'guru_id': flashcardMap['guru_id'],
                'isActive': flashcardMap['isActive'] ?? true,
                'totalViews': flashcardMap['totalViews'] ?? 0,
                'totalStudents': flashcardMap['totalStudents'] ?? 0,
                'createdAt': flashcardMap['createdAt']?.toString() ?? '',
                'updatedAt': flashcardMap['updatedAt']?.toString() ?? '',
                'kartu': flashcardMap['kartu'] ?? [],
                'color': Colors.primaries[_flashcardList.length % Colors.primaries.length],
              };
            }).toList();
          } else {
            _flashcardList = [];
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    result['message'] ?? 'Gagal memuat flashcard',
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
          _isLoading = false;
          _flashcardList = [];
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

  Future<void> _refreshFlashcards() async {
    await _loadFlashcards();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    // Debounce search
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchQuery == query) {
        _loadFlashcards();
      }
    });
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
          'Kelola Flashcard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              _showSearchDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshFlashcards,
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1976D2),
                  Color(0xFF64B5F6),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Stats Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.style,
                          title: 'Total Flashcard',
                          value: '${_flashcardList.length}',
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.quiz,
                          title: 'Total Kartu',
                          value: '${_flashcardList.fold(0, (sum, flashcard) => sum + (flashcard['jumlahKartu'] as int))}',
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Button Buat Flashcard Baru
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TambahFlashcardPage(),
                          ),
                        );
                        
                        // If flashcard was successfully created, refresh the list
                        if (result != null && result is Map<String, dynamic> && result['success'] == true) {
                          _refreshFlashcards();
                        }
                      },
                      icon: const Icon(Icons.add_circle_outline, size: 24),
                      label: const Text(
                        'Buat Flashcard Baru',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1976D2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Daftar Flashcard
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: _refreshFlashcards,
                    child: _flashcardList.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.style_outlined,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Belum ada flashcard',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Tap tombol "+" untuk membuat flashcard baru',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: _flashcardList.length,
                            itemBuilder: (context, index) {
                              final flashcard = _flashcardList[index];
                              return _buildFlashcardCard(
                                flashcard: flashcard,
                                onTap: () {
                                  _showDetailFlashcardDialog(flashcard);
                                },
                                onEdit: () {
                                  _showEditFlashcardDialog(flashcard, index);
                                },
                                onDelete: () {
                                  _showDeleteConfirmation(flashcard['judul'], flashcard['_id']);
                                },
                                onToggleActive: () {
                                  _toggleActiveStatus(flashcard['_id'], index);
                                },
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcardCard({
    required Map<String, dynamic> flashcard,
    required VoidCallback onTap,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    required VoidCallback onToggleActive,
  }) {
    final String judul = flashcard['judul'] ?? '';
    final String deskripsi = flashcard['deskripsi'] ?? '';
    final int jumlahKartu = flashcard['jumlahKartu'] ?? 0;
    final String topik = flashcard['topik'] ?? '';
    final bool isActive = flashcard['isActive'] ?? true;
    final int totalViews = flashcard['totalViews'] ?? 0;
    final int totalStudents = flashcard['totalStudents'] ?? 0;
    final String createdAt = flashcard['createdAt'] ?? '';
    final String updatedAt = flashcard['updatedAt'] ?? '';
    final Color color = flashcard['color'] ?? Colors.blue;
    
    // Format dates
    final String tanggalDibuat = _formatDate(createdAt);
    final String terakhirDiupdate = _formatDate(updatedAt);
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Icon Flashcard
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.style,
                        color: color,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 15),
                    // Info Flashcard
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            judul,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            deskripsi,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isActive ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        isActive ? 'Aktif' : 'Nonaktif',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isActive ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Action Buttons
                    PopupMenuButton(
                      icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: Colors.blue.shade700, size: 20),
                              const SizedBox(width: 10),
                              const Text('Edit'),
                            ],
                          ),
                          onTap: () {
                            Future.delayed(Duration.zero, onEdit);
                          },
                        ),
                        PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(
                                isActive ? Icons.visibility_off : Icons.visibility,
                                color: Colors.orange.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(isActive ? 'Nonaktifkan' : 'Aktifkan'),
                            ],
                          ),
                          onTap: () {
                            Future.delayed(Duration.zero, onToggleActive);
                          },
                        ),
                        PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red.shade700, size: 20),
                              const SizedBox(width: 10),
                              const Text('Hapus'),
                            ],
                          ),
                          onTap: () {
                            Future.delayed(Duration.zero, onDelete);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                // Divider
                Divider(color: Colors.grey.shade200),
                const SizedBox(height: 15),
                // Detail Info
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        Icons.quiz,
                        '$jumlahKartu Kartu',
                        color,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        Icons.topic,
                        topik.isNotEmpty ? topik : 'Topik',
                        color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        Icons.visibility,
                        '$totalViews Views',
                        color,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        Icons.people,
                        '$totalStudents Siswa',
                        color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildInfoItem(
                  Icons.calendar_today,
                  'Dibuat: $tanggalDibuat',
                  color,
                ),
                const SizedBox(height: 10),
                _buildInfoItem(
                  Icons.access_time,
                  'Update: $terakhirDiupdate',
                  color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString.substring(0, 10); // Fallback to first 10 characters
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text('Cari Flashcard'),
        content: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: 'Kata kunci',
            hintText: 'Masukkan judul, topik, atau deskripsi',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            prefixIcon: const Icon(Icons.search),
          ),
          onChanged: _onSearchChanged,
        ),
        actions: [
          TextButton(
            onPressed: () {
              _searchController.clear();
              _onSearchChanged('');
              Navigator.pop(context);
            },
            child: const Text('Reset'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
            ),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleActiveStatus(String flashcardId, int index) async {
    try {
      final result = await _flashcardService.toggleActiveStatus(flashcardId);
      
      if (result['success'] == true) {
        setState(() {
          _flashcardList[index]['isActive'] = !_flashcardList[index]['isActive'];
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Status berhasil diubah'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal mengubah status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showTambahFlashcardDialog() {
    final judulController = TextEditingController();
    final deskripsiController = TextEditingController();
    final kategoriController = TextEditingController();
    String selectedDifficulty = 'Mudah';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('Buat Flashcard Baru'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: judulController,
                  decoration: InputDecoration(
                    labelText: 'Judul Flashcard',
                    hintText: 'Contoh: Matematika Dasar',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.style),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: deskripsiController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Deskripsi',
                    hintText: 'Deskripsi singkat tentang flashcard',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.description),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: kategoriController,
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    hintText: 'Contoh: Matematika',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.category),
                  ),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: selectedDifficulty,
                  decoration: InputDecoration(
                    labelText: 'Tingkat Kesulitan',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.trending_up),
                  ),
                  items: ['Mudah', 'Menengah', 'Sulit'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setDialogState(() {
                      selectedDifficulty = newValue!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (judulController.text.isNotEmpty &&
                    deskripsiController.text.isNotEmpty &&
                    kategoriController.text.isNotEmpty) {
                  setState(() {
                    _flashcardList.add({
                      'judul': judulController.text,
                      'deskripsi': deskripsiController.text,
                      'jumlahKartu': 0,
                      'kategori': kategoriController.text,
                      'tingkatKesulitan': selectedDifficulty,
                      'tanggalDibuat': DateTime.now().toString().substring(0, 10),
                      'terakhirDipelajari': '-',
                      'color': Colors.primaries[_flashcardList.length % Colors.primaries.length],
                    });
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Flashcard berhasil ditambahkan!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
              ),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailFlashcardDialog(Map<String, dynamic> flashcard) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(flashcard['judul'] ?? ''),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Topik', flashcard['topik'] ?? ''),
              _buildDetailRow('Deskripsi', flashcard['deskripsi'] ?? ''),
              _buildDetailRow('Jumlah Kartu', '${flashcard['jumlahKartu'] ?? 0} Kartu'),
              _buildDetailRow('Status', flashcard['isActive'] == true ? 'Aktif' : 'Nonaktif'),
              _buildDetailRow('Total Views', '${flashcard['totalViews'] ?? 0}'),
              _buildDetailRow('Total Siswa', '${flashcard['totalStudents'] ?? 0}'),
              _buildDetailRow('Tanggal Dibuat', _formatDate(flashcard['createdAt'] ?? '')),
              _buildDetailRow('Terakhir Update', _formatDate(flashcard['updatedAt'] ?? '')),
              if (flashcard['kelas_id'] != null && flashcard['kelas_id'] is Map)
                _buildDetailRow('Kelas', '${flashcard['kelas_id']['nama'] ?? ''} (${flashcard['kelas_id']['tahun_ajaran'] ?? ''})')  ,
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
            ),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditFlashcardDialog(Map<String, dynamic> flashcard, int index) {
    // For now, show a simple message that edit functionality needs to be implemented
    // This would require a more complex form similar to TambahFlashcardPage
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text('Edit Flashcard'),
        content: const Text(
          'Fitur edit flashcard akan segera tersedia. Untuk saat ini, Anda dapat menghapus dan membuat ulang flashcard.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(String judulFlashcard, String flashcardId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text('Hapus Flashcard'),
        content: Text('Apakah Anda yakin ingin menghapus "$judulFlashcard"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteFlashcard(flashcardId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteFlashcard(String flashcardId) async {
    try {
      final result = await _flashcardService.deleteFlashcard(flashcardId);
      
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Flashcard berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
        _refreshFlashcards(); // Refresh the list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal menghapus flashcard'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}