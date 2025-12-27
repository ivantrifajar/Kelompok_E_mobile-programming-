const User = require('../models/User');

// @desc    Register new user
// @route   POST /api/users/register
// @access  Public
exports.register = async (req, res) => {
  try {
    const { nama_lengkap, email, password, role } = req.body;

    // Check if user already exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'Email already registered'
      });
    }

    // Create user
    const user = await User.create({
      nama_lengkap,
      email,
      password,
      role: role || 'siswa'
    });

    // Return user without password
    const userResponse = {
      _id: user._id,
      nama_lengkap: user.nama_lengkap,
      email: user.email,
      role: user.role,
      isActive: user.isActive,
      createdAt: user.createdAt
    };

    res.status(201).json({
      success: true,
      message: 'User registered successfully',
      data: userResponse
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      message: 'Error registering user',
      error: error.message
    });
  }
};

// @desc    Login user
// @route   POST /api/users/login
// @access  Public
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validate input
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Please provide email and password'
      });
    }

    // Find user with password field
    const user = await User.findOne({ email }).select('+password');

    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials'
      });
    }

    // Check if user is active
    if (!user.isActive) {
      return res.status(401).json({
        success: false,
        message: 'Account is deactivated'
      });
    }

    // Compare password
    const isMatch = await user.comparePassword(password);

    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials'
      });
    }

    // Return user data without password
    const userResponse = {
      _id: user._id,
      nama_lengkap: user.nama_lengkap,
      email: user.email,
      role: user.role,
      isActive: user.isActive
    };

    res.status(200).json({
      success: true,
      message: 'Login successful',
      data: userResponse
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error logging in',
      error: error.message
    });
  }
};

// @desc    Get all users
// @route   GET /api/users
// @access  Public
exports.getAllUsers = async (req, res) => {
  try {
    const { role } = req.query;
    
    // Filter by role if provided
    const filter = role ? { role } : {};
    
    const users = await User.find(filter).sort({ createdAt: -1 });
    
    res.status(200).json({
      success: true,
      count: users.length,
      data: users
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching users',
      error: error.message
    });
  }
};

// @desc    Get single user by ID
// @route   GET /api/users/:id
// @access  Public
exports.getUserById = async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    res.status(200).json({
      success: true,
      data: user
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching user',
      error: error.message
    });
  }
};

// @desc    Create new user (Admin only - without password hashing in request)
// @route   POST /api/users
// @access  Public
exports.createUser = async (req, res) => {
  try {
    const user = await User.create(req.body);
    
    // Return user without password
    const userResponse = {
      _id: user._id,
      nama_lengkap: user.nama_lengkap,
      email: user.email,
      role: user.role,
      isActive: user.isActive,
      createdAt: user.createdAt
    };
    
    res.status(201).json({
      success: true,
      message: 'User created successfully',
      data: userResponse
    });
  } catch (error) {
    // Handle duplicate email error
    if (error.code === 11000) {
      return res.status(400).json({
        success: false,
        message: 'Email already exists'
      });
    }
    
    res.status(400).json({
      success: false,
      message: 'Error creating user',
      error: error.message
    });
  }
};

// @desc    Update user
// @route   PUT /api/users/:id
// @access  Public
exports.updateUser = async (req, res) => {
  try {
    const user = await User.findByIdAndUpdate(
      req.params.id,
      req.body,
      {
        new: true,
        runValidators: true
      }
    );

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    res.status(200).json({
      success: true,
      message: 'User updated successfully',
      data: user
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      message: 'Error updating user',
      error: error.message
    });
  }
};

// @desc    Delete user
// @route   DELETE /api/users/:id
// @access  Public
exports.deleteUser = async (req, res) => {
  try {
    const user = await User.findByIdAndDelete(req.params.id);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    res.status(200).json({
      success: true,
      message: 'User deleted successfully',
      data: {}
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error deleting user',
      error: error.message
    });
  }
};

// @desc    Search users by nama_lengkap or email
// @route   GET /api/users/search?q=keyword
// @access  Public
exports.searchUsers = async (req, res) => {
  try {
    const keyword = req.query.q;
    const role = req.query.role;
    
    if (!keyword) {
      return res.status(400).json({
        success: false,
        message: 'Search keyword is required'
      });
    }

    const searchFilter = {
      $or: [
        { nama_lengkap: { $regex: keyword, $options: 'i' } },
        { email: { $regex: keyword, $options: 'i' } }
      ]
    };

    // Add role filter if provided
    if (role) {
      searchFilter.role = role;
    }

    const users = await User.find(searchFilter);

    res.status(200).json({
      success: true,
      count: users.length,
      data: users
    });
  } catch (error) {
    console.error('Error searching users:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while searching users',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// @desc    Search available siswa users (not yet assigned to any class)
// @route   GET /api/users/search-siswa
// @access  Public
exports.searchAvailableSiswa = async (req, res) => {
  try {
    const { q } = req.query;

    if (!q) {
      return res.status(400).json({
        success: false,
        message: 'Search query is required'
      });
    }

    // Get all user IDs that are already assigned to a class
    const Siswa = require('../models/Siswa');
    const assignedUserIds = await Siswa.find({}, 'user_id').distinct('user_id');

    // Search for users with role 'siswa' that are not yet assigned
    const users = await User.find({
      role: 'siswa',
      _id: { $nin: assignedUserIds },
      $or: [
        { nama_lengkap: { $regex: q, $options: 'i' } },
        { email: { $regex: q, $options: 'i' } }
      ]
    })
    .select('nama_lengkap email createdAt')
    .sort({ nama_lengkap: 1 })
    .limit(20);

    res.status(200).json({
      success: true,
      count: users.length,
      data: users
    });
  } catch (error) {
    console.error('Error searching available siswa:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while searching available siswa',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};
