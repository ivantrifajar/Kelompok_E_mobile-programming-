const mongoose = require('mongoose');

const siswaSchema = new mongoose.Schema({
  user_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'User ID is required'],
    unique: true
  },
  nis: {
    type: String,
    required: [true, 'NIS is required'],
    unique: true,
    trim: true,
    minlength: [5, 'NIS must be at least 5 characters'],
    maxlength: [20, 'NIS cannot exceed 20 characters']
  },
  // Changed from kelas_id to kelas_ids to support multiple classes
  kelas_ids: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Kelas',
    required: true
  }],
  jenis_kelamin: {
    type: String,
    enum: {
      values: ['L', 'P'],
      message: 'Jenis kelamin must be either L (Laki-laki) or P (Perempuan)'
    },
    required: [true, 'Jenis kelamin is required']
  },
  tanggal_lahir: {
    type: Date,
    required: [true, 'Tanggal lahir is required']
  },
  alamat: {
    type: String,
    trim: true,
    maxlength: [200, 'Alamat cannot exceed 200 characters']
  },
  no_telepon: {
    type: String,
    trim: true,
    match: [/^[0-9+\-\s()]+$/, 'Please provide a valid phone number']
  },
  nama_orang_tua: {
    type: String,
    trim: true,
    maxlength: [100, 'Nama orang tua cannot exceed 100 characters']
  },
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

// Validation to ensure at least one class
siswaSchema.path('kelas_ids').validate(function(value) {
  return value && value.length > 0;
}, 'Siswa harus terdaftar minimal di satu kelas');

// Virtual for total classes count
siswaSchema.virtual('jumlah_kelas').get(function() {
  return this.kelas_ids ? this.kelas_ids.length : 0;
});

// Instance method to check if enrolled in specific class
siswaSchema.methods.isEnrolledInClass = function(kelasId) {
  return this.kelas_ids.some(id => id.toString() === kelasId.toString());
};

// Instance method to add to class
siswaSchema.methods.addToClass = function(kelasId) {
  if (!this.isEnrolledInClass(kelasId)) {
    this.kelas_ids.push(kelasId);
  }
  return this;
};

// Instance method to remove from class
siswaSchema.methods.removeFromClass = function(kelasId) {
  this.kelas_ids = this.kelas_ids.filter(
    id => id.toString() !== kelasId.toString()
  );
  return this;
};

// Index untuk performa query
siswaSchema.index({ user_id: 1 }, { unique: true });
siswaSchema.index({ nis: 1 }, { unique: true });
siswaSchema.index({ kelas_ids: 1 });
siswaSchema.index({ kelas_ids: 1, isActive: 1 });
siswaSchema.index({ createdAt: -1 });

module.exports = mongoose.model('Siswa', siswaSchema);
