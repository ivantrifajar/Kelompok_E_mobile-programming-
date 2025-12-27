const mongoose = require('mongoose');

const kelasSchema = new mongoose.Schema({
  nama: {
    type: String,
    required: [true, 'Nama kelas is required'],
    trim: true,
    minlength: [3, 'Nama kelas must be at least 3 characters'],
    maxlength: [100, 'Nama kelas cannot exceed 100 characters']
  },
  guru_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'Guru ID is required']
  },
  tahun_ajaran: {
    type: String,
    trim: true
  },
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

// Index untuk performa query
kelasSchema.index({ nama: 1 });
kelasSchema.index({ guru_id: 1 });
kelasSchema.index({ tahun_ajaran: 1 });

module.exports = mongoose.model('Kelas', kelasSchema);
