const postgres = require('postgres');
const fs = require('fs');

const sql = postgres(process.env.DATABASE_URL, {
  ssl: 'require',
});

const migrationSQL = fs.readFileSync('./init-db.sql', 'utf8');

sql.unsafe(migrationSQL)
  .then(() => {
    console.log('✅ Migration completed successfully');
    process.exit(0);
  })
  .catch((err) => {
    console.error('❌ Migration failed:', err);
    process.exit(1);
  });
