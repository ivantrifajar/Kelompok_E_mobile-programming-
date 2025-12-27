const express = require('express');
const router = express.Router();
const {
  createSiswa,
  getAllSiswa,
  getSiswaById,
  updateSiswa,
  deleteSiswa,
  searchSiswa,
  getSiswaByKelas,
  getSiswaByUserId
} = require('../controllers/siswaController');

// Search route (must be before /:id route)
router.get('/search', searchSiswa);

// Get siswa by kelas
router.get('/kelas/:kelasId', getSiswaByKelas);

// Get siswa by user ID
router.get('/user/:userId', getSiswaByUserId);

// Main routes
router.route('/')
  .get(getAllSiswa)
  .post(createSiswa);

router.route('/:id')
  .get(getSiswaById)
  .put(updateSiswa)
  .delete(deleteSiswa);

module.exports = router;
