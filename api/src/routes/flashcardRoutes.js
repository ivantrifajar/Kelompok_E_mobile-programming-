const express = require('express');
const router = express.Router();
const {
  createFlashcard,
  getAllFlashcards,
  getFlashcardById,
  updateFlashcard,
  deleteFlashcard,
  toggleActiveStatus,
  getFlashcardsByKelas,
  searchFlashcards
} = require('../controllers/flashcardController');

// @route   POST /api/flashcards
// @desc    Create new flashcard
// @access  Private (Guru only)
router.post('/', createFlashcard);

// @route   GET /api/flashcards
// @desc    Get all flashcards with pagination and filters
// @access  Private
router.get('/', getAllFlashcards);

// @route   GET /api/flashcards/search
// @desc    Search flashcards
// @access  Private
router.get('/search', searchFlashcards);

// @route   GET /api/flashcards/kelas/:kelasId
// @desc    Get flashcards by kelas
// @access  Private
router.get('/kelas/:kelasId', getFlashcardsByKelas);

// @route   GET /api/flashcards/:id
// @desc    Get flashcard by ID
// @access  Private
router.get('/:id', getFlashcardById);

// @route   PUT /api/flashcards/:id
// @desc    Update flashcard
// @access  Private (Guru only - own flashcards)
router.put('/:id', updateFlashcard);

// @route   DELETE /api/flashcards/:id
// @desc    Delete flashcard
// @access  Private (Guru only - own flashcards)
router.delete('/:id', deleteFlashcard);

// @route   PATCH /api/flashcards/:id/toggle-active
// @desc    Toggle flashcard active status
// @access  Private (Guru only - own flashcards)
router.patch('/:id/toggle-active', toggleActiveStatus);

module.exports = router;
