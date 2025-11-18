import {
  pgTable,
  uuid,
  real,
  varchar,
  text,
  timestamp,
  integer,
  boolean,
  smallint,
  index,
} from 'drizzle-orm/pg-core';
import { sql } from 'drizzle-orm';

export const parkingReports = pgTable(
  'parking_reports',
  {
    id: uuid('id').primaryKey().defaultRandom(),
    latitude: real('latitude').notNull(),
    longitude: real('longitude').notNull(),
    status: varchar('status', { length: 50 }).notNull(),
    description: text('description'),
    userId: uuid('user_id'),
    createdAt: timestamp('created_at').defaultNow().notNull(),
    updatedAt: timestamp('updated_at').defaultNow(),
    expiresAt: timestamp('expires_at').notNull(),
    totalRatings: integer('total_ratings').default(0).notNull(),
    sumRatings: integer('sum_ratings').default(0).notNull(),
    isActive: boolean('is_active').default(true).notNull(),
  },
  (table) => ({
    createdAtIdx: index('idx_created_at').on(table.createdAt),
    expiresAtIdx: index('idx_expires_at').on(table.expiresAt),
    statusIdx: index('idx_status').on(table.status),
    isActiveIdx: index('idx_is_active').on(table.isActive),
  }),
);

export const reportRatings = pgTable(
  'report_ratings',
  {
    id: uuid('id').primaryKey().defaultRandom(),
    reportId: uuid('report_id')
      .notNull()
      .references(() => parkingReports.id, { onDelete: 'cascade' }),
    userId: uuid('user_id'),
    rating: smallint('rating').notNull(),
    createdAt: timestamp('created_at').defaultNow().notNull(),
  },
  (table) => ({
    reportIdIdx: index('idx_report_rating').on(table.reportId),
  }),
);

export type ParkingReport = typeof parkingReports.$inferSelect;
export type NewParkingReport = typeof parkingReports.$inferInsert;
export type ReportRating = typeof reportRatings.$inferSelect;
export type NewReportRating = typeof reportRatings.$inferInsert;
