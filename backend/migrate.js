const postgres = require('postgres');

const sql = postgres(process.env.DATABASE_URL, {
  ssl: { rejectUnauthorized: false }
});

async function migrate() {
  try {
    console.log('Starting migration...');
    
    // Create users table
    await sql`
      CREATE TABLE IF NOT EXISTS "users" (
        "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
        "email" varchar(255) NOT NULL UNIQUE,
        "password_hash" varchar(255),
        "first_name" varchar(100),
        "last_name" varchar(100),
        "avatar_url" text,
        "oauth_provider" varchar(50),
        "oauth_id" varchar(255),
        "refresh_token" text,
        "is_active" boolean DEFAULT true NOT NULL,
        "created_at" timestamp DEFAULT now() NOT NULL,
        "updated_at" timestamp DEFAULT now() NOT NULL
      )
    `;
    console.log('✓ Users table created');

    // Create favorites table
    await sql`
      CREATE TABLE IF NOT EXISTS "favorites" (
        "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
        "user_id" uuid NOT NULL,
        "report_id" uuid NOT NULL,
        "created_at" timestamp DEFAULT now() NOT NULL,
        CONSTRAINT "unique_favorite" UNIQUE("user_id","report_id")
      )
    `;
    console.log('✓ Favorites table created');

    // Create indexes
    await sql`CREATE INDEX IF NOT EXISTS "idx_user_email" ON "users" USING btree ("email")`;
    await sql`CREATE INDEX IF NOT EXISTS "idx_oauth" ON "users" USING btree ("oauth_provider","oauth_id")`;
    await sql`CREATE INDEX IF NOT EXISTS "idx_favorite_user_id" ON "favorites" USING btree ("user_id")`;
    await sql`CREATE INDEX IF NOT EXISTS "idx_favorite_report_id" ON "favorites" USING btree ("report_id")`;
    await sql`CREATE INDEX IF NOT EXISTS "idx_user_id" ON "parking_reports" USING btree ("user_id")`;
    await sql`CREATE INDEX IF NOT EXISTS "idx_rating_user_id" ON "report_ratings" USING btree ("user_id")`;
    console.log('✓ Indexes created');

    console.log('Migration completed successfully!');
  } catch (error) {
    console.error('Migration failed:', error);
  } finally {
    await sql.end();
  }
}

migrate();
