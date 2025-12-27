# Multiple Class Enrollment - API Changes Required

## Overview
This document outlines the necessary backend API changes to support students being enrolled in multiple classes simultaneously.

## Database Schema Changes

### Option 1: Modify Existing Structure (Recommended)
Change the `kelas_id` field in the `siswas` collection to support an array of class IDs:

```javascript
// Before (Single Class)
{
  "_id": "ObjectId('68e6678f912acc54287c6371')",
  "isActive": true,
  "user_id": "ObjectId('68e6380b35f51c372cc6c0b2')",
  "nis": "123123123",
  "kelas_id": "ObjectId('68e6667c912acc54287c62c8')", // Single ID
  "jenis_kelamin": "L",
  "tanggal_lahir": "2004-10-11T17:00:00.000+00:00",
  "createdAt": "2025-10-08T13:30:55.532+00:00",
  "updatedAt": "2025-10-08T13:30:55.532+00:00",
  "__v": 0
}

// After (Multiple Classes)
{
  "_id": "ObjectId('68e6678f912acc54287c6371')",
  "isActive": true,
  "user_id": "ObjectId('68e6380b35f51c372cc6c0b2')",
  "nis": "123123123",
  "kelas_ids": [  // Array of IDs
    "ObjectId('68e6667c912acc54287c62c8')",
    "ObjectId('68e6667c912acc54287c62c9')",
    "ObjectId('68e6667c912acc54287c62ca')"
  ],
  "jenis_kelamin": "L",
  "tanggal_lahir": "2004-10-11T17:00:00.000+00:00",
  "createdAt": "2025-10-08T13:30:55.532+00:00",
  "updatedAt": "2025-10-08T13:30:55.532+00:00",
  "__v": 0
}
```

### Option 2: Junction Table Approach (Alternative)
Create a separate `siswa_kelas` collection for many-to-many relationships:

```javascript
// siswas collection (unchanged)
{
  "_id": "ObjectId('68e6678f912acc54287c6371')",
  "isActive": true,
  "user_id": "ObjectId('68e6380b35f51c372cc6c0b2')",
  "nis": "123123123",
  "jenis_kelamin": "L",
  "tanggal_lahir": "2004-10-11T17:00:00.000+00:00",
  // ... other fields
}

// siswa_kelas collection (new)
{
  "_id": "ObjectId('...')",
  "siswa_id": "ObjectId('68e6678f912acc54287c6371')",
  "kelas_id": "ObjectId('68e6667c912acc54287c62c8')",
  "enrolled_at": "2025-10-08T13:30:55.532+00:00",
  "isActive": true
}
```

## API Endpoint Changes

### 1. Create Siswa Endpoint
**Endpoint:** `POST /api/siswa`

**Request Body Changes:**
```javascript
// Before
{
  "user_id": "68e6380b35f51c372cc6c0b2",
  "nis": "123123123",
  "kelas_id": "68e6667c912acc54287c62c8", // Single ID
  "jenis_kelamin": "L",
  "tanggal_lahir": "2004-10-11T17:00:00.000Z",
  "alamat": "Jl. Contoh No. 123",
  "no_telepon": "081234567890",
  "nama_orang_tua": "Budi Santoso"
}

// After
{
  "user_id": "68e6380b35f51c372cc6c0b2",
  "nis": "123123123",
  "kelas_ids": [  // Array of IDs
    "68e6667c912acc54287c62c8",
    "68e6667c912acc54287c62c9",
    "68e6667c912acc54287c62ca"
  ],
  "jenis_kelamin": "L",
  "tanggal_lahir": "2004-10-11T17:00:00.000Z",
  "alamat": "Jl. Contoh No. 123",
  "no_telepon": "081234567890",
  "nama_orang_tua": "Budi Santoso"
}
```

### 2. Backend Implementation (Node.js/Express Example)

```javascript
// siswa.controller.js
const createSiswa = async (req, res) => {
  try {
    const {
      user_id,
      nis,
      kelas_ids, // Now expecting an array
      jenis_kelamin,
      tanggal_lahir,
      alamat,
      no_telepon,
      nama_orang_tua
    } = req.body;

    // Validation
    if (!Array.isArray(kelas_ids) || kelas_ids.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Minimal satu kelas harus dipilih'
      });
    }

    // Validate all class IDs exist
    const validKelas = await Kelas.find({ 
      _id: { $in: kelas_ids },
      isActive: true 
    });
    
    if (validKelas.length !== kelas_ids.length) {
      return res.status(400).json({
        success: false,
        message: 'Satu atau lebih kelas tidak valid'
      });
    }

    // Create siswa with multiple classes
    const siswa = new Siswa({
      user_id,
      nis,
      kelas_ids, // Store as array
      jenis_kelamin,
      tanggal_lahir,
      alamat,
      no_telepon,
      nama_orang_tua,
      isActive: true
    });

    await siswa.save();

    // Populate class information
    await siswa.populate('kelas_ids', 'nama tahun_ajaran');

    res.status(201).json({
      success: true,
      message: 'Siswa berhasil ditambahkan ke multiple kelas',
      data: siswa
    });

  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};
```

