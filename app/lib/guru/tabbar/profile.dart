import 'package:flutter/material.dart';
import '../../auth/login.dart';
import '../../services/user_service.dart';
import '../../services/kelas_service.dart';
import '../../services/siswa_service.dart';
import '../../services/flashcard_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserService _userService = UserService();
  final KelasService _kelasService = KelasService();
  final SiswaService _siswaService = SiswaService();
  final FlashcardService _flashcardService = FlashcardService();
  
  String _userName = 'Guru';
  String _userEmail = 'guru@sekolah.com';
  int _totalKelas = 0;
  int _totalSiswa = 0;
  int _totalFlashcard = 0;
  bool _isLoading = true;
  
  // TODO: Get actual guru_id from user session/auth
  final String _guruId = '68e630667aa27040bcb95fed';

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load user data
      final userData = await _userService.getUserData();
      
      // Load statistics in parallel
      final results = await Future.wait([
        _loadKelasCount(),
        _loadSiswaCount(),
        _loadFlashcardCount(),
      ]);

      setState(() {
        _userName = userData['userName'] ?? 'Guru';
        _userEmail = userData['userEmail'] ?? 'guru@sekolah.com';
        _totalKelas = results[0];
        _totalSiswa = results[1];
        _totalFlashcard = results[2];
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading profile data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<int> _loadKelasCount() async {
    try {
      final result = await _kelasService.getAllKelas(guruId: _guruId);
      if (result['success'] == true) {
        final dataList = result['data'] as List? ?? [];
        return dataList.length;
      }
    } catch (e) {
      print('Error loading kelas count: $e');
    }
    return 0;
  }

  Future<int> _loadSiswaCount() async {
    try {
      // Get all classes first
      final kelasResult = await _kelasService.getAllKelas(guruId: _guruId);
      if (kelasResult['success'] == true) {
        final kelasList = kelasResult['data'] as List? ?? [];
        Set<String> uniqueSiswa = {};
        
        // Get students for each class
        for (final kelas in kelasList) {
          final kelasMap = kelas as Map<String, dynamic>? ?? {};
          final kelasId = kelasMap['_id']?.toString();
          if (kelasId != null) {
            final siswaResult = await _siswaService.getSiswaByKelas(kelasId);
            if (siswaResult['success'] == true) {
              final siswaList = siswaResult['data'] as List? ?? [];
              for (final siswa in siswaList) {
                final siswaMap = siswa as Map<String, dynamic>? ?? {};
                final siswaId = siswaMap['_id']?.toString();
                if (siswaId != null) {
                  uniqueSiswa.add(siswaId);
                }
              }
            }
          }
        }
        return uniqueSiswa.length;
      }
    } catch (e) {
      print('Error loading siswa count: $e');
    }
    return 0;
  }

  Future<int> _loadFlashcardCount() async {
    try {
      final result = await _flashcardService.getAllFlashcards(
        guruId: _guruId,
        limit: 1000, // Get all flashcards for count
      );
      if (result['success'] == true) {
        final dataList = result['data'] as List? ?? [];
        return dataList.length;
      }
    } catch (e) {
      print('Error loading flashcard count: $e');
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1976D2),
                    Color(0xFF64B5F6),
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    children: [
                      // Profile Picture
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const CircleAvatar(
                              radius: 55,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.person,
                                size: 70,
                                color: Color(0xFF1976D2),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.camera_alt,
                                  color: Color(0xFF1976D2),
                                  size: 20,
                                ),
                                onPressed: () {
                                  // Change profile picture
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _userEmail,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const SizedBox(height: 25),
                      // Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatItem(_isLoading ? '-' : _totalKelas.toString(), 'Kelas'),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          _buildStatItem(_isLoading ? '-' : _totalSiswa.toString(), 'Siswa'),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          _buildStatItem(_isLoading ? '-' : _totalFlashcard.toString(), 'Flashcard'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Edit Profile Button
                      ElevatedButton.icon(
                        onPressed: () {
                          _showEditProfileDialog();
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Profile'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1976D2),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Menu Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pengaturan Akun',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildProfileMenuItem(
                    icon: Icons.person_outline,
                    title: 'Informasi Pribadi',
                    subtitle: 'Kelola data pribadi Anda',
                    color: Colors.blue,
                    onTap: () {
                      _showInfoDialog('Informasi Pribadi', 'Fitur ini akan segera tersedia');
                    },
                  ),
                  _buildProfileMenuItem(
                    icon: Icons.lock_outline,
                    title: 'Ubah Password',
                    subtitle: 'Ganti password akun Anda',
                    color: Colors.orange,
                    onTap: () {
                      _showChangePasswordDialog();
                    },
                  ),
                  _buildProfileMenuItem(
                    icon: Icons.security,
                    title: 'Keamanan',
                    subtitle: 'Pengaturan keamanan akun',
                    color: Colors.green,
                    onTap: () {
                      _showInfoDialog('Keamanan', 'Fitur ini akan segera tersedia');
                    },
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    'Preferensi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildProfileMenuItem(
                    icon: Icons.notifications,
                    title: 'Notifikasi',
                    subtitle: 'Atur preferensi notifikasi',
                    color: Colors.purple,
                    onTap: () {
                      _showInfoDialog('Notifikasi', 'Fitur ini akan segera tersedia');
                    },
                  ),
                  _buildProfileMenuItem(
                    icon: Icons.language,
                    title: 'Bahasa',
                    subtitle: 'Indonesia',
                    color: Colors.teal,
                    onTap: () {
                      _showInfoDialog('Bahasa', 'Fitur ini akan segera tersedia');
                    },
                  ),
                  _buildProfileMenuItem(
                    icon: Icons.dark_mode,
                    title: 'Tema',
                    subtitle: 'Terang',
                    color: Colors.indigo,
                    onTap: () {
                      _showInfoDialog('Tema', 'Fitur ini akan segera tersedia');
                    },
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    'Lainnya',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildProfileMenuItem(
                    icon: Icons.help_outline,
                    title: 'Bantuan & Dukungan',
                    subtitle: 'Pusat bantuan dan FAQ',
                    color: Colors.cyan,
                    onTap: () {
                      _showInfoDialog('Bantuan', 'Hubungi kami di support@sekolah.com');
                    },
                  ),
                  _buildProfileMenuItem(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Kebijakan Privasi',
                    subtitle: 'Baca kebijakan privasi kami',
                    color: Colors.amber,
                    onTap: () {
                      _showInfoDialog('Kebijakan Privasi', 'Fitur ini akan segera tersedia');
                    },
                  ),
                  _buildProfileMenuItem(
                    icon: Icons.info_outline,
                    title: 'Tentang Aplikasi',
                    subtitle: 'Versi 1.0.0',
                    color: Colors.grey,
                    onTap: () {
                      _showAboutDialog();
                    },
                  ),
                  const SizedBox(height: 25),
                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showLogoutDialog();
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text(
                        'Keluar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        value == '-' 
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
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
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey.shade400,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Nama',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              decoration: InputDecoration(
                labelText: 'Mata Pelajaran',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.book),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile berhasil diupdate!'),
                  backgroundColor: Colors.green,
                ),
              );
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

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text('Ubah Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password Lama',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password Baru',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Konfirmasi Password Baru',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.lock_outline),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password berhasil diubah!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
            ),
            child: const Text('Ubah'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(title),
        content: Text(message),
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

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text('Tentang Aplikasi'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aplikasi Pendidikan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text('Versi: 1.0.0'),
            SizedBox(height: 5),
            Text('Build: 2025.10.06'),
            SizedBox(height: 15),
            Text(
              'Aplikasi pembelajaran interaktif untuk guru dan siswa.',
              style: TextStyle(fontSize: 14),
            ),
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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Close dialog first
              Navigator.of(context).pop();

              // Clear user data from SharedPreferences
              await _userService.clearUserData();

              // Navigate back to login immediately
              if (!mounted) return;
              
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );

              // Show success message after navigation
              Future.delayed(const Duration(milliseconds: 300), () {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Berhasil keluar'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}
