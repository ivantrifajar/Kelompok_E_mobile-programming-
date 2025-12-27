const mongoose = require('mongoose');

const materiSchema = new mongoose.Schema({
  judul: {
    type: String,
    required: [true, 'Judul materi is required'],
    trim: true,
    minlength: [3, 'Judul materi must be at least 3 characters'],
    maxlength: [200, 'Judul materi cannot exceed 200 characters']
  },
  deskripsi: {
    type: String,
    trim: true,
    maxlength: [1000, 'Deskripsi cannot exceed 1000 characters']
  },
  konten: {
    type: String,
    required: [true, 'Konten materi is required'],
    trim: true
  },
  kelas_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Kelas',
    required: [true, 'Kelas ID is required'],
    index: true
  },
  guru_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'Guru ID is required'],
    index: true
  },
  tipe_materi: {
    type: String,
    enum: {
      values: ['teks', 'video', 'dokumen', 'link', 'gambar'],
      message: 'Tipe materi must be one of: teks, video, dokumen, link, gambar'
    },
    default: 'teks'
  },
  file_url: {
    type: String,
    trim: true
  },
  urutan: {
    type: Number,
    default: 0,
    min: [0, 'Urutan cannot be negative']
  },
  isActive: {
    type: Boolean,
    default: true,
    index: true
  },
  // Metadata for tracking
  views: {
    type: Number,
    default: 0,
    min: [0, 'Views cannot be negative']
  },
  // Tags for categorization
  tags: [{
    type: String,
    trim: true,
    lowercase: true
  }]
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Indexes for better query performance
materiSchema.index({ kelas_id: 1, isActive: 1 });
materiSchema.index({ guru_id: 1, isActive: 1 });
materiSchema.index({ kelas_id: 1, urutan: 1 });
materiSchema.index({ createdAt: -1 });
materiSchema.index({ judul: 'text', deskripsi: 'text', konten: 'text' }); // Text search

// Virtual for formatted creation date
materiSchema.virtual('tanggal_dibuat').get(function() {
  if (!this.createdAt) return null;
  
  const date = new Date(this.createdAt);
  const options = { 
    year: 'numeric', 
    month: 'long', 
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
    timeZone: 'Asia/Jakarta'
  };
  
  return date.toLocaleDateString('id-ID', options);
});

// Virtual for content preview (first 100 characters)
materiSchema.virtual('konten_preview').get(function() {
  if (!this.konten) return '';
  return this.konten.length > 100 ? this.konten.substring(0, 100) + '...' : this.konten;
});

// Static method to get materi by kelas with pagination
materiSchema.statics.getByKelas = function(kelasId, options = {}) {
  const {
    page = 1,
    limit = 10,
    sortBy = 'urutan',
    sortOrder = 'asc',
    search = '',
    tipeMateri = null
  } = options;

  const query = { 
    kelas_id: kelasId, 
    isActive: true 
  };

  // Add search filter
  if (search) {
    query.$text = { $search: search };
  }

  // Add type filter
  if (tipeMateri) {
    query.tipe_materi = tipeMateri;
  }

  const sort = {};
  sort[sortBy] = sortOrder === 'desc' ? -1 : 1;

  return this.find(query)
    .populate('guru_id', 'nama_lengkap email')
    .populate('kelas_id', 'nama tahun_ajaran')
    .sort(sort)
    .limit(limit * 1)
    .skip((page - 1) * limit)
    .exec();
};

// Static method to get materi statistics
materiSchema.statics.getStatistics = async function(kelasId) {
  const stats = await this.aggregate([
    { $match: { kelas_id: mongoose.Types.ObjectId(kelasId), isActive: true } },
    {
      $group: {
        _id: null,
        totalMateri: { $sum: 1 },
        totalViews: { $sum: '$views' },
        materiByType: {
          $push: {
            tipe: '$tipe_materi',
            count: 1
          }
        }
      }
    }
  ]);

  return stats[0] || {
    totalMateri: 0,
    totalViews: 0,
    materiByType: []
  };
};

// Instance method to increment views
materiSchema.methods.incrementViews = function() {
  this.views += 1;
  return this.save();
};

// Pre-save middleware to set urutan if not provided
materiSchema.pre('save', async function(next) {
  if (this.isNew && this.urutan === 0) {
    // Get the highest urutan for this kelas
    const lastMateri = await this.constructor.findOne({
      kelas_id: this.kelas_id,
      isActive: true
    }).sort({ urutan: -1 });

    this.urutan = lastMateri ? lastMateri.urutan + 1 : 1;
  }
  next();
});

// Ensure urutan uniqueness per kelas
materiSchema.index({ kelas_id: 1, urutan: 1 }, { unique: true });

module.exports = mongoose.model('Materi', materiSchema);
