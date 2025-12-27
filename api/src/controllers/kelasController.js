const Kelas = require('../models/Kelas');
const User = require('../models/User');

// @desc    Create new kelas
// @route   POST /api/kelas
// @access  Private (Guru only)
exports.createKelas = async (req, res) => {
  try {
    const { nama, guru_id, tahun_ajaran } = req.body;

    // Validate required fields
    if (!nama) {
      return res.status(400).json({
        success: false,
        message: 'Nama kelas is required'
      });
    }

    if (!guru_id) {
      return res.status(400).json({
        success: false,
        message: 'Guru ID is required'
      });
    }

    // Verify guru exists and has guru role
    const guru = await User.findById(guru_id);
    if (!guru) {
      return res.status(404).json({
        success: false,
        message: 'Guru not found'
      });
    }

    if (guru.role !== 'guru') {
      return res.status(403).json({
        success: false,
        message: 'Only guru can create a class'
      });
    }

    // Create kelas
    const kelas = await Kelas.create({
      nama,
      guru_id,
      tahun_ajaran: tahun_ajaran || new Date().getFullYear().toString()
    });

    // Populate guru data
    await kelas.populate('guru_id', 'nama_lengkap email');

    res.status(201).json({
      success: true,
      message: 'Kelas created successfully',
      data: kelas
    });
  } catch (error) {
    console.error('Error creating kelas:', error);
    
    // Handle validation errors
    if (error.name === 'ValidationError') {
      const messages = Object.values(error.errors).map(err => err.message);
      return res.status(400).json({
        success: false,
        message: messages.join(', ')
      });
    }

    res.status(500).json({
      success: false,
      message: 'Server error while creating kelas',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// @desc    Get all kelas
// @route   GET /api/kelas
// @access  Public
exports.getAllKelas = async (req, res) => {
  try {
    const { guru_id, tahun_ajaran, isActive } = req.query;
    
    // Build filter
    const filter = {};
    if (guru_id) filter.guru_id = guru_id;
    if (tahun_ajaran) filter.tahun_ajaran = tahun_ajaran;
    if (isActive !== undefined) filter.isActive = isActive === 'true';

    const kelas = await Kelas.find(filter)
      .populate('guru_id', 'nama_lengkap email')
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      count: kelas.length,
      data: kelas
    });
  } catch (error) {
    console.error('Error getting kelas:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while getting kelas',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// @desc    Get kelas by ID
// @route   GET /api/kelas/:id
// @access  Public
exports.getKelasById = async (req, res) => {
  try {
    const kelas = await Kelas.findById(req.params.id)
      .populate('guru_id', 'nama_lengkap email');

    if (!kelas) {
      return res.status(404).json({
        success: false,
        message: 'Kelas not found'
      });
    }

    res.status(200).json({
      success: true,
      data: kelas
    });
  } catch (error) {
    console.error('Error getting kelas by ID:', error);
    
    // Handle invalid ObjectId
    if (error.kind === 'ObjectId') {
      return res.status(404).json({
        success: false,
        message: 'Kelas not found'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Server error while getting kelas',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// @desc    Update kelas
// @route   PUT /api/kelas/:id
// @access  Private (Guru only)
exports.updateKelas = async (req, res) => {
  try {
    const { nama, tahun_ajaran, isActive } = req.body;

    let kelas = await Kelas.findById(req.params.id);

    if (!kelas) {
      return res.status(404).json({
        success: false,
        message: 'Kelas not found'
      });
    }

    // Update fields
    if (nama !== undefined) kelas.nama = nama;
    if (tahun_ajaran !== undefined) kelas.tahun_ajaran = tahun_ajaran;
    if (isActive !== undefined) kelas.isActive = isActive;

    await kelas.save();
    await kelas.populate('guru_id', 'nama_lengkap email');

    res.status(200).json({
      success: true,
      message: 'Kelas updated successfully',
      data: kelas
    });
  } catch (error) {
    console.error('Error updating kelas:', error);
    
    // Handle validation errors
    if (error.name === 'ValidationError') {
      const messages = Object.values(error.errors).map(err => err.message);
      return res.status(400).json({
        success: false,
        message: messages.join(', ')
      });
    }

    // Handle invalid ObjectId
    if (error.kind === 'ObjectId') {
      return res.status(404).json({
        success: false,
        message: 'Kelas not found'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Server error while updating kelas',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// @desc    Delete kelas
// @route   DELETE /api/kelas/:id
// @access  Private (Guru only)
exports.deleteKelas = async (req, res) => {
  try {
    const kelas = await Kelas.findById(req.params.id);

    if (!kelas) {
      return res.status(404).json({
        success: false,
        message: 'Kelas not found'
      });
    }

    await kelas.deleteOne();

    res.status(200).json({
      success: true,
      message: 'Kelas deleted successfully',
      data: {}
    });
  } catch (error) {
    console.error('Error deleting kelas:', error);
    
    // Handle invalid ObjectId
    if (error.kind === 'ObjectId') {
      return res.status(404).json({
        success: false,
        message: 'Kelas not found'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Server error while deleting kelas',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// @desc    Search kelas
// @route   GET /api/kelas/search
// @access  Public
exports.searchKelas = async (req, res) => {
  try {
    const { q, guru_id } = req.query;

    if (!q) {
      return res.status(400).json({
        success: false,
        message: 'Search query is required'
      });
    }

    // Build filter
    const filter = {
      nama: { $regex: q, $options: 'i' }
    };

    if (guru_id) {
      filter.guru_id = guru_id;
    }

    const kelas = await Kelas.find(filter)
      .populate('guru_id', 'nama_lengkap email')
      .sort({ nama: 1 })
      .limit(20);

    res.status(200).json({
      success: true,
      count: kelas.length,
      data: kelas
    });
  } catch (error) {
    console.error('Error searching kelas:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while searching kelas',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};
