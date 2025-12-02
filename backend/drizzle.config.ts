import { defineConfig } from 'drizzle-kit';
import * as dotenv from 'dotenv';

dotenv.config();

export default defineConfig({
  schema: './src/database/schema.ts',
  out: './src/database/migrations',
  dialect: 'postgresql',
  dbCredentials: {
    url: process.env.DATABASE_SSL === 'true' 
      ? `${process.env.DATABASE_URL}?sslmode=no-verify`
      : process.env.DATABASE_URL || '',
  },
  verbose: true,
  strict: true,
});
