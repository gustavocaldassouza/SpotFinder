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
  unique,
} from 'drizzle-orm/pg-core';

export const users = pgTable(
  'users',
  {
    id: uuid('id').primaryKey().defaultRandom(),
    email: varchar('email', { length: 255 }).notNull().unique(),
    passwordHash: varchar('password_hash', { length: 255 }),
    firstName: varchar('first_name', { length: 100 }),
    lastName: varchar('last_name', { length: 100 }),
    avatarUrl: text('avatar_url'),
    oauthProvider: varchar('oauth_provider', { length: 50 }),
    oauthId: varchar('oauth_id', { length: 255 }),
    refreshToken: text('refresh_token'),
    isActive: boolean('is_active').default(true).notNull(),
    createdAt: timestamp('created_at').defaultNow().notNull(),
    updatedAt: timestamp('updated_at').defaultNow().notNull(),
  },
  (table) => ({
    emailIdx: index('idx_user_email').on(table.email),
    oauthIdx: index('idx_oauth').on(table.oauthProvider, table.oauthId),
  }),
);

export const parkingReports = pgTable(
  'parking_reports',
  {
    id: uuid('id').primaryKey().defaultRandom(),
    latitude: real('latitude').notNull(),
    longitude: real('longitude').notNull(),
    status: varchar('status', { length: 50 }).notNull(),
    description: text('description'),
    userId: uuid('user_id').references(() => users.id, {
      onDelete: 'set null',
    }),
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
    userIdIdx: index('idx_user_id').on(table.userId),
  }),
);

export const reportRatings = pgTable(
  'report_ratings',
  {
    id: uuid('id').primaryKey().defaultRandom(),
    reportId: uuid('report_id')
      .notNull()
      .references(() => parkingReports.id, { onDelete: 'cascade' }),
    userId: uuid('user_id')
      .notNull()
      .references(() => users.id, { onDelete: 'cascade' }),
    rating: smallint('rating').notNull(),
    createdAt: timestamp('created_at').defaultNow().notNull(),
  },
  (table) => ({
    reportIdIdx: index('idx_report_rating').on(table.reportId),
    userIdIdx: index('idx_rating_user_id').on(table.userId),
    uniqueUserRating: unique('unique_user_rating').on(
      table.reportId,
      table.userId,
    ),
  }),
);

export const favorites = pgTable(
  'favorites',
  {
    id: uuid('id').primaryKey().defaultRandom(),
    userId: uuid('user_id')
      .notNull()
      .references(() => users.id, { onDelete: 'cascade' }),
    reportId: uuid('report_id')
      .notNull()
      .references(() => parkingReports.id, { onDelete: 'cascade' }),
    createdAt: timestamp('created_at').defaultNow().notNull(),
  },
  (table) => ({
    userIdIdx: index('idx_favorite_user_id').on(table.userId),
    reportIdIdx: index('idx_favorite_report_id').on(table.reportId),
    uniqueFavorite: unique('unique_favorite').on(table.userId, table.reportId),
  }),
);

export type User = typeof users.$inferSelect;
export type NewUser = typeof users.$inferInsert;
export type ParkingReport = typeof parkingReports.$inferSelect;
export type NewParkingReport = typeof parkingReports.$inferInsert;
export type ReportRating = typeof reportRatings.$inferSelect;
export type NewReportRating = typeof reportRatings.$inferInsert;
export type Favorite = typeof favorites.$inferSelect;
export type NewFavorite = typeof favorites.$inferInsert;
