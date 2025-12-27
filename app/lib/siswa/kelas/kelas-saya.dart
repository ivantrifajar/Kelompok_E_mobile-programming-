import 'package:flutter/material.dart';
import 'materi_list.dart';
import '../../services/siswa_service.dart';
import '../../services/user_service.dart';

class KelasSayaPage extends StatefulWidget {
  const KelasSayaPage({super.key});

  @override
  State<KelasSayaPage> createState() => _KelasSayaPageState();
}

class _KelasSayaPageState extends State<KelasSayaPage> {
  final SiswaService _siswaService = SiswaService();
  final UserService _userService = UserService();
  
  List<Map<String, dynamic>> _classList = [];
  bool _isLoading = true;
  int _totalSiswa = 0;
  // double _averageProgress = 0.0; // Hidden for cleaner UI
  
  // Color palette for different classes
  final List<Color> _classColors = [
    const Color(0xFF1976D2),
    const Color(0xFF64B5F6),
    const Color(0xFF42A5F5),
    const Color(0xFF90CAF9),
    const Color(0xFFBBDEFB),
    const Color(0xFF2196F3),
    const Color(0xFF03DAC6),
    const Color(0xFF6200EE),
  ];
  
  // Icon mapping for different subjects
  final Map<String, IconData> _subjectIcons = {
    'matematika': Icons.calculate,
    'bahasa': Icons.book,
    'indonesia': Icons.book,
    'inggris': Icons.language,
    'ipa': Icons.science,
    'fisika': Icons.science,
    'kimia': Icons.science,
    'biologi': Icons.science,
    'sejarah': Icons.history_edu,
    'geografi': Icons.public,
    'ekonomi': Icons.trending_up,
    'sosiologi': Icons.people,
    'seni': Icons.palette,
    'olahraga': Icons.sports,
    'agama': Icons.auto_stories,
    'pkn': Icons.account_balance,
    'teknologi': Icons.computer,
    'pemrograman': Icons.code,
  };
  
  @override
  void initState() {
    super.initState();
    _loadKelasData();
  }
  
  Future<void> _loadKelasData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Get current user ID
      final userId = await _userService.getUserId();
      
