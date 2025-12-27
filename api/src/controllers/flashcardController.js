const Flashcard = require('../models/Flashcard');
const Kelas = require('../models/Kelas');
const User = require('../models/User');

// @desc    Create new flashcard
// @route   POST /api/flashcards
// @access  Private (Guru only)
exports.createFlashcard = async (req, res) => {
  try {
    const { judul, topik, deskripsi, kelas_id, guru_id, kartu } = req.body;

    // Validate required fields
    if (!judul || !topik || !deskripsi || !kelas_id || !guru_id || !kartu) {
      return res.status(400).json({
        success: false,
        message: 'All fields are required (judul, topik, deskripsi, kelas_id, guru_id, kartu)'
      });
    }

    // Validate kartu array
    if (!Array.isArray(kartu) || kartu.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'At least one flashcard item is required'
      });
    }

    // Validate each kartu item
    for (let i = 0; i < kartu.length; i++) {
      const item = kartu[i];
      if (!item.pertanyaan || !item.jawaban) {
        return res.status(400).json({
          success: false,
          message: `Flashcard item ${i + 1}: pertanyaan and jawaban are required`
        });
      }
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
        message: 'Only guru can create flashcards'
      });
    }

    // Verify kelas exists
    const kelas = await Kelas.findById(kelas_id);
    if (!kelas) {
      return res.status(404).json({
        success: false,
        message: 'Kelas not found'
      });
    }

    // Create flashcard
    const flashcard = await Flashcard.create({
      judul,
      topik,
      deskripsi,
      kelas_id,
      guru_id,
      kartu
    });

    // Populate references
    await flashcard.populate([
      { path: 'kelas_id', select: 'nama tahun_ajaran' },
      { path: 'guru_id', select: 'nama_lengkap email' }
    ]);

    res.status(201).json({
      success: true,
      message: 'Flashcard created successfully',
      data: flashcard
    });

  } catch (error) {
    console.error('Create flashcard error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

// @desc    Get all flashcards
// @route   GET /api/flashcards
// @access  Private
exports.getAllFlashcards = async (req, res) => {
  try {
    const { kelas_id, guru_id, isActive, page = 1, limit = 10, search } = req.query;

    // Build filter object
    const filter = {};
    if (kelas_id) filter.kelas_id = kelas_id;
    if (guru_id) filter.guru_id = guru_id;
    if (isActive !== undefined) filter.isActive = isActive === 'true';

    // Add search functionality
    if (search) {
      filter.$or = [
        { judul: { $regex: search, $options: 'i' } },
        { topik: { $regex: search, $options: 'i' } },
        { deskripsi: { $regex: search, $options: 'i' } }
      ];
    }

    // Calculate pagination
    const skip = (parseInt(page) - 1) * parseInt(limit);

    // Get flashcards with pagination
    const flashcards = await Flashcard.find(filter)
      .populate([
        { path: 'kelas_id', select: 'nama tahun_ajaran' },
        { path: 'guru_id', select: 'nama_lengkap email' }
      ])
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(parseInt(limit));

    // Get total count for pagination
    const total = await Flashcard.countDocuments(filter);

    res.json({
      success: true,
      data: flashcards,
      pagination: {
        current_page: parseInt(page),
        per_page: parseInt(limit),
        total: total,
        total_pages: Math.ceil(total / parseInt(limit))
      }
    });

  } catch (error) {
    console.error('Get flashcards error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

// @desc    Get flashcard by ID
// @route   GET /api/flashcards/:id
// @access  Private
exports.getFlashcardById = async (req, res) => {
  try {
    const { id } = req.params;

    const flashcard = await Flashcard.findById(id)
      .populate([
        { path: 'kelas_id', select: 'nama tahun_ajaran' },
        { path: 'guru_id', select: 'nama_lengkap email' }
      ]);

    if (!flashcard) {
      return res.status(404).json({
        success: false,
        message: 'Flashcard not found'
      });
    }

    // Increment view count
    await Flashcard.findByIdAndUpdate(id, { $inc: { totalViews: 1 } });

    res.json({
      success: true,
      data: flashcard
    });

  } catch (error) {
    console.error('Get flashcard by ID error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

// @desc    Update flashcard
// @route   PUT /api/flashcards/:id
// @access  Private (Guru only - own flashcards)
exports.updateFlashcard = async (req, res) => {
  try {
    const { id } = req.params;
    const { judul, topik, deskripsi, kelas_id, kartu } = req.body;

    // Find existing flashcard
    const existingFlashcard = await Flashcard.findById(id);
    if (!existingFlashcard) {
      return res.status(404).json({
        success: false,
        message: 'Flashcard not found'
      });
    }

    // Validate kartu if provided
    if (kartu) {
      if (!Array.isArray(kartu) || kartu.length === 0) {
        return res.status(400).json({
          success: false,
          message: 'At least one flashcard item is required'
        });
      }

      // Validate each kartu item
      for (let i = 0; i < kartu.length; i++) {
        const item = kartu[i];
        if (!item.pertanyaan || !item.jawaban) {
          return res.status(400).json({
            success: false,
            message: `Flashcard item ${i + 1}: pertanyaan and jawaban are required`
          });
        }
      }
    }

    // Verify kelas exists if kelas_id is being updated
    if (kelas_id && kelas_id !== existingFlashcard.kelas_id.toString()) {
      const kelas = await Kelas.findById(kelas_id);
      if (!kelas) {
        return res.status(404).json({
          success: false,
          message: 'Kelas not found'
        });
      }
    }

    // Build update object
    const updateData = {};
    if (judul) updateData.judul = judul;
    if (topik) updateData.topik = topik;
    if (deskripsi) updateData.deskripsi = deskripsi;
    if (kelas_id) updateData.kelas_id = kelas_id;
    if (kartu) updateData.kartu = kartu;

    // Update flashcard
    const flashcard = await Flashcard.findByIdAndUpdate(
      id,
      updateData,
      { new: true, runValidators: true }
    ).populate([
      { path: 'kelas_id', select: 'nama tahun_ajaran' },
      { path: 'guru_id', select: 'nama_lengkap email' }
    ]);

    res.json({
      success: true,
      message: 'Flashcard updated successfully',
      data: flashcard
    });

  } catch (error) {
    console.error('Update flashcard error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

// @desc    Delete flashcard
// @route   DELETE /api/flashcards/:id
// @access  Private (Guru only - own flashcards)
exports.deleteFlashcard = async (req, res) => {
  try {
    const { id } = req.params;

    const flashcard = await Flashcard.findById(id);
    if (!flashcard) {
      return res.status(404).json({
        success: false,
        message: 'Flashcard not found'
      });
    }

    await Flashcard.findByIdAndDelete(id);

    res.json({
      success: true,
      message: 'Flashcard deleted successfully'
    });

  } catch (error) {
    console.error('Delete flashcard error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

// @desc    Toggle flashcard active status
// @route   PATCH /api/flashcards/:id/toggle-active
// @access  Private (Guru only - own flashcards)
exports.toggleActiveStatus = async (req, res) => {
  try {
    const { id } = req.params;

    const flashcard = await Flashcard.findById(id);
    if (!flashcard) {
      return res.status(404).json({
        success: false,
        message: 'Flashcard not found'
      });
    }

    // Toggle active status
    flashcard.isActive = !flashcard.isActive;
    await flashcard.save();

    await flashcard.populate([
      { path: 'kelas_id', select: 'nama tahun_ajaran' },
      { path: 'guru_id', select: 'nama_lengkap email' }
    ]);

    res.json({
      success: true,
      message: `Flashcard ${flashcard.isActive ? 'activated' : 'deactivated'} successfully`,
      data: flashcard
    });

  } catch (error) {
    console.error('Toggle active status error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

// @desc    Get flashcards by kelas
// @route   GET /api/flashcards/kelas/:kelasId
// @access  Private
exports.getFlashcardsByKelas = async (req, res) => {
  try {
    const { kelasId } = req.params;
    const { isActive = true } = req.query;

    // Verify kelas exists
    const kelas = await Kelas.findById(kelasId);
    if (!kelas) {
      return res.status(404).json({
        success: false,
        message: 'Kelas not found'
      });
    }

    const filter = { kelas_id: kelasId };
    if (isActive !== undefined) filter.isActive = isActive === 'true';

    const flashcards = await Flashcard.find(filter)
      .populate([
        { path: 'kelas_id', select: 'nama tahun_ajaran' },
        { path: 'guru_id', select: 'nama_lengkap email' }
      ])
      .sort({ createdAt: -1 });

    res.json({
      success: true,
      data: flashcards,
      count: flashcards.length
    });

  } catch (error) {
    console.error('Get flashcards by kelas error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

// @desc    Search flashcards
// @route   GET /api/flashcards/search
// @access  Private
exports.searchFlashcards = async (req, res) => {
  try {
    const { q, kelas_id, guru_id } = req.query;

    if (!q) {
      return res.status(400).json({
        success: false,
        message: 'Search query is required'
      });
    }

    // Build filter
    const filter = {
      isActive: true,
      $or: [
        { judul: { $regex: q, $options: 'i' } },
        { topik: { $regex: q, $options: 'i' } },
        { deskripsi: { $regex: q, $options: 'i' } }
      ]
    };

    if (kelas_id) filter.kelas_id = kelas_id;
    if (guru_id) filter.guru_id = guru_id;

    const flashcards = await Flashcard.find(filter)
      .populate([
        { path: 'kelas_id', select: 'nama tahun_ajaran' },
        { path: 'guru_id', select: 'nama_lengkap email' }
      ])
      .sort({ createdAt: -1 })
      .limit(20);

    res.json({
      success: true,
      data: flashcards,
      count: flashcards.length
    });

  } catch (error) {
    console.error('Search flashcards error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};
