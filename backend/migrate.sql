-- Create users table
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
);

-- Create favorites table
CREATE TABLE IF NOT EXISTS "favorites" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
  "user_id" uuid NOT NULL,
  "report_id" uuid NOT NULL,
  "created_at" timestamp DEFAULT now() NOT NULL,
  CONSTRAINT "unique_favorite" UNIQUE("user_id","report_id")
);

-- Add indexes for users
CREATE INDEX IF NOT EXISTS "idx_user_email" ON "users" USING btree ("email");
CREATE INDEX IF NOT EXISTS "idx_oauth" ON "users" USING btree ("oauth_provider","oauth_id");

-- Add indexes for favorites
CREATE INDEX IF NOT EXISTS "idx_favorite_user_id" ON "favorites" USING btree ("user_id");
CREATE INDEX IF NOT EXISTS "idx_favorite_report_id" ON "favorites" USING btree ("report_id");

-- Add user_id column to parking_reports if not exists
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='parking_reports' AND column_name='user_id') THEN
    ALTER TABLE "parking_reports" ADD COLUMN "user_id" uuid;
  END IF;
END $$;

-- Create index on user_id for parking_reports
CREATE INDEX IF NOT EXISTS "idx_user_id" ON "parking_reports" USING btree ("user_id");

-- Create index on user_id for report_ratings
CREATE INDEX IF NOT EXISTS "idx_rating_user_id" ON "report_ratings" USING btree ("user_id");