      if (userId != null) {
        // Get siswa data to get enrolled classes
        final siswaResult = await _siswaService.getSiswaByUserId(userId);
        
        print('=== KELAS SAYA DEBUG ===');
        print('Siswa Result: $siswaResult');
        
        if (siswaResult['success'] == true) {
          final siswaData = siswaResult['data'] as Map<String, dynamic>? ?? {};
          final kelasIds = siswaData['kelas_ids'] as List? ?? [];
          
          print('Kelas IDs: $kelasIds');
          
          List<Map<String, dynamic>> classList = [];
          int totalSiswa = 0;
          
          // Process each class
          for (int i = 0; i < kelasIds.length; i++) {
            final kelas = kelasIds[i] as Map<String, dynamic>? ?? {};
            final kelasId = kelas['_id']?.toString();
            
            if (kelasId != null) {
              // Get siswa count for this class
              final siswaByKelasResult = await _siswaService.getSiswaByKelas(kelasId);
              int siswaCount = 0;
              
              if (siswaByKelasResult['success'] == true) {
                siswaCount = siswaByKelasResult['count'] as int? ?? 0;
                totalSiswa += siswaCount;
              }
              
              // Create class data
              final className = kelas['nama']?.toString() ?? 'Kelas';
              final tahunAjaran = kelas['tahun_ajaran']?.toString() ?? '';
              
              // Get guru data
              final guruData = kelas['guru_id'] as Map<String, dynamic>? ?? {};
              final guruName = guruData['nama_lengkap']?.toString() ?? 'Guru ${className}';
              
              print('Kelas: $className, Guru: $guruName'); // Debug log
              
              classList.add({
                '_id': kelasId,
                'title': className,
                'code': _generateClassCode(className),
                'tahun_ajaran': tahunAjaran,
                'students': siswaCount,
                // 'progress': _generateRandomProgress(), // Hidden for cleaner UI
                'color': _classColors[i % _classColors.length],
                'icon': _getIconForSubject(className),
                'teacher': guruName, // Real teacher name from database
              });
            }
          }
          
          // Calculate average progress - Hidden for cleaner UI
          // double avgProgress = 0.0;
          // if (classList.isNotEmpty) {
          //   avgProgress = classList.fold(0.0, (sum, item) => sum + (item['progress'] as double)) / classList.length;
          // }
          
          if (mounted) {
            setState(() {
              _classList = classList;
              _totalSiswa = totalSiswa;
              // _averageProgress = avgProgress; // Hidden
              _isLoading = false;
            });
          }
        } else {
          // No siswa data found
          if (mounted) {
            setState(() {
              _classList = [];
              _totalSiswa = 0;
              // _averageProgress = 0.0; // Hidden
              _isLoading = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading kelas data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data kelas: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  String _generateClassCode(String className) {
    // Generate a simple class code based on class name
    final words = className.split(' ');
    String code = '';
    for (final word in words) {
      if (word.isNotEmpty) {
        code += word.substring(0, 1).toUpperCase();
      }
    }
    return '$code-${DateTime.now().year.toString().substring(2)}';
  }
  
  IconData _getIconForSubject(String className) {
    final lowerName = className.toLowerCase();
    for (final key in _subjectIcons.keys) {
      if (lowerName.contains(key)) {
        return _subjectIcons[key]!;
      }
    }
    return Icons.school; // Default icon
  }
  
  double _generateRandomProgress() {
    // TODO: Replace with real progress from API
    return 0.45 + (0.4 * (DateTime.now().millisecondsSinceEpoch % 100) / 100);
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Kelas Saya',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Handle search
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {
              // Handle filter
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Stats
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF1976D2),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.class_,
                            title: 'Total Kelas',
                            value: '${_classList.length}',
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
                        const SizedBox(width: 15),
                        // Progress stats hidden for cleaner UI
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 20),
          // Class List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF1976D2),
                    ),
                  )
                : _classList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.school_outlined,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Belum Ada Kelas',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Anda belum terdaftar di kelas manapun',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _loadKelasData,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Refresh'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1976D2),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadKelasData,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          itemCount: _classList.length,
                          itemBuilder: (context, index) {
                            final classData = _classList[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: _buildClassCard(classData),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle join new class
          _showJoinClassDialog();
        },
        backgroundColor: const Color(0xFF1976D2),
        child: const Icon(Icons.add, color: Colors.white),
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
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard(Map<String, dynamic> classData) {
    return InkWell(
      onTap: () {
        // Navigate to class detail
        _showClassDetailDialog(classData);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with gradient
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    classData['color'],
                    classData['color'].withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      classData['icon'],
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          classData['title'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          classData['code'],
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Progress percentage hidden for cleaner UI
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Teacher and Schedule Info
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          icon: Icons.person,
                          title: 'Pengajar',
                          value: classData['teacher'],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          icon: Icons.people,
                          title: 'Siswa',
                          value: '${classData['students']} siswa',
                        ),
                      ),
                    ],
                  ),
                  // Progress Bar - Hidden for cleaner UI
                  const SizedBox(height: 20),
                  // Action Buttons - Only Materi button
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Navigate to materi list page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MateriListPage(
                                  kelasId: classData['_id'],
                                  kelasName: classData['title'],
                                  tahunAjaran: classData['tahun_ajaran'] ?? '',
                                ),
                              ),
                            );
                          },
                          icon: Icon(Icons.book, color: classData['color']),
                          label: const Text('Materi'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: classData['color'],
                            side: BorderSide(color: classData['color']),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showClassDetailDialog(Map<String, dynamic> classData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(classData['icon'], color: classData['color']),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  classData['title'],
                  style: TextStyle(
                    color: classData['color'],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Kode Kelas: ${classData['code']}'),
              const SizedBox(height: 8),
              Text('Pengajar: ${classData['teacher']}'),
              const SizedBox(height: 8),
              Text('Jumlah Siswa: ${classData['students']} siswa'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Tutup',
                style: TextStyle(color: classData['color']),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showJoinClassDialog() {
    final TextEditingController codeController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.add_circle, color: Color(0xFF1976D2)),
              SizedBox(width: 10),
              Text(
                'Gabung Kelas Baru',
                style: TextStyle(
                  color: Color(0xFF1976D2),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Masukkan kode kelas untuk bergabung:'),
              const SizedBox(height: 15),
              TextField(
                controller: codeController,
                decoration: InputDecoration(
                  labelText: 'Kode Kelas',
                  hintText: 'Contoh: MTK-001',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.vpn_key),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Batal',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle join class
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Berhasil bergabung dengan kelas!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
              ),
              child: const Text('Gabung', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}