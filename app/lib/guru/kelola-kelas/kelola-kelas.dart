import 'package:flutter/material.dart';
import 'tambah-kelas.dart';
import 'daftar-siswa.dart';
import 'materi_list_guru.dart';
import '../../services/kelas_service.dart';
import '../../services/user_service.dart';
import '../../services/siswa_service.dart';

class KelolaKelasPage extends StatefulWidget {
  const KelolaKelasPage({super.key});

  @override
  State<KelolaKelasPage> createState() => _KelolaKelasPageState();
}

class _KelolaKelasPageState extends State<KelolaKelasPage> {
  final KelasService _kelasService = KelasService();
  final UserService _userService = UserService();
  final SiswaService _siswaService = SiswaService();
  List<Map<String, dynamic>> _kelasList = [];
  bool _isLoading = true;
  String? _currentUserId;
  int _totalSiswa = 0;

  @override
  void initState() {
    super.initState();
    _loadKelas();
  }

  Future<void> _loadKelas() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user ID
      _currentUserId = await _userService.getUserId();
      
      if (_currentUserId == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User tidak ditemukan. Silakan login kembali.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Load kelas from API
      final result = await _kelasService.getAllKelas(guruId: _currentUserId);
      
      if (result['success'] == true && mounted) {
        final dataList = result['data'] as List? ?? [];
        final tempKelasList = dataList.asMap().entries.map<Map<String, dynamic>>((entry) {
          final index = entry.key;
          final kelas = entry.value;
          final kelasMap = kelas as Map<String, dynamic>? ?? {};
          return {
            'id': kelasMap['_id']?.toString() ?? '',
            'nama': kelasMap['nama']?.toString() ?? 'Nama Kelas',
            'guru_id': kelasMap['guru_id']?.toString() ?? '',
            'tahun_ajaran': kelasMap['tahun_ajaran']?.toString() ?? DateTime.now().year.toString(),
            'createdAt': kelasMap['createdAt']?.toString(),
            'updatedAt': kelasMap['updatedAt']?.toString(),
            // Default values for display
            'color': Colors.primaries[index % Colors.primaries.length],
            'jumlah_siswa': 0, // Will be updated below
          };
        }).toList();
        
        // Load siswa count for each kelas
        await _loadSiswaCountForEachKelas(tempKelasList);
        
        setState(() {
          _kelasList = tempKelasList;
          _isLoading = false;
        });
        
        // Load total siswa count
        _loadTotalSiswa();
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']?.toString() ?? 'Gagal memuat data kelas'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
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

  Future<void> _loadSiswaCountForEachKelas(List<Map<String, dynamic>> kelasList) async {
    try {
      for (int i = 0; i < kelasList.length; i++) {
        final kelasId = kelasList[i]['id']?.toString();
        if (kelasId != null && kelasId.isNotEmpty) {
          final result = await _siswaService.getSiswaByKelas(kelasId);
          if (result['success'] == true) {
            kelasList[i]['jumlah_siswa'] = result['count'] as int? ?? 0;
          }
        }
      }
    } catch (e) {
      // Silently handle error, keep jumlah_siswa as 0
    }
  }

  Future<void> _loadTotalSiswa() async {
    try {
      int totalCount = 0;
      
      // Sum up siswa count from each kelas
      for (final kelas in _kelasList) {
        totalCount += (kelas['jumlah_siswa'] as int? ?? 0);
      }
      
      if (mounted) {
        setState(() {
          _totalSiswa = totalCount;
        });
      }
    } catch (e) {
      // Silently handle error, keep _totalSiswa as 0
      if (mounted) {
        setState(() {
          _totalSiswa = 0;
        });
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
          'Kelola Kelas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Search functionality
            },
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
                          icon: Icons.class_,
                          title: 'Total Kelas',
                          value: '${_kelasList.length}',
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.people,
                          title: 'Total Siswa',
                          value: '$_totalSiswa',
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Button Buat Kelas Baru
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TambahKelasPage(),
                          ),
                        );

                        // Jika ada data yang dikembalikan, refresh list
                        if (result != null) {
                          _loadKelas(); // Reload data from API
                        }
                      },
                      icon: const Icon(Icons.add_circle_outline, size: 24),
                      label: const Text(
                        'Buat Kelas Baru',
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
          // Daftar Kelas
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF1976D2),
                    ),
                  )
                : _kelasList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.class_,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada kelas',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Buat kelas baru untuk memulai',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadKelas,
                        color: const Color(0xFF1976D2),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: _kelasList.length,
                          itemBuilder: (context, index) {
                            final kelas = _kelasList[index];
                            return _buildKelasCard(
                              kelas: kelas,
                              onTap: () {
                                _showDetailKelasDialog(kelas);
                              },
                              onEdit: () {
                                _showEditKelasDialog(kelas, index);
                              },
                              onDelete: () {
                                _showDeleteConfirmation(kelas, index);
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

  Widget _buildKelasCard({
    required Map<String, dynamic> kelas,
    required VoidCallback onTap,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    final nama = kelas['nama'] ?? 'Nama Kelas';
    final tahunAjaran = kelas['tahun_ajaran'] ?? DateTime.now().year.toString();
    final color = kelas['color'] ?? Colors.blue;
    final createdAt = kelas['createdAt'] != null 
        ? DateTime.tryParse(kelas['createdAt'].toString())?.toLocal() ?? DateTime.now()
        : DateTime.now();
    final formattedDate = '${createdAt.day}/${createdAt.month}/${createdAt.year}';
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
                    // Icon Kelas
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.class_,
                        color: color,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 15),
                    // Info Kelas
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nama,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tahun Ajaran: $tahunAjaran',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                              Icon(Icons.book, color: Colors.purple.shade700, size: 20),
                              const SizedBox(width: 10),
                              const Text('Kelola Materi'),
                            ],
                          ),
                          onTap: () {
                            Future.delayed(Duration.zero, () => _navigateToKelolaMateri(kelas));
                          },
                        ),
                        PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(Icons.people, color: Colors.green.shade700, size: 20),
                              const SizedBox(width: 10),
                              const Text('Kelola Siswa'),
                            ],
                          ),
                          onTap: () {
                            Future.delayed(Duration.zero, () => _navigateToKelolaSiswa(kelas));
                          },
                        ),
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
                        Icons.people,
                        '${kelas['jumlah_siswa'] ?? 0} Siswa',
                        color,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        Icons.calendar_today,
                        'Dibuat: $formattedDate',
                        color,
                      ),
                    ),
                  ],
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

  void _showTambahKelasDialog() {
    final namaController = TextEditingController();
    final mataPelajaranController = TextEditingController();
    final jumlahSiswaController = TextEditingController();
    final jadwalController = TextEditingController();
    final waktuController = TextEditingController();
    final ruanganController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text('Buat Kelas Baru'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaController,
                decoration: InputDecoration(
                  labelText: 'Nama Kelas',
                  hintText: 'Contoh: Kelas X-A',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.class_),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: mataPelajaranController,
                decoration: InputDecoration(
                  labelText: 'Mata Pelajaran',
                  hintText: 'Contoh: Matematika',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.book),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: jumlahSiswaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Jumlah Siswa',
                  hintText: 'Contoh: 30',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.people),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: jadwalController,
                decoration: InputDecoration(
                  labelText: 'Jadwal',
                  hintText: 'Contoh: Senin, Rabu, Jumat',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: waktuController,
                decoration: InputDecoration(
                  labelText: 'Waktu',
                  hintText: 'Contoh: 08:00 - 09:30',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.access_time),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: ruanganController,
                decoration: InputDecoration(
                  labelText: 'Ruangan',
                  hintText: 'Contoh: R.101',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.room),
                ),
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
              // This dialog is not used anymore since we use TambahKelasPage
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showDetailKelasDialog(Map<String, dynamic> kelas) {
    final createdAt = kelas['createdAt'] != null 
        ? DateTime.tryParse(kelas['createdAt'].toString())?.toLocal() ?? DateTime.now()
        : DateTime.now();
    final updatedAt = kelas['updatedAt'] != null 
        ? DateTime.tryParse(kelas['updatedAt'].toString())?.toLocal() ?? DateTime.now()
        : DateTime.now();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(kelas['nama']?.toString() ?? 'Nama Kelas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Jumlah Siswa', '${kelas['jumlah_siswa'] ?? 0} Siswa'),
            _buildDetailRow('Tahun Ajaran', kelas['tahun_ajaran']?.toString() ?? DateTime.now().year.toString()),
            _buildDetailRow('Dibuat', '${createdAt.day}/${createdAt.month}/${createdAt.year}'),
            _buildDetailRow('Terakhir Update', '${updatedAt.day}/${updatedAt.month}/${updatedAt.year}'),
          ],
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

  void _showEditKelasDialog(Map<String, dynamic> kelas, int index) {
    final namaController = TextEditingController(text: kelas['nama']?.toString() ?? '');
    final tahunAjaranController = TextEditingController(text: kelas['tahun_ajaran']?.toString() ?? DateTime.now().year.toString());
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Text('Edit Kelas'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: namaController,
                    decoration: InputDecoration(
                      labelText: 'Nama Kelas',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.class_),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: tahunAjaranController,
                    decoration: InputDecoration(
                      labelText: 'Tahun Ajaran',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.calendar_today),
                    ),
                  ),
                  if (isLoading) ...[
                    const SizedBox(height: 20),
                    const CircularProgressIndicator(),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: isLoading ? null : () async {
                  if (namaController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nama kelas tidak boleh kosong'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  
                  setDialogState(() {
                    isLoading = true;
                  });
                  
                  try {
                    final kelasId = kelas['id']?.toString();
                    if (kelasId == null || kelasId.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('ID kelas tidak valid'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    
                    final result = await _kelasService.updateKelas(
                      id: kelasId,
                      nama: namaController.text,
                      tahunAjaran: tahunAjaranController.text,
                    );
                    
                    if (mounted) {
                      Navigator.pop(context);
                      
                      if (result['success'] == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result['message']?.toString() ?? 'Kelas berhasil diupdate!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        _loadKelas(); // Reload data
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result['message']?.toString() ?? 'Gagal mengupdate kelas'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Terjadi kesalahan: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                ),
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showDeleteConfirmation(Map<String, dynamic> kelas, int index) async {
    final namaKelas = kelas['nama']?.toString() ?? 'Kelas';
    final kelasId = kelas['id']?.toString() ?? '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text('Hapus Kelas'),
        content: Text('Apakah Anda yakin ingin menghapus $namaKelas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );
              
              try {
                final result = await _kelasService.deleteKelas(kelasId);
                
                if (mounted) {
                  Navigator.pop(context); // Close loading
                  
                  if (result['success'] == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result['message']?.toString() ?? 'Kelas berhasil dihapus!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _loadKelas(); // Reload data
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result['message']?.toString() ?? 'Gagal menghapus kelas'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context); // Close loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Terjadi kesalahan: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
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

  Future<void> _navigateToKelolaSiswa(Map<String, dynamic> kelas) async {
    final kelasId = kelas['id']?.toString();
    final namaKelas = kelas['nama']?.toString() ?? 'Kelas';
    
    if (kelasId == null || kelasId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID kelas tidak valid'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Navigate to daftar siswa page
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DaftarSiswaPage(
          kelasId: kelasId,
          namaKelas: namaKelas,
        ),
      ),
    );

    // Reload kelas data to update siswa count
    _loadKelas();
  }

  void _navigateToKelolaMateri(Map<String, dynamic> kelas) async {
    final kelasId = kelas['id']?.toString();
    final namaKelas = kelas['nama']?.toString() ?? 'Kelas';
    final tahunAjaran = kelas['tahun_ajaran']?.toString() ?? DateTime.now().year.toString();

    if (kelasId == null || kelasId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID kelas tidak valid'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Navigate to materi list guru page
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MateriListGuruPage(
          kelasId: kelasId,
          kelasName: namaKelas,
          tahunAjaran: tahunAjaran,
        ),
      ),
    );
  }
}
