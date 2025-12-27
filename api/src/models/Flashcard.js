const mongoose = require('mongoose');

// Schema untuk individual flashcard item
const flashcardItemSchema = new mongoose.Schema({
  pertanyaan: {
    type: String,
    required: [true, 'Pertanyaan is required'],
    trim: true,
    minlength: [3, 'Pertanyaan must be at least 3 characters'],
    maxlength: [1000, 'Pertanyaan cannot exceed 1000 characters']
  },
  jawaban: {
    type: String,
    required: [true, 'Jawaban is required'],
    trim: true,
    minlength: [1, 'Jawaban must be at least 1 character'],
    maxlength: [1000, 'Jawaban cannot exceed 1000 characters']
  }
}, { _id: true });

// Schema utama untuk flashcard set
const flashcardSchema = new mongoose.Schema({
  judul: {
    type: String,
    required: [true, 'Judul is required'],
    trim: true,
    minlength: [3, 'Judul must be at least 3 characters'],
    maxlength: [200, 'Judul cannot exceed 200 characters']
  },
  topik: {
    type: String,
    required: [true, 'Topik is required'],
    trim: true,
    minlength: [3, 'Topik must be at least 3 characters'],
    maxlength: [200, 'Topik cannot exceed 200 characters']
  },
  deskripsi: {
    type: String,
    required: [true, 'Deskripsi is required'],
    trim: true,
    minlength: [10, 'Deskripsi must be at least 10 characters'],
    maxlength: [1000, 'Deskripsi cannot exceed 1000 characters']
  },
  kelas_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Kelas',
    required: [true, 'Kelas ID is required']
  },
  guru_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'Guru ID is required']
  },
  kartu: {
    type: [flashcardItemSchema],
    validate: {
      validator: function(v) {
        return v && v.length > 0;
      },
      message: 'At least one flashcard item is required'
    }
  },
  jumlahKartu: {
    type: Number,
    default: function() {
      return this.kartu ? this.kartu.length : 0;
    }
  },
  isActive: {
    type: Boolean,
    default: true
  },
  // Statistics
  totalViews: {
    type: Number,
    default: 0
  },
  totalStudents: {
    type: Number,
    default: 0
  }
}, {
  timestamps: true
});

// Pre-save middleware to update jumlahKartu
flashcardSchema.pre('save', function(next) {
  if (this.kartu) {
    this.jumlahKartu = this.kartu.length;
  }
  next();
});

// Index untuk performa query
flashcardSchema.index({ judul: 1 });
flashcardSchema.index({ topik: 1 });
flashcardSchema.index({ kelas_id: 1 });
flashcardSchema.index({ guru_id: 1 });
flashcardSchema.index({ isActive: 1 });
flashcardSchema.index({ createdAt: -1 });

// Compound indexes
flashcardSchema.index({ kelas_id: 1, isActive: 1 });
flashcardSchema.index({ guru_id: 1, isActive: 1 });

module.exports = mongoose.model('Flashcard', flashcardSchema);
