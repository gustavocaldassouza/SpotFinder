import { drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';
import * as schema from './schema';

let client: ReturnType<typeof postgres> | null = null;
let db: ReturnType<typeof drizzle> | null = null;

export const getDatabase = (connectionString: string) => {
  if (!db) {
    client = postgres(connectionString, {
      max: 10,
      idle_timeout: 20,
      connect_timeout: 10,
      ssl: process.env.DATABASE_SSL === 'true' ? 'require' : false,
    });
    db = drizzle(client, { schema });
  }
  return db;
};

export const closeDatabase = async () => {
  if (client) {
    await client.end();
    client = null;
    db = null;
  }
};

export type Database = ReturnType<typeof getDatabase>;
