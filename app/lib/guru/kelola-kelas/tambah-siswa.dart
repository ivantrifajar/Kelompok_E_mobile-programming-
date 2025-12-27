import 'package:flutter/material.dart';
import 'dart:async';
import '../../services/siswa_service.dart';
import '../../services/user_search_service.dart';
import '../../services/kelas_service.dart';

class TambahSiswaPage extends StatefulWidget {
  final String? kelasId;
  final String? namaKelas;

  const TambahSiswaPage({
    super.key,
    this.kelasId,
    this.namaKelas,
  });

  @override
  State<TambahSiswaPage> createState() => _TambahSiswaPageState();
}

class _TambahSiswaPageState extends State<TambahSiswaPage> {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  final _nisController = TextEditingController();
  final _tanggalLahirController = TextEditingController();
  final _alamatController = TextEditingController();
  final _noTeleponController = TextEditingController();
  final _namaOrangTuaController = TextEditingController();

  final _siswaService = SiswaService();
  final _userSearchService = UserSearchService();
  final _kelasService = KelasService();
  bool _isLoading = false;
  bool _isSearching = false;
  bool _isLoadingKelas = false;
  String _jenisKelamin = 'L';
  DateTime? _selectedDate;
  Map<String, dynamic>? _selectedUser;
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _availableKelas = [];
  List<String> _selectedKelasIds = [];
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadAvailableKelas();
    // If coming from a specific class, pre-select it
    if (widget.kelasId != null) {
      _selectedKelasIds.add(widget.kelasId!);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _nisController.dispose();
    _tanggalLahirController.dispose();
    _alamatController.dispose();
    _noTeleponController.dispose();
    _namaOrangTuaController.dispose();
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal memuat kelas: ${result['message'] ?? 'Unknown error'}'),
                backgroundColor: Colors.orange,
              ),
            );
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
            content: Text('Gagal memuat daftar kelas: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onSearchChanged(String query) {
    // Cancel previous timer
    _debounceTimer?.cancel();
    
    // Set new timer for debouncing
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _searchUsers(query);
    });
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final result = await _userSearchService.searchAvailableSiswa(
        query: query,
      );

      if (mounted) {
        setState(() {
          _isSearching = false;
          if (result['success'] == true) {
            final dataList = result['data'] as List? ?? [];
            _searchResults = dataList.map<Map<String, dynamic>>((user) {
              final userMap = user as Map<String, dynamic>? ?? {};
              return {
                'id': userMap['_id']?.toString() ?? '',
                'nama_lengkap': userMap['nama_lengkap']?.toString() ?? '',
                'email': userMap['email']?.toString() ?? '',
              };
            }).toList();
          } else {
            _searchResults = [];
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _searchResults = [];
        });
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(
        const Duration(days: 365 * 15),
      ), // 15 years ago
      firstDate: DateTime.now().subtract(
        const Duration(days: 365 * 25),
      ), // 25 years ago
      lastDate: DateTime.now().subtract(
        const Duration(days: 365 * 5),
      ), // 5 years ago
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1976D2),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _tanggalLahirController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Future<void> _handleSimpan() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pilih siswa terlebih dahulu'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tanggal lahir harus dipilih'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_selectedKelasIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pilih minimal satu kelas'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Multiple classes are now fully supported!

      setState(() {
        _isLoading = true;
      });

      try {
        // Debug: Print what we're sending
        print('=== DEBUG: Sending to API ===');
        print('User ID: ${_selectedUser!['id']}');
        print('NIS: ${_nisController.text}');
        print('Kelas IDs: $_selectedKelasIds');
        print('Jenis Kelamin: $_jenisKelamin');
        print('Tanggal Lahir: ${_selectedDate!.toIso8601String()}');
        print('Alamat: ${_alamatController.text.isEmpty ? 'null' : _alamatController.text}');
        print('No Telepon: ${_noTeleponController.text.isEmpty ? 'null' : _noTeleponController.text}');
        print('Nama Orang Tua: ${_namaOrangTuaController.text.isEmpty ? 'null' : _namaOrangTuaController.text}');
        print('========================');
        
        final result = await _siswaService.createSiswa(
          userId: _selectedUser!['id'],
          nis: _nisController.text,
          kelasIds: _selectedKelasIds,
          jenisKelamin: _jenisKelamin,
          tanggalLahir: _selectedDate!.toIso8601String(),
          alamat: _alamatController.text.isEmpty
              ? null
              : _alamatController.text,
          noTelepon: _noTeleponController.text.isEmpty
              ? null
              : _noTeleponController.text,
          namaOrangTua: _namaOrangTuaController.text.isEmpty
              ? null
              : _namaOrangTuaController.text,
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          if (result['success'] == true) {
            Navigator.pop(context, result['data']);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  result['message']?.toString() ??
                      'Siswa berhasil ditambahkan!',
                ),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  result['message']?.toString() ?? 'Gagal menambahkan siswa',
                ),
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
          'Tambah Siswa Baru',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
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
              ),
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.person_add,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.namaKelas != null 
                          ? 'Tambah Siswa ke ${widget.namaKelas}'
                          : 'Tambah Siswa Baru',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Lengkapi data siswa dengan benar',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            // Form Section
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    // Search User
                    _buildUserSearchField(),
                    const SizedBox(height: 20),
                    // Class Selection
                    _buildKelasSelectionField(),
                    const SizedBox(height: 20),
                    // NIS
                    _buildTextField(
                      controller: _nisController,
                      label: 'NIS (Nomor Induk Siswa)',
                      hint: 'Masukkan NIS siswa',
                      icon: Icons.badge,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'NIS tidak boleh kosong';
                        }
                        if (value.length < 5) {
                          return 'NIS minimal 5 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Jenis Kelamin
                    const Text(
                      'Jenis Kelamin',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Laki-laki'),
                              value: 'L',
                              groupValue: _jenisKelamin,
                              activeColor: const Color(0xFF1976D2),
                              onChanged: (value) {
                                setState(() {
                                  _jenisKelamin = value!;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Perempuan'),
                              value: 'P',
                              groupValue: _jenisKelamin,
                              activeColor: const Color(0xFF1976D2),
                              onChanged: (value) {
                                setState(() {
                                  _jenisKelamin = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Tanggal Lahir
                    const Text(
                      'Tanggal Lahir',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _tanggalLahirController,
                        readOnly: true,
                        onTap: _selectDate,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Pilih tanggal lahir',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(12),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1976D2).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.calendar_today,
                              color: Color(0xFF1976D2),
                              size: 24,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Alamat
                    _buildTextField(
                      controller: _alamatController,
                      label: 'Alamat (Opsional)',
                      hint: 'Masukkan alamat siswa',
                      icon: Icons.location_on,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    // No Telepon
                    _buildTextField(
                      controller: _noTeleponController,
                      label: 'No. Telepon (Opsional)',
                      hint: 'Masukkan nomor telepon',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 20),
                    // Nama Orang Tua
                    _buildTextField(
                      controller: _namaOrangTuaController,
                      label: 'Nama Orang Tua (Opsional)',
                      hint: 'Masukkan nama orang tua/wali',
                      icon: Icons.family_restroom,
                    ),
                    const SizedBox(height: 40),
                    // Button Simpan
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSimpan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 3,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle_outline, size: 24),
                                  SizedBox(width: 10),
                                  Text(
                                    'Simpan Siswa',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Button Batal
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1976D2),
                          side: const BorderSide(
                            color: Color(0xFF1976D2),
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1976D2),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1976D2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF1976D2), size: 24),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildUserSearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Siswa',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1976D2),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              TextFormField(
                controller: _searchController,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Cari nama atau email siswa...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  prefixIcon: Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1976D2).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.search,
                      color: Color(0xFF1976D2),
                      size: 24,
                    ),
                  ),
                  suffixIcon: _isSearching
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF1976D2),
                            ),
                          ),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                ),
                onChanged: (value) {
                  _onSearchChanged(value);
                },
              ),
              // Selected User Display
              if (_selectedUser != null)
                Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1976D2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF1976D2).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person,
                        color: Color(0xFF1976D2),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedUser!['nama_lengkap'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1976D2),
                              ),
                            ),
                            Text(
                              _selectedUser!['email'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Color(0xFF1976D2),
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedUser = null;
                            _searchController.clear();
                            _searchResults = [];
                          });
                        },
                      ),
                    ],
                  ),
                ),
              // Search Results
              if (_searchResults.isNotEmpty && _selectedUser == null)
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final user = _searchResults[index];
                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF1976D2),
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          user['nama_lengkap'],
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          user['email'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _selectedUser = user;
                            _searchController.text = user['nama_lengkap'];
                            _searchResults = [];
                          });
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKelasSelectionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Pilih Kelas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2),
              ),
            ),
            TextButton.icon(
              onPressed: _isLoadingKelas ? null : _loadAvailableKelas,
              icon: Icon(
                Icons.refresh,
                size: 16,
                color: _isLoadingKelas ? Colors.grey : const Color(0xFF1976D2),
              ),
              label: Text(
                'Refresh',
                style: TextStyle(
                  fontSize: 12,
                  color: _isLoadingKelas ? Colors.grey : const Color(0xFF1976D2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: _isLoadingKelas
              ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF1976D2),
                    ),
                  ),
                )
              : _availableKelas.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.school_outlined,
                            size: 48,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Tidak ada kelas tersedia',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: _loadAvailableKelas,
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Coba Lagi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1976D2),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: _availableKelas.map((kelas) {
                        final isSelected = _selectedKelasIds.contains(kelas['id']);
                        return CheckboxListTile(
                          title: Text(
                            kelas['nama'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: kelas['tahun_ajaran'].isNotEmpty
                              ? Text(
                                  'Tahun Ajaran: ${kelas['tahun_ajaran']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                )
                              : null,
                          value: isSelected,
                          activeColor: const Color(0xFF1976D2),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedKelasIds.add(kelas['id']);
                              } else {
                                _selectedKelasIds.remove(kelas['id']);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
        ),
        if (_selectedKelasIds.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF1976D2).withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kelas Terpilih:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _selectedKelasIds.map((kelasId) {
                      final kelas = _availableKelas.firstWhere(
                        (k) => k['id'] == kelasId,
                        orElse: () => {'nama': 'Unknown'},
                      );
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1976D2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              kelas['nama'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedKelasIds.remove(kelasId);
                                });
                              },
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
