const express = require('express');
const router = express.Router();
const {
  createMateri,
  getMateriByKelas,
  getMateriById,
  updateMateri,
  deleteMateri,
  reorderMateri,
  searchMateri
} = require('../controllers/materiController');

// @route   POST /api/materi
// @desc    Create new materi
// @access  Private (Guru only)
router.post('/', createMateri);

// @route   GET /api/materi/search
// @desc    Search materi across all kelas
// @access  Public
router.get('/search', searchMateri);

// @route   GET /api/materi/kelas/:kelasId
// @desc    Get all materi by kelas with pagination and filters
// @access  Public
router.get('/kelas/:kelasId', getMateriByKelas);

// @route   PUT /api/materi/reorder
// @desc    Reorder materi in a kelas
// @access  Private (Guru only)
router.put('/reorder', reorderMateri);

// @route   GET /api/materi/:id
// @desc    Get materi by ID
// @access  Public
router.get('/:id', getMateriById);

// @route   PUT /api/materi/:id
// @desc    Update materi
// @access  Private (Guru only)
router.put('/:id', updateMateri);

// @route   DELETE /api/materi/:id
// @desc    Delete materi (soft delete)
// @access  Private (Guru only)
router.delete('/:id', deleteMateri);

module.exports = router;
