import { Injectable, Inject } from '@nestjs/common';
import { eq, and, gte, lte, sql, inArray } from 'drizzle-orm';
import type { Database } from '../database/client';
import { DATABASE_TOKEN } from '../database/database.module';
import {
  parkingReports,
  reportRatings,
  favorites,
  NewParkingReport,
  NewReportRating,
  NewFavorite,
} from '../database/schema';
import {
  ParkingReportEntity,
  ParkingReportWithDistance,
} from './entities/parking-report.entity';

@Injectable()
export class ParkingRepository {
  constructor(@Inject(DATABASE_TOKEN) private readonly db: Database) {}

  async create(data: NewParkingReport) {
    const [report] = await this.db
      .insert(parkingReports)
      .values(data)
      .returning();
    return report;
  }

  async findById(id: string): Promise<ParkingReportEntity | null> {
    const [report] = await this.db
      .select()
      .from(parkingReports)
      .where(eq(parkingReports.id, id))
      .limit(1);

    if (!report) return null;

    return this.mapToEntity(report);
  }

  async findNearby(
    latitude: number,
    longitude: number,
    radiusMeters: number,
  ): Promise<ParkingReportWithDistance[]> {
    const now = new Date();

    const distance = sql<number>`
      (6371000 * acos(
        cos(radians(${latitude})) * 
        cos(radians(${parkingReports.latitude})) * 
        cos(radians(${parkingReports.longitude}) - radians(${longitude})) + 
        sin(radians(${latitude})) * 
        sin(radians(${parkingReports.latitude}))
      ))
    `;

    const reports = await this.db
      .select({
        id: parkingReports.id,
        latitude: parkingReports.latitude,
        longitude: parkingReports.longitude,
        status: parkingReports.status,
        description: parkingReports.description,
        createdAt: parkingReports.createdAt,
        expiresAt: parkingReports.expiresAt,
        totalRatings: parkingReports.totalRatings,
        sumRatings: parkingReports.sumRatings,
        isActive: parkingReports.isActive,
        distance,
      })
      .from(parkingReports)
      .where(
        and(
          eq(parkingReports.isActive, true),
          gte(parkingReports.expiresAt, now),
          sql`${distance} <= ${radiusMeters}`,
        ),
      )
      .orderBy(distance);

    return reports.map((report) => ({
      ...this.mapToEntity(report),
      distance: report.distance,
    }));
  }

  async update(id: string, data: Partial<NewParkingReport>) {
    const [updated] = await this.db
      .update(parkingReports)
      .set({ ...data, updatedAt: new Date() })
      .where(eq(parkingReports.id, id))
      .returning();
    return updated;
  }

  async addRating(data: NewReportRating) {
    // Check if user already rated this report
    const [existingRating] = await this.db
      .select()
      .from(reportRatings)
      .where(
        and(
          eq(reportRatings.reportId, data.reportId),
          eq(reportRatings.userId, data.userId!),
        ),
      )
      .limit(1);

    if (existingRating) {
      // User already rated this report
      return null;
    }

    const [rating] = await this.db
      .insert(reportRatings)
      .values(data)
      .returning();

    await this.db
      .update(parkingReports)
      .set({
        totalRatings: sql`${parkingReports.totalRatings} + 1`,
        sumRatings: sql`${parkingReports.sumRatings} + ${data.rating}`,
        updatedAt: new Date(),
      })
      .where(eq(parkingReports.id, data.reportId));

    return rating;
  }

  async expireOldReports() {
    const now = new Date();
    await this.db
      .update(parkingReports)
      .set({ isActive: false, updatedAt: now })
      .where(
        and(
          eq(parkingReports.isActive, true),
          lte(parkingReports.expiresAt, now),
        ),
      );
  }

  private mapToEntity(report: any): ParkingReportEntity {
    const accuracyRating =
      report.totalRatings > 0 ? report.sumRatings / report.totalRatings : 0;

    return {
      id: report.id,
      latitude: report.latitude,
      longitude: report.longitude,
      status: report.status,
      description: report.description,
      createdAt: report.createdAt,
      expiresAt: report.expiresAt,
      accuracyRating: Math.round(accuracyRating * 10) / 10,
      totalRatings: report.totalRatings,
      isActive: report.isActive,
    };
  }

  // Favorites methods
  async addFavorite(data: NewFavorite) {
    // Check if already favorited
    const [existing] = await this.db
      .select()
      .from(favorites)
      .where(
        and(
          eq(favorites.userId, data.userId),
          eq(favorites.reportId, data.reportId),
        ),
      )
      .limit(1);

    if (existing) {
      return existing;
    }

    const [favorite] = await this.db
      .insert(favorites)
      .values(data)
      .returning();

    return favorite;
  }

  async removeFavorite(userId: string, reportId: string) {
    const result = await this.db
      .delete(favorites)
      .where(
        and(eq(favorites.userId, userId), eq(favorites.reportId, reportId)),
      )
      .returning();

    return result.length > 0;
  }

  async getFavorites(userId: string): Promise<ParkingReportEntity[]> {
    const userFavorites = await this.db
      .select({ reportId: favorites.reportId })
      .from(favorites)
      .where(eq(favorites.userId, userId));

    if (userFavorites.length === 0) {
      return [];
    }

    const reportIds = userFavorites.map((f) => f.reportId);

    const reports = await this.db
      .select()
      .from(parkingReports)
      .where(inArray(parkingReports.id, reportIds));

    return reports.map((report) => this.mapToEntity(report));
  }

  async isFavorite(userId: string, reportId: string): Promise<boolean> {
    const [favorite] = await this.db
      .select()
      .from(favorites)
      .where(
        and(eq(favorites.userId, userId), eq(favorites.reportId, reportId)),
      )
      .limit(1);

    return !!favorite;
  }

  async getFavoriteIds(userId: string): Promise<string[]> {
    const userFavorites = await this.db
      .select({ reportId: favorites.reportId })
      .from(favorites)
      .where(eq(favorites.userId, userId));

    return userFavorites.map((f) => f.reportId);
  }
}
