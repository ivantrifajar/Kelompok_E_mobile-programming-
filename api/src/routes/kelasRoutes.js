const express = require('express');
const router = express.Router();
const {
  createKelas,
  getAllKelas,
  getKelasById,
  updateKelas,
  deleteKelas,
  searchKelas
} = require('../controllers/kelasController');

// Search route (must be before /:id route)
router.get('/search', searchKelas);

// Main routes
router.route('/')
  .get(getAllKelas)
  .post(createKelas);

router.route('/:id')
  .get(getKelasById)
  .put(updateKelas)
  .delete(deleteKelas);

module.exports = router;
