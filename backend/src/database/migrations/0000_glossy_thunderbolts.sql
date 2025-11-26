CREATE TABLE "parking_reports" (
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
--> statement-breakpoint
CREATE TABLE "report_ratings" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"report_id" uuid NOT NULL,
	"user_id" uuid,
	"rating" smallint NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "users" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"email" varchar(255) NOT NULL,
	"password_hash" varchar(255),
	"first_name" varchar(100),
	"last_name" varchar(100),
	"avatar_url" text,
	"oauth_provider" varchar(50),
	"oauth_id" varchar(255),
	"refresh_token" text,
	"is_active" boolean DEFAULT true NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "users_email_unique" UNIQUE("email")
);
--> statement-breakpoint
ALTER TABLE "parking_reports" ADD CONSTRAINT "parking_reports_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "report_ratings" ADD CONSTRAINT "report_ratings_report_id_parking_reports_id_fk" FOREIGN KEY ("report_id") REFERENCES "public"."parking_reports"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "report_ratings" ADD CONSTRAINT "report_ratings_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "idx_created_at" ON "parking_reports" USING btree ("created_at");--> statement-breakpoint
CREATE INDEX "idx_expires_at" ON "parking_reports" USING btree ("expires_at");--> statement-breakpoint
CREATE INDEX "idx_status" ON "parking_reports" USING btree ("status");--> statement-breakpoint
CREATE INDEX "idx_is_active" ON "parking_reports" USING btree ("is_active");--> statement-breakpoint
CREATE INDEX "idx_user_id" ON "parking_reports" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "idx_report_rating" ON "report_ratings" USING btree ("report_id");--> statement-breakpoint
CREATE INDEX "idx_rating_user_id" ON "report_ratings" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "idx_user_email" ON "users" USING btree ("email");--> statement-breakpoint
CREATE INDEX "idx_oauth" ON "users" USING btree ("oauth_provider","oauth_id");