const Materi = require('../models/Materi');
const Kelas = require('../models/Kelas');

// @desc    Create new materi
// @route   POST /api/materi
// @access  Private (Guru only)
const createMateri = async (req, res) => {
  try {
    const {
      judul,
      deskripsi,
      konten,
      kelas_id,
      guru_id,
      tipe_materi,
      file_url,
      urutan,
      tags
    } = req.body;

    // Validate required fields
    if (!judul || !konten || !kelas_id || !guru_id) {
      return res.status(400).json({
        success: false,
        message: 'Judul, konten, kelas_id, dan guru_id wajib diisi'
      });
    }

    // Verify kelas exists and guru has access
    const kelas = await Kelas.findOne({ 
      _id: kelas_id, 
      guru_id: guru_id,
      isActive: true 
    });
    
    if (!kelas) {
      return res.status(403).json({
        success: false,
        message: 'Anda tidak memiliki akses ke kelas ini'
      });
    }

    // Create materi
    const materi = await Materi.create({
      judul,
      deskripsi,
      konten,
      kelas_id,
      guru_id,
      tipe_materi: tipe_materi || 'teks',
      file_url,
      urutan,
      tags: tags || []
    });

    // Populate related data
    await materi.populate([
      { path: 'guru_id', select: 'nama_lengkap email' },
      { path: 'kelas_id', select: 'nama tahun_ajaran' }
    ]);

    res.status(201).json({
      success: true,
      message: 'Materi berhasil dibuat',
      data: materi
    });

  } catch (error) {
    console.error('Error creating materi:', error);
    
    // Handle validation errors
    if (error.name === 'ValidationError') {
      const messages = Object.values(error.errors).map(err => err.message);
      return res.status(400).json({
        success: false,
        message: messages.join(', ')
      });
    }

    // Handle duplicate urutan error
    if (error.code === 11000 && error.keyPattern?.urutan) {
      return res.status(400).json({
        success: false,
        message: 'Urutan materi sudah ada untuk kelas ini'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Server error while creating materi',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// @desc    Get all materi by kelas
// @route   GET /api/materi/kelas/:kelasId
// @access  Public
const getMateriByKelas = async (req, res) => {
  try {
    const { kelasId } = req.params;
    const {
      page = 1,
      limit = 10,
      sortBy = 'urutan',
      sortOrder = 'asc',
      search = '',
      tipe_materi = null
    } = req.query;

    // Verify kelas exists
    const kelas = await Kelas.findById(kelasId);
    if (!kelas) {
      return res.status(404).json({
        success: false,
        message: 'Kelas tidak ditemukan'
      });
    }

    // Get materi with pagination and filters
    const materi = await Materi.getByKelas(kelasId, {
      page: parseInt(page),
      limit: parseInt(limit),
      sortBy,
      sortOrder,
      search,
      tipeMateri: tipe_materi
    });

    // Get total count for pagination
    const totalQuery = { kelas_id: kelasId, isActive: true };
    if (search) {
      totalQuery.$text = { $search: search };
    }
    if (tipe_materi) {
      totalQuery.tipe_materi = tipe_materi;
    }

    const total = await Materi.countDocuments(totalQuery);

    // Get statistics
    const stats = await Materi.getStatistics(kelasId);

    res.json({
      success: true,
      data: materi,
      pagination: {
        current_page: parseInt(page),
        total_pages: Math.ceil(total / limit),
        total_items: total,
        items_per_page: parseInt(limit)
      },
      statistics: stats,
      kelas: {
        _id: kelas._id,
        nama: kelas.nama,
        tahun_ajaran: kelas.tahun_ajaran
      }
    });

  } catch (error) {
    console.error('Error getting materi by kelas:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while getting materi',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// @desc    Get materi by ID
// @route   GET /api/materi/:id
// @access  Public
const getMateriById = async (req, res) => {
  try {
    const materi = await Materi.findById(req.params.id)
      .populate('guru_id', 'nama_lengkap email')
      .populate('kelas_id', 'nama tahun_ajaran');

    if (!materi || !materi.isActive) {
      return res.status(404).json({
        success: false,
        message: 'Materi tidak ditemukan'
      });
    }

    // Increment views
    await materi.incrementViews();

    res.json({
      success: true,
      data: materi
    });

  } catch (error) {
    console.error('Error getting materi by ID:', error);
    
    // Handle invalid ObjectId
    if (error.kind === 'ObjectId') {
      return res.status(404).json({
        success: false,
        message: 'Materi tidak ditemukan'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Server error while getting materi',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// @desc    Update materi
// @route   PUT /api/materi/:id
// @access  Private (Guru only)
const updateMateri = async (req, res) => {
  try {
    const {
      judul,
      deskripsi,
      konten,
      tipe_materi,
      file_url,
      urutan,
      tags,
      isActive
    } = req.body;

    let materi = await Materi.findById(req.params.id);

    if (!materi) {
      return res.status(404).json({
        success: false,
        message: 'Materi tidak ditemukan'
      });
    }

    // Check if user is the owner (guru) of this materi
    if (materi.guru_id.toString() !== req.body.guru_id) {
      return res.status(403).json({
        success: false,
        message: 'Anda tidak memiliki akses untuk mengubah materi ini'
      });
    }

    // Update fields
    const updateData = {};
    if (judul !== undefined) updateData.judul = judul;
    if (deskripsi !== undefined) updateData.deskripsi = deskripsi;
    if (konten !== undefined) updateData.konten = konten;
    if (tipe_materi !== undefined) updateData.tipe_materi = tipe_materi;
    if (file_url !== undefined) updateData.file_url = file_url;
    if (urutan !== undefined) updateData.urutan = urutan;
    if (tags !== undefined) updateData.tags = tags;
    if (isActive !== undefined) updateData.isActive = isActive;

    materi = await Materi.findByIdAndUpdate(
      req.params.id,
      updateData,
      { new: true, runValidators: true }
    ).populate([
      { path: 'guru_id', select: 'nama_lengkap email' },
      { path: 'kelas_id', select: 'nama tahun_ajaran' }
    ]);

    res.json({
      success: true,
      message: 'Materi berhasil diupdate',
      data: materi
    });

  } catch (error) {
    console.error('Error updating materi:', error);
    
    // Handle validation errors
    if (error.name === 'ValidationError') {
      const messages = Object.values(error.errors).map(err => err.message);
      return res.status(400).json({
        success: false,
        message: messages.join(', ')
      });
    }

    // Handle duplicate urutan error
    if (error.code === 11000 && error.keyPattern?.urutan) {
      return res.status(400).json({
        success: false,
        message: 'Urutan materi sudah ada untuk kelas ini'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Server error while updating materi',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// @desc    Delete materi (soft delete)
// @route   DELETE /api/materi/:id
// @access  Private (Guru only)
const deleteMateri = async (req, res) => {
  try {
    const materi = await Materi.findById(req.params.id);

    if (!materi) {
      return res.status(404).json({
        success: false,
        message: 'Materi tidak ditemukan'
      });
    }

    // Check if user is the owner (guru) of this materi
    if (materi.guru_id.toString() !== req.body.guru_id) {
      return res.status(403).json({
        success: false,
        message: 'Anda tidak memiliki akses untuk menghapus materi ini'
      });
    }

    // Soft delete
    materi.isActive = false;
    await materi.save();

    res.json({
      success: true,
      message: 'Materi berhasil dihapus'
    });

  } catch (error) {
    console.error('Error deleting materi:', error);
    
    // Handle invalid ObjectId
    if (error.kind === 'ObjectId') {
      return res.status(404).json({
        success: false,
        message: 'Materi tidak ditemukan'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Server error while deleting materi',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// @desc    Reorder materi
// @route   PUT /api/materi/reorder
// @access  Private (Guru only)
const reorderMateri = async (req, res) => {
  try {
    const { kelas_id, guru_id, materi_orders } = req.body;

    if (!kelas_id || !guru_id || !Array.isArray(materi_orders)) {
      return res.status(400).json({
        success: false,
        message: 'kelas_id, guru_id, dan materi_orders (array) wajib diisi'
      });
    }

    // Verify kelas exists and guru has access
    const kelas = await Kelas.findOne({ 
      _id: kelas_id, 
      guru_id: guru_id,
      isActive: true 
    });
    
    if (!kelas) {
      return res.status(403).json({
        success: false,
        message: 'Anda tidak memiliki akses ke kelas ini'
      });
    }

    // Update urutan for each materi
    const updatePromises = materi_orders.map((item, index) => {
      return Materi.findByIdAndUpdate(
        item.materi_id,
        { urutan: index + 1 },
        { new: true }
      );
    });

    await Promise.all(updatePromises);

    // Get updated materi list
    const updatedMateri = await Materi.find({
      kelas_id: kelas_id,
      isActive: true
    }).sort({ urutan: 1 })
      .populate('guru_id', 'nama_lengkap email');

    res.json({
      success: true,
      message: 'Urutan materi berhasil diupdate',
      data: updatedMateri
    });

  } catch (error) {
    console.error('Error reordering materi:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while reordering materi',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// @desc    Search materi across all kelas
// @route   GET /api/materi/search
// @access  Public
const searchMateri = async (req, res) => {
  try {
    const {
      q = '',
      kelas_id = null,
      tipe_materi = null,
      page = 1,
      limit = 10
    } = req.query;

    if (!q || q.trim().length < 2) {
      return res.status(400).json({
        success: false,
        message: 'Query pencarian minimal 2 karakter'
      });
    }

    // Build search query
    const searchQuery = {
      $text: { $search: q },
      isActive: true
    };

    if (kelas_id) {
      searchQuery.kelas_id = kelas_id;
    }

    if (tipe_materi) {
      searchQuery.tipe_materi = tipe_materi;
    }

    // Execute search with pagination
    const materi = await Materi.find(searchQuery, { score: { $meta: 'textScore' } })
      .populate('guru_id', 'nama_lengkap email')
      .populate('kelas_id', 'nama tahun_ajaran')
      .sort({ score: { $meta: 'textScore' }, createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);

    const total = await Materi.countDocuments(searchQuery);

    res.json({
      success: true,
      data: materi,
      pagination: {
        current_page: parseInt(page),
        total_pages: Math.ceil(total / limit),
        total_items: total,
        items_per_page: parseInt(limit)
      },
      query: q
    });

  } catch (error) {
    console.error('Error searching materi:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while searching materi',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

module.exports = {
  createMateri,
  getMateriByKelas,
  getMateriById,
  updateMateri,
  deleteMateri,
  reorderMateri,
  searchMateri
};
