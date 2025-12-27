const Siswa = require('../models/Siswa');
const Kelas = require('../models/Kelas');

// @desc    Create new siswa
// @route   POST /api/siswa
// @access  Private (Guru only)
exports.createSiswa = async (req, res) => {
  try {
    const { 
      user_id,
      nis, 
      kelas_id,        // For backward compatibility
      kelas_ids,       // New multiple classes support
      jenis_kelamin, 
      tanggal_lahir, 
      alamat, 
      no_telepon, 
      nama_orang_tua 
    } = req.body;

    // Determine which classes to use
    let kelasIdsToUse = [];
    
    if (kelas_ids && Array.isArray(kelas_ids) && kelas_ids.length > 0) {
      // Use new multiple classes format
      kelasIdsToUse = kelas_ids;
    } else if (kelas_id) {
      // Use old single class format for backward compatibility
      kelasIdsToUse = [kelas_id];
    } else {
      return res.status(400).json({
        success: false,
        message: 'Minimal satu kelas harus dipilih'
      });
    }

    // Validate required fields
    if (!user_id || !nis || !jenis_kelamin || !tanggal_lahir) {
      return res.status(400).json({
        success: false,
        message: 'User, NIS, jenis kelamin, dan tanggal lahir wajib diisi'
      });
    }

    // Validate all class IDs exist and are active
    const validKelas = await Kelas.find({ 
      _id: { $in: kelasIdsToUse },
      isActive: true 
    });
    
    if (validKelas.length !== kelasIdsToUse.length) {
      const invalidIds = kelasIdsToUse.filter(id => 
        !validKelas.some(kelas => kelas._id.toString() === id)
      );
      return res.status(400).json({
        success: false,
        message: `Kelas tidak valid atau tidak aktif: ${invalidIds.join(', ')}`
      });
    }

    // Verify user exists and has siswa role
    const User = require('../models/User');
    const user = await User.findById(user_id);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    if (user.role !== 'siswa') {
      return res.status(403).json({
        success: false,
        message: 'User must have siswa role'
      });
    }

    // Check if user is already assigned to any class
    const existingUserAssignment = await Siswa.findOne({ user_id });
    if (existingUserAssignment) {
      return res.status(400).json({
        success: false,
        message: 'User sudah terdaftar sebagai siswa'
      });
    }

    // Check if NIS already exists
    const existingNIS = await Siswa.findOne({ nis });
    if (existingNIS) {
      return res.status(400).json({
        success: false,
        message: 'NIS sudah digunakan'
      });
    }

    // Create siswa with multiple classes
    const siswa = await Siswa.create({
      user_id,
      nis,
      kelas_ids: kelasIdsToUse, // Use multiple classes
      jenis_kelamin,
      tanggal_lahir,
      alamat,
      no_telepon,
      nama_orang_tua
    });

    // Populate user and kelas data
    await siswa.populate('user_id', 'nama_lengkap email');
    await siswa.populate('kelas_ids', 'nama tahun_ajaran');

    // Update class student counts
    await Kelas.updateMany(
      { _id: { $in: kelasIdsToUse } },
      { $inc: { jumlah_siswa: 1 } }
    );

    const kelasNames = validKelas.map(k => k.nama).join(', ');
    
    res.status(201).json({
      success: true,
      message: kelasIdsToUse.length > 1 
        ? `Siswa berhasil ditambahkan ke ${kelasIdsToUse.length} kelas: ${kelasNames}`
        : `Siswa berhasil ditambahkan ke kelas ${kelasNames}`,
      data: siswa
    });
  } catch (error) {
    console.error('Error creating siswa:', error);
    
    // Handle validation errors
    if (error.name === 'ValidationError') {
      const messages = Object.values(error.errors).map(err => err.message);
      return res.status(400).json({
        success: false,
        message: messages.join(', ')
      });
    }

    // Handle duplicate key error
    if (error.code === 11000) {
      const field = Object.keys(error.keyValue)[0];
      return res.status(400).json({
        success: false,
        message: `${field} sudah digunakan`
      });
    }

    res.status(500).json({
      success: false,
      message: 'Server error while creating siswa',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// @desc    Get all siswa
// @route   GET /api/siswa
// @access  Public
exports.getAllSiswa = async (req, res) => {
  try {
    const { kelas_id, jenis_kelamin, isActive } = req.query;
    
    // Build filter
    const filter = {};
    if (kelas_id) filter.kelas_ids = kelas_id; // Updated for multiple classes
    if (jenis_kelamin) filter.jenis_kelamin = jenis_kelamin;
    if (isActive !== undefined) filter.isActive = isActive === 'true';

    const siswa = await Siswa.find(filter)
      .populate('user_id', 'nama_lengkap email')
      .populate('kelas_ids', 'nama tahun_ajaran') // Updated for multiple classes
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      count: siswa.length,
      data: siswa
    });
  } catch (error) {
    console.error('Error getting siswa:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while getting siswa',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// @desc    Get siswa by ID
// @route   GET /api/siswa/:id
// @access  Public
exports.getSiswaById = async (req, res) => {
  try {
    const siswa = await Siswa.findById(req.params.id)
      .populate('user_id', 'nama_lengkap email')
      .populate('kelas_ids', 'nama tahun_ajaran'); // Updated for multiple classes

    if (!siswa) {
      return res.status(404).json({
        success: false,
        message: 'Siswa not found'
      });
    }

    res.status(200).json({
      success: true,
      data: siswa
    });
  } catch (error) {
    console.error('Error getting siswa by ID:', error);
    
    // Handle invalid ObjectId
    if (error.kind === 'ObjectId') {
      return res.status(404).json({
        success: false,
        message: 'Siswa not found'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Server error while getting siswa',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// @desc    Update siswa
// @route   PUT /api/siswa/:id
// @access  Private (Guru only)
exports.updateSiswa = async (req, res) => {
  try {
    const { 
      nama_lengkap, 
      nis, 
      email, 
      kelas_id, 
      jenis_kelamin, 
      tanggal_lahir, 
      alamat, 
      no_telepon, 
      nama_orang_tua,
      isActive 
    } = req.body;

    let siswa = await Siswa.findById(req.params.id);

    if (!siswa) {
      return res.status(404).json({
        success: false,
        message: 'Siswa not found'
      });
    }

    // Check if NIS is being changed and already exists
    if (nis && nis !== siswa.nis) {
      const existingNIS = await Siswa.findOne({ nis, _id: { $ne: req.params.id } });
      if (existingNIS) {
        return res.status(400).json({
          success: false,
          message: 'NIS sudah digunakan'
        });
      }
    }

    // Check if email is being changed and already exists
    if (email && email !== siswa.email) {
      const existingEmail = await Siswa.findOne({ email, _id: { $ne: req.params.id } });
      if (existingEmail) {
        return res.status(400).json({
          success: false,
          message: 'Email sudah digunakan'
        });
      }
    }

    // Verify kelas exists if kelas_id is being changed
    if (kelas_id && kelas_id !== siswa.kelas_id.toString()) {
      const kelas = await Kelas.findById(kelas_id);
      if (!kelas) {
        return res.status(404).json({
          success: false,
          message: 'Kelas not found'
        });
      }
    }

    // Update fields
    if (nama_lengkap !== undefined) siswa.nama_lengkap = nama_lengkap;
    if (nis !== undefined) siswa.nis = nis;
    if (email !== undefined) siswa.email = email;
    if (kelas_id !== undefined) siswa.kelas_id = kelas_id;
    if (jenis_kelamin !== undefined) siswa.jenis_kelamin = jenis_kelamin;
    if (tanggal_lahir !== undefined) siswa.tanggal_lahir = tanggal_lahir;
    if (alamat !== undefined) siswa.alamat = alamat;
    if (no_telepon !== undefined) siswa.no_telepon = no_telepon;
    if (nama_orang_tua !== undefined) siswa.nama_orang_tua = nama_orang_tua;
    if (isActive !== undefined) siswa.isActive = isActive;

    await siswa.save();
    await siswa.populate('kelas_id', 'nama tahun_ajaran');

    res.status(200).json({
      success: true,
      message: 'Siswa berhasil diupdate',
      data: siswa
    });
  } catch (error) {
    console.error('Error updating siswa:', error);
    
    // Handle validation errors
    if (error.name === 'ValidationError') {
      const messages = Object.values(error.errors).map(err => err.message);
      return res.status(400).json({
        success: false,
        message: messages.join(', ')
      });
    }

    // Handle duplicate key error
    if (error.code === 11000) {
      const field = Object.keys(error.keyValue)[0];
      return res.status(400).json({
        success: false,
        message: `${field} sudah digunakan`
      });
    }

    // Handle invalid ObjectId
    if (error.kind === 'ObjectId') {
      return res.status(404).json({
        success: false,
        message: 'Siswa not found'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Server error while updating siswa',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// @desc    Delete siswa
// @route   DELETE /api/siswa/:id
// @access  Private (Guru only)
exports.deleteSiswa = async (req, res) => {
  try {
    const siswa = await Siswa.findById(req.params.id);

    if (!siswa) {
      return res.status(404).json({
        success: false,
        message: 'Siswa not found'
      });
    }

    await siswa.deleteOne();

    res.status(200).json({
      success: true,
      message: 'Siswa berhasil dihapus',
      data: {}
    });
  } catch (error) {
    console.error('Error deleting siswa:', error);
    
    // Handle invalid ObjectId
    if (error.kind === 'ObjectId') {
      return res.status(404).json({
        success: false,
        message: 'Siswa not found'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Server error while deleting siswa',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// @desc    Search siswa
// @route   GET /api/siswa/search
// @access  Public
exports.searchSiswa = async (req, res) => {
  try {
    const { q, kelas_id } = req.query;

    if (!q) {
      return res.status(400).json({
        success: false,
        message: 'Search query is required'
      });
    }

    // Build filter
    const filter = {
      $or: [
        { nama_lengkap: { $regex: q, $options: 'i' } },
        { nis: { $regex: q, $options: 'i' } },
        { email: { $regex: q, $options: 'i' } }
      ]
    };

    if (kelas_id) {
      filter.kelas_id = kelas_id;
    }

    const siswa = await Siswa.find(filter)
      .populate('kelas_id', 'nama tahun_ajaran')
      .sort({ nama_lengkap: 1 })
      .limit(20);

    res.status(200).json({
      success: true,
      count: siswa.length,
      data: siswa
    });
  } catch (error) {
    console.error('Error searching siswa:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while searching siswa',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// @desc    Get siswa by kelas
// @route   GET /api/siswa/kelas/:kelasId
// @access  Public
exports.getSiswaByKelas = async (req, res) => {
  try {
    const { kelasId } = req.params;

    // Verify kelas exists
    const kelas = await Kelas.findById(kelasId);
    if (!kelas) {
      return res.status(404).json({
        success: false,
        message: 'Kelas not found'
      });
    }

    const siswa = await Siswa.find({ kelas_id: kelasId, isActive: true })
      .populate('user_id', 'nama_lengkap email')
      .populate('kelas_id', 'nama tahun_ajaran')
      .sort({ 'user_id.nama_lengkap': 1 });

    res.status(200).json({
      success: true,
      count: siswa.length,
      kelas: kelas,
      data: siswa
    });
  } catch (error) {
    console.error('Error getting siswa by kelas:', error);
    
    // Handle invalid ObjectId
    if (error.kind === 'ObjectId') {
      return res.status(404).json({
        success: false,
        message: 'Kelas not found'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Server error while getting siswa by kelas',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// @desc    Get siswa data by user ID (for student login)
// @route   GET /api/siswa/user/:userId
// @access  Public
exports.getSiswaByUserId = async (req, res) => {
  try {
    const { userId } = req.params;

    const siswa = await Siswa.findOne({ user_id: userId, isActive: true })
      .populate('user_id', 'nama_lengkap email')
      .populate({
        path: 'kelas_ids',
        select: 'nama tahun_ajaran guru_id',
        populate: {
          path: 'guru_id',
          select: 'nama_lengkap email'
        }
      }); // Updated to include guru data

    if (!siswa) {
      return res.status(404).json({
        success: false,
        message: 'Siswa data not found for this user'
      });
    }

    res.status(200).json({
      success: true,
      data: siswa
    });
  } catch (error) {
    console.error('Error getting siswa by user ID:', error);
    
    // Handle invalid ObjectId
    if (error.kind === 'ObjectId') {
      return res.status(404).json({
        success: false,
        message: 'Invalid user ID'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Server error while getting siswa by user ID',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// @desc    Get siswa by kelas (updated for multiple classes)
// @route   GET /api/siswa/kelas/:kelasId
// @access  Public
exports.getSiswaByKelas = async (req, res) => {
  try {
    const { kelasId } = req.params;
    
    // Find all siswa that have this kelas in their kelas_ids array
    const siswa = await Siswa.find({
      kelas_ids: kelasId,
      isActive: true
    }).populate([
      { path: 'user_id', select: 'nama_lengkap email' },
      { 
        path: 'kelas_ids', 
        select: 'nama tahun_ajaran guru_id',
        populate: {
          path: 'guru_id',
          select: 'nama_lengkap email'
        }
      }
    ]).sort({ createdAt: -1 });

    // Get kelas info
    const Kelas = require('../models/Kelas');
    const kelas = await Kelas.findById(kelasId).select('nama tahun_ajaran');

    res.json({
      success: true,
      data: siswa,
      count: siswa.length,
      kelas: kelas
    });
  } catch (error) {
    console.error('Error getting siswa by kelas:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan server: ' + error.message
    });
  }
};

// @desc    Add siswa to additional classes
// @route   POST /api/siswa/:siswaId/kelas
// @access  Private (Guru only)
exports.addSiswaToKelas = async (req, res) => {
  try {
    const { siswaId } = req.params;
    const { kelas_ids } = req.body;

    if (!Array.isArray(kelas_ids) || kelas_ids.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Kelas IDs harus berupa array dan tidak boleh kosong'
      });
    }

    const siswa = await Siswa.findById(siswaId);
    if (!siswa) {
      return res.status(404).json({
        success: false,
        message: 'Siswa tidak ditemukan'
      });
    }

    // Validate classes exist
    const Kelas = require('../models/Kelas');
    const validKelas = await Kelas.find({ 
      _id: { $in: kelas_ids },
      isActive: true 
    });
    
    if (validKelas.length !== kelas_ids.length) {
      return res.status(400).json({
        success: false,
        message: 'Satu atau lebih kelas tidak valid'
      });
    }

    // Add new classes (avoid duplicates)
    const currentKelasIds = siswa.kelas_ids.map(id => id.toString());
    const newKelasIds = kelas_ids.filter(id => !currentKelasIds.includes(id));
    
    if (newKelasIds.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Siswa sudah terdaftar di semua kelas yang dipilih'
      });
    }

    // Update siswa
    siswa.kelas_ids.push(...newKelasIds);
    await siswa.save();

    // Update class student counts
    await Kelas.updateMany(
      { _id: { $in: newKelasIds } },
      { $inc: { jumlah_siswa: 1 } }
    );

    await siswa.populate([
      { path: 'kelas_ids', select: 'nama tahun_ajaran' },
      { path: 'user_id', select: 'nama_lengkap email' }
    ]);

    res.json({
      success: true,
      message: `Siswa berhasil ditambahkan ke ${newKelasIds.length} kelas baru`,
      data: siswa
    });

  } catch (error) {
    console.error('Error adding siswa to kelas:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan server: ' + error.message
    });
  }
};
