import { Injectable, Inject } from '@nestjs/common';
import { eq, and, gte, lte, sql } from 'drizzle-orm';
import type { Database } from '../database/client';
import { DATABASE_TOKEN } from '../database/database.module';
import {
  parkingReports,
  reportRatings,
  NewParkingReport,
  NewReportRating,
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
}
