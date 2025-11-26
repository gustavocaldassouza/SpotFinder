ALTER TABLE "report_ratings" DROP CONSTRAINT "report_ratings_user_id_users_id_fk";
--> statement-breakpoint
ALTER TABLE "report_ratings" ALTER COLUMN "user_id" SET NOT NULL;--> statement-breakpoint
ALTER TABLE "report_ratings" ADD CONSTRAINT "report_ratings_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "report_ratings" ADD CONSTRAINT "unique_user_rating" UNIQUE("report_id","user_id");