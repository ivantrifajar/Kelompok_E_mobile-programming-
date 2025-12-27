import 'package:flutter/material.dart';
import '../../services/user_service.dart';
import '../../services/materi_service.dart';

class MateriListGuruPage extends StatefulWidget {
  final String kelasId;
  final String kelasName;
  final String tahunAjaran;

  const MateriListGuruPage({
    super.key,
    required this.kelasId,
    required this.kelasName,
    required this.tahunAjaran,
  });

  @override
  State<MateriListGuruPage> createState() => _MateriListGuruPageState();
}

class _MateriListGuruPageState extends State<MateriListGuruPage> {
  final MateriService _materiService = MateriService();
  final UserService _userService = UserService();
  
  List<Map<String, dynamic>> _materiList = [];
  bool _isLoading = true;
  String? _currentUserId;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadMateriData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _userService.getUserData();
      final userId = userData['userId'];
      
      setState(() {
        _currentUserId = userId;
      });
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _loadMateriData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _materiService.getMateriByKelas(
        widget.kelasId,
        search: _searchQuery,
      );

      print('=== MATERI GURU LIST DEBUG ===');
      print('Result: $result');

      if (result['success'] == true && mounted) {
        setState(() {
          _materiList = List<Map<String, dynamic>>.from(result['data'] ?? []);
          _isLoading = false;
        });
      } else {
        setState(() {
          _materiList = [];
          _isLoading = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Gagal memuat materi'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error loading materi: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showAddMateriDialog() async {
    if (_currentUserId == null) return;

    final judulController = TextEditingController();
    final deskripsiController = TextEditingController();
    final kontenController = TextEditingController();
    String selectedType = 'teks';

    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Materi Baru'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: judulController,
                decoration: const InputDecoration(
                  labelText: 'Judul Materi *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: deskripsiController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi (Opsional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tipe Materi',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'teks', child: Text('Teks')),
                  DropdownMenuItem(value: 'video', child: Text('Video')),
                  DropdownMenuItem(value: 'dokumen', child: Text('Dokumen')),
                  DropdownMenuItem(value: 'link', child: Text('Link')),
                  DropdownMenuItem(value: 'gambar', child: Text('Gambar')),
                ],
                onChanged: (value) {
                  selectedType = value ?? 'teks';
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: kontenController,
                decoration: const InputDecoration(
                  labelText: 'Konten Materi *',
                  border: OutlineInputBorder(),
                  hintText: 'Masukkan konten materi...',
                ),
                maxLines: 6,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (judulController.text.trim().isEmpty ||
                  kontenController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Judul dan konten materi wajib diisi'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(context, true);

              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              // Create materi
              final createResult = await _materiService.createMateri(
                judul: judulController.text.trim(),
                konten: kontenController.text.trim(),
                kelasId: widget.kelasId,
                guruId: _currentUserId!,
                deskripsi: deskripsiController.text.trim().isNotEmpty
                    ? deskripsiController.text.trim()
                    : null,
                tipeMateri: selectedType,
              );

              // Hide loading
              if (mounted) Navigator.pop(context);

              if (mounted) {
                if (createResult['success'] == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(createResult['message'] ?? 'Materi berhasil ditambahkan'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadMateriData(); // Refresh list
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(createResult['message'] ?? 'Gagal menambahkan materi'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              foregroundColor: Colors.white,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    judulController.dispose();
    deskripsiController.dispose();
    kontenController.dispose();
  }

  Future<void> _showEditMateriDialog(Map<String, dynamic> materi) async {
    if (_currentUserId == null) return;

    final judulController = TextEditingController(text: materi['judul']?.toString() ?? '');
    final deskripsiController = TextEditingController(text: materi['deskripsi']?.toString() ?? '');
    final kontenController = TextEditingController(text: materi['konten']?.toString() ?? '');
    String selectedType = materi['tipe_materi']?.toString() ?? 'teks';

    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Materi'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: judulController,
                decoration: const InputDecoration(
                  labelText: 'Judul Materi *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: deskripsiController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi (Opsional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tipe Materi',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'teks', child: Text('Teks')),
                  DropdownMenuItem(value: 'video', child: Text('Video')),
                  DropdownMenuItem(value: 'dokumen', child: Text('Dokumen')),
                  DropdownMenuItem(value: 'link', child: Text('Link')),
                  DropdownMenuItem(value: 'gambar', child: Text('Gambar')),
                ],
                onChanged: (value) {
                  selectedType = value ?? 'teks';
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: kontenController,
                decoration: const InputDecoration(
                  labelText: 'Konten Materi *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 6,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (judulController.text.trim().isEmpty ||
                  kontenController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Judul dan konten materi wajib diisi'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(context, true);

              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              // Update materi
              final updateResult = await _materiService.updateMateri(
                materiId: materi['_id']?.toString() ?? '',
                guruId: _currentUserId!,
                judul: judulController.text.trim(),
                konten: kontenController.text.trim(),
                deskripsi: deskripsiController.text.trim().isNotEmpty
                    ? deskripsiController.text.trim()
                    : null,
                tipeMateri: selectedType,
              );

              // Hide loading
              if (mounted) Navigator.pop(context);

              if (mounted) {
                if (updateResult['success'] == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(updateResult['message'] ?? 'Materi berhasil diupdate'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadMateriData(); // Refresh list
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(updateResult['message'] ?? 'Gagal mengupdate materi'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              foregroundColor: Colors.white,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );

    judulController.dispose();
    deskripsiController.dispose();
    kontenController.dispose();
  }

  Future<void> _deleteMateri(String materiId, String judul) async {
    if (_currentUserId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Materi'),
        content: Text('Apakah Anda yakin ingin menghapus materi "$judul"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final result = await _materiService.deleteMateri(
        materiId: materiId,
        guruId: _currentUserId!,
      );

      // Hide loading
      if (mounted) Navigator.pop(context);

      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Materi berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );
          _loadMateriData(); // Refresh list
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Gagal menghapus materi'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _performSearch() {
    setState(() {
      _searchQuery = _searchController.text.trim();
    });
    _loadMateriData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kelola Materi',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              '${widget.kelasName} - ${widget.tahunAjaran}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _showAddMateriDialog,
            tooltip: 'Tambah Materi',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari materi...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onSubmitted: (_) => _performSearch(),
            ),
          ),
          // Statistics Card
          if (!_isLoading && _materiList.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF1976D2).withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    icon: Icons.book,
                    label: 'Total Materi',
                    value: '${_materiList.length}',
                  ),
                  _buildStatItem(
                    icon: Icons.visibility,
                    label: 'Total Views',
                    value: '${_materiList.fold<int>(0, (sum, item) => sum + (item['views'] as int? ?? 0))}',
                  ),
                ],
              ),
            ),
          // Materi List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF1976D2),
                    ),
                  )
                : _materiList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.book_outlined,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              _searchQuery.isNotEmpty ? 'Materi tidak ditemukan' : 'Belum Ada Materi',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _searchQuery.isNotEmpty 
                                  ? 'Coba kata kunci lain'
                                  : 'Tambahkan materi pertama untuk kelas ini',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _showAddMateriDialog,
                              icon: const Icon(Icons.add),
                              label: const Text('Tambah Materi'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1976D2),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadMateriData,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _materiList.length,
                          itemBuilder: (context, index) {
                            final materi = _materiList[index];
                            return _buildMateriCard(materi, index + 1);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: const Color(0xFF1976D2),
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1976D2),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildMateriCard(Map<String, dynamic> materi, int urutan) {
    final judul = materi['judul']?.toString() ?? 'Materi';
    final deskripsi = materi['deskripsi']?.toString() ?? '';
    final kontenString = materi['konten']?.toString() ?? '';
    final kontenPreview = materi['konten_preview']?.toString() ?? 
                         (kontenString.length > 100 
                             ? kontenString.substring(0, 100) + '...'
                             : kontenString);
    final tipeMateri = materi['tipe_materi']?.toString() ?? 'teks';
    final views = materi['views'] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1976D2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      urutan.toString(),
                      style: const TextStyle(
                        color: Color(0xFF1976D2),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        judul,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (deskripsi.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          deskripsi,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditMateriDialog(materi);
                    } else if (value == 'delete') {
                      _deleteMateri(materi['_id']?.toString() ?? '', judul);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Hapus'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Content Preview
            if (kontenPreview.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  kontenPreview,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 12),
            ],
            // Footer
            Row(
              children: [
                Icon(
                  _getTypeIcon(tipeMateri),
                  size: 16,
                  color: const Color(0xFF1976D2),
                ),
                const SizedBox(width: 4),
                Text(
                  _getTypeLabel(tipeMateri),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF1976D2),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.visibility,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  '$views views',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(String tipeMateri) {
    switch (tipeMateri.toLowerCase()) {
      case 'video':
        return Icons.play_circle_outline;
      case 'dokumen':
        return Icons.description;
      case 'link':
        return Icons.link;
      case 'gambar':
        return Icons.image;
      default:
        return Icons.article;
    }
  }

  String _getTypeLabel(String tipeMateri) {
    switch (tipeMateri.toLowerCase()) {
      case 'video':
        return 'Video';
      case 'dokumen':
        return 'Dokumen';
      case 'link':
        return 'Link';
      case 'gambar':
        return 'Gambar';
      default:
        return 'Teks';
    }
  }
}
