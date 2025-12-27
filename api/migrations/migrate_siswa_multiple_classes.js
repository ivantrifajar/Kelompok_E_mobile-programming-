const mongoose = require('mongoose');
require('dotenv').config();

// Connect to MongoDB
const connectDB = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/project-pendidikan', {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log('MongoDB Connected for migration...');
  } catch (error) {
    console.error('Database connection error:', error);
    process.exit(1);
  }
};

// Migration function to convert kelas_id to kelas_ids
const migrateSiswaKelas = async () => {
  try {
    console.log('Starting migration: Converting kelas_id to kelas_ids...');
    
    // Get the siswas collection
    const db = mongoose.connection.db;
    const siswaCollection = db.collection('siswas');
    
    // Find all siswa documents with old kelas_id field
    const siswasWithOldFormat = await siswaCollection.find({ 
      kelas_id: { $exists: true },
      kelas_ids: { $exists: false }
    }).toArray();
    
    console.log(`Found ${siswasWithOldFormat.length} siswa records to migrate`);
    
    if (siswasWithOldFormat.length === 0) {
      console.log('No records need migration. All siswa already have kelas_ids format.');
      return;
    }
    
    let migratedCount = 0;
    let errorCount = 0;
    
    // Process each siswa record
    for (const siswa of siswasWithOldFormat) {
      try {
        // Convert single kelas_id to array kelas_ids
        const updateResult = await siswaCollection.updateOne(
          { _id: siswa._id },
          {
            $set: { 
              kelas_ids: [siswa.kelas_id] // Convert to array
            },
            $unset: { 
              kelas_id: 1 // Remove old field
            }
          }
        );
        
        if (updateResult.modifiedCount === 1) {
          migratedCount++;
          console.log(`✓ Migrated siswa ${siswa._id} (NIS: ${siswa.nis})`);
        } else {
          console.log(`⚠ Warning: Could not update siswa ${siswa._id}`);
          errorCount++;
        }
      } catch (error) {
        console.error(`✗ Error migrating siswa ${siswa._id}:`, error.message);
        errorCount++;
      }
    }
    
    console.log('\n=== Migration Summary ===');
    console.log(`Total records found: ${siswasWithOldFormat.length}`);
    console.log(`Successfully migrated: ${migratedCount}`);
    console.log(`Errors: ${errorCount}`);
    
    // Verify migration
    console.log('\n=== Verification ===');
    const remainingOldFormat = await siswaCollection.countDocuments({ 
      kelas_id: { $exists: true } 
    });
    const newFormatCount = await siswaCollection.countDocuments({ 
      kelas_ids: { $exists: true } 
    });
    
    console.log(`Records still with old format (kelas_id): ${remainingOldFormat}`);
    console.log(`Records with new format (kelas_ids): ${newFormatCount}`);
    
    if (remainingOldFormat === 0) {
      console.log('✓ Migration completed successfully! All records now use kelas_ids format.');
    } else {
      console.log('⚠ Warning: Some records still have old format. Please check manually.');
    }
    
  } catch (error) {
    console.error('Migration failed:', error);
    throw error;
  }
};

// Rollback function (in case we need to revert)
const rollbackMigration = async () => {
  try {
    console.log('Starting rollback: Converting kelas_ids back to kelas_id...');
    
    const db = mongoose.connection.db;
    const siswaCollection = db.collection('siswas');
    
    // Find all siswa documents with new kelas_ids field that have only one class
    const siswasToRollback = await siswaCollection.find({ 
      kelas_ids: { $exists: true, $size: 1 },
      kelas_id: { $exists: false }
    }).toArray();
    
    console.log(`Found ${siswasToRollback.length} siswa records to rollback`);
    
    let rolledBackCount = 0;
    
    for (const siswa of siswasToRollback) {
      try {
        // Convert array back to single kelas_id (only if array has exactly 1 element)
        if (siswa.kelas_ids && siswa.kelas_ids.length === 1) {
          await siswaCollection.updateOne(
            { _id: siswa._id },
            {
              $set: { 
                kelas_id: siswa.kelas_ids[0] // Take first (and only) element
              },
              $unset: { 
                kelas_ids: 1 // Remove new field
              }
            }
          );
          rolledBackCount++;
          console.log(`✓ Rolled back siswa ${siswa._id}`);
        } else {
          console.log(`⚠ Skipped siswa ${siswa._id} - has multiple classes, cannot rollback to single kelas_id`);
        }
      } catch (error) {
        console.error(`✗ Error rolling back siswa ${siswa._id}:`, error.message);
      }
    }
    
    console.log(`\nRollback completed. ${rolledBackCount} records rolled back.`);
    
  } catch (error) {
    console.error('Rollback failed:', error);
    throw error;
  }
};

// Main execution
const main = async () => {
  try {
    await connectDB();
    
    const args = process.argv.slice(2);
    const command = args[0];
    
    if (command === 'rollback') {
      await rollbackMigration();
    } else {
      await migrateSiswaKelas();
    }
    
  } catch (error) {
    console.error('Migration script failed:', error);
    process.exit(1);
  } finally {
    await mongoose.connection.close();
    console.log('Database connection closed.');
  }
};

// Handle script termination
process.on('SIGINT', async () => {
  console.log('\nReceived SIGINT. Closing database connection...');
  await mongoose.connection.close();
  process.exit(0);
});

// Run the migration
if (require.main === module) {
  main();
}

module.exports = {
  migrateSiswaKelas,
  rollbackMigration
};
