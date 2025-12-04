import { drizzle } from 'drizzle-orm/postgres-js';
import { migrate } from 'drizzle-orm/postgres-js/migrator';
import postgres from 'postgres';
import * as dotenv from 'dotenv';
import * as path from 'path';

dotenv.config();

const runMigrations = async () => {
  const connectionString = process.env.DATABASE_URL;
  if (!connectionString) {
    throw new Error('DATABASE_URL is not defined');
  }

  console.log('Connecting to database for migrations...');
  const sql = postgres(connectionString, {
    max: 1,
    ssl: process.env.DATABASE_SSL === 'true' ? { rejectUnauthorized: false } : false,
  });

  const db = drizzle(sql);

  console.log('Running migrations...');

  // When compiled, this file is in dist/database/migrate.js
  // Migrations are copied to dist/database/migrations
  const migrationsFolder = path.join(__dirname, 'migrations');
  console.log(`Reading migrations from ${migrationsFolder}`);

  try {
    await migrate(db, { migrationsFolder });
    console.log('Migrations completed successfully');
  } catch (error) {
    console.error('Migration failed:', error);
    process.exit(1);
  } finally {
    await sql.end();
  }
};

runMigrations();