### 3. Update Siswa Schema (Mongoose Example)

```javascript
// models/Siswa.js
const siswaSchema = new mongoose.Schema({
  user_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  nis: {
    type: String,
    required: true,
    unique: true
  },
  kelas_ids: [{  // Changed from kelas_id to kelas_ids array
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Kelas',
    required: true
  }],
  jenis_kelamin: {
    type: String,
    enum: ['L', 'P'],
    required: true
  },
  tanggal_lahir: {
    type: Date,
    required: true
  },
  alamat: String,
  no_telepon: String,
  nama_orang_tua: String,
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

// Add compound index for better query performance
siswaSchema.index({ user_id: 1, kelas_ids: 1 });
siswaSchema.index({ nis: 1 });
```

### 4. Update Query Methods

```javascript
// Get siswa by kelas
const getSiswaByKelas = async (req, res) => {
  try {
    const { kelasId } = req.params;
    
    // Find all siswa that have this kelas in their kelas_ids array
    const siswa = await Siswa.find({
      kelas_ids: kelasId,
      isActive: true
    }).populate('user_id', 'nama_lengkap email')
      .populate('kelas_ids', 'nama tahun_ajaran');

    res.json({
      success: true,
      data: siswa,
      count: siswa.length
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// Get all kelas for a siswa
const getKelasBySiswa = async (req, res) => {
  try {
    const { siswaId } = req.params;
    
    const siswa = await Siswa.findById(siswaId)
      .populate('kelas_ids', 'nama tahun_ajaran guru_id');

    if (!siswa) {
      return res.status(404).json({
        success: false,
        message: 'Siswa tidak ditemukan'
      });
    }

    res.json({
      success: true,
      data: siswa.kelas_ids
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};
```

## Migration Script

If you choose Option 1, here's a migration script to update existing data:

```javascript
// migration/update_siswa_kelas.js
const mongoose = require('mongoose');

const migrateSiswaKelas = async () => {
  try {
    // Find all siswa with old kelas_id field
    const siswas = await mongoose.connection.db
      .collection('siswas')
      .find({ kelas_id: { $exists: true } })
      .toArray();

    for (const siswa of siswas) {
      // Convert single kelas_id to array kelas_ids
      await mongoose.connection.db
        .collection('siswas')
        .updateOne(
          { _id: siswa._id },
          {
            $set: { kelas_ids: [siswa.kelas_id] },
            $unset: { kelas_id: 1 }
          }
        );
    }

    console.log(`Migrated ${siswas.length} siswa records`);
  } catch (error) {
    console.error('Migration failed:', error);
  }
};

module.exports = migrateSiswaKelas;
```

## Testing

### Test Cases to Implement:

1. **Create siswa with multiple classes**
   - Valid multiple class IDs
   - Invalid class ID in array
   - Empty class array
   - Duplicate class IDs

2. **Query siswa by class**
   - Should return all siswa enrolled in specific class
   - Should handle class with no siswa

3. **Query classes by siswa**
   - Should return all classes for specific siswa

4. **Update siswa classes**
   - Add new class to existing siswa
   - Remove class from siswa
   - Replace all classes

## Frontend Integration

The Flutter app has been updated to:
- ✅ Support multiple class selection with checkboxes
- ✅ Send `kelas_ids` array in API requests
- ✅ Display selected classes as removable chips
- ✅ Validate that at least one class is selected
- ✅ Handle backward compatibility when coming from specific class page

## Next Steps

1. **Implement backend API changes** according to this specification
2. **Run migration script** to update existing data
3. **Update all related endpoints** that query by class
4. **Test thoroughly** with the updated Flutter app
5. **Update API documentation** to reflect new structure

## Notes

- The Flutter app is ready and will work once the backend API is updated
- Consider adding indexes on `kelas_ids` field for better query performance
- Ensure proper validation to prevent orphaned references
- Consider implementing cascade operations when classes are deleted
