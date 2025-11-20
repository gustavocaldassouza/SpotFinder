CREATE TABLE IF NOT EXISTS "parking_reports" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
  "latitude" real NOT NULL,
  "longitude" real NOT NULL,
  "status" varchar(50) NOT NULL,
  "description" text,
  "user_id" uuid,
  "created_at" timestamp DEFAULT now() NOT NULL,
  "updated_at" timestamp DEFAULT now(),
  "expires_at" timestamp NOT NULL,
  "total_ratings" integer DEFAULT 0 NOT NULL,
  "sum_ratings" integer DEFAULT 0 NOT NULL,
  "is_active" boolean DEFAULT true NOT NULL
);

CREATE TABLE IF NOT EXISTS "report_ratings" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
  "report_id" uuid NOT NULL,
  "user_id" uuid,
  "rating" smallint NOT NULL,
  "created_at" timestamp DEFAULT now() NOT NULL
);

ALTER TABLE "report_ratings" DROP CONSTRAINT IF EXISTS "report_ratings_report_id_parking_reports_id_fk";
ALTER TABLE "report_ratings" ADD CONSTRAINT "report_ratings_report_id_parking_reports_id_fk" FOREIGN KEY ("report_id") REFERENCES "public"."parking_reports"("id") ON DELETE cascade ON UPDATE no action;

DROP INDEX IF EXISTS "idx_created_at";
DROP INDEX IF EXISTS "idx_expires_at";
DROP INDEX IF EXISTS "idx_status";
DROP INDEX IF EXISTS "idx_is_active";
DROP INDEX IF EXISTS "idx_report_rating";

CREATE INDEX "idx_created_at" ON "parking_reports" USING btree ("created_at");
CREATE INDEX "idx_expires_at" ON "parking_reports" USING btree ("expires_at");
CREATE INDEX "idx_status" ON "parking_reports" USING btree ("status");
CREATE INDEX "idx_is_active" ON "parking_reports" USING btree ("is_active");
CREATE INDEX "idx_report_rating" ON "report_ratings" USING btree ("report_id");
