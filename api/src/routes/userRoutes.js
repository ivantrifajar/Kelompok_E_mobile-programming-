const express = require('express');
const router = express.Router();
const {
  register,
  login,
  getAllUsers,
  getUserById,
  createUser,
  updateUser,
  deleteUser,
  searchUsers,
  searchAvailableSiswa
} = require('../controllers/userController');

// Authentication routes
router.post('/register', register);
router.post('/login', login);

// Search routes (must be before /:id route)
router.get('/search', searchUsers);
router.get('/search-siswa', searchAvailableSiswa);

// Main routes
router.route('/')
  .get(getAllUsers)
  .post(createUser);

router.route('/:id')
  .get(getUserById)
  .put(updateUser)
  .delete(deleteUser);

module.exports = router;
