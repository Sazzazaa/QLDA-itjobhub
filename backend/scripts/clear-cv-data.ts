import { connect, connection } from 'mongoose';
import * as fs from 'fs';
import * as path from 'path';

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/itjobhub';

async function clearCVData() {
  try {
    console.log('🔌 Connecting to MongoDB...');
    await connect(MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    const db = connection.db;
    
    // Clear CV data from database
    console.log('🗑️  Clearing CV data from database...');
    const cvResult = await db.collection('cvdatas').deleteMany({});
    console.log(`✅ Deleted ${cvResult.deletedCount} CV records from database`);

    // Clear uploaded files
    const uploadsDir = path.join(__dirname, '..', 'uploads');
    if (fs.existsSync(uploadsDir)) {
      console.log('🗑️  Clearing uploaded files...');
      const files = fs.readdirSync(uploadsDir);
      let deletedCount = 0;
      for (const file of files) {
        if (file !== '.gitkeep') {
          const filePath = path.join(uploadsDir, file);
          fs.unlinkSync(filePath);
          deletedCount++;
        }
      }
      console.log(`✅ Deleted ${deletedCount} uploaded files`);
    }

    console.log('✅ CV data cleared successfully!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error clearing CV data:', error);
    process.exit(1);
  }
}

clearCVData();
