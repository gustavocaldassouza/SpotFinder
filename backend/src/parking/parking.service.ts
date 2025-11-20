import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { ParkingRepository } from './parking.repository';
import { CreateReportDto } from './dto/create-report.dto';
import { RateReportDto } from './dto/rate-report.dto';
import { calculateTimeAgo } from '../utils/geolocation';
import { WebSocketService } from '../websocket/websocket.service';

@Injectable()
export class ParkingService {
  private readonly defaultRadius: number;
  private readonly reportExpirationTime: number;

  constructor(
    private readonly repository: ParkingRepository,
    private readonly configService: ConfigService,
    private readonly wsService: WebSocketService,
  ) {
    this.defaultRadius = parseInt(
      this.configService.get<string>('DEFAULT_SEARCH_RADIUS', '500'),
    );
    this.reportExpirationTime = parseInt(
      this.configService.get<string>('REPORT_EXPIRATION_TIME', '1800000'),
    );
  }

  async createReport(dto: CreateReportDto) {
    const expiresAt = new Date(Date.now() + this.reportExpirationTime);

    const report = await this.repository.create({
      latitude: dto.latitude,
      longitude: dto.longitude,
      status: dto.status,
      description: dto.description || null,
      expiresAt,
      userId: null,
    });

    // Get the full report with all details
    const reportWithDetails = await this.repository.findById(report.id);
    
    if (reportWithDetails) {
      // Broadcast new report via WebSocket
      this.wsService.broadcastNewReport({
        ...reportWithDetails,
        createdAgo: calculateTimeAgo(reportWithDetails.createdAt),
      });

      return {
        ...reportWithDetails,
        createdAgo: calculateTimeAgo(reportWithDetails.createdAt),
      };
    }

    // Fallback if full report couldn't be retrieved
    return {
      id: report.id,
      latitude: dto.latitude,
      longitude: dto.longitude,
      status: dto.status,
      description: dto.description || null,
      accuracyRating: 0,
      totalRatings: 0,
      isActive: true,
      createdAt: report.createdAt,
      expiresAt: expiresAt,
      createdAgo: calculateTimeAgo(report.createdAt),
    };
  }

  async getNearbyReports(latitude: number, longitude: number, radius?: number) {
    const searchRadius = radius || this.defaultRadius;

    // Expire old reports before querying
    await this.repository.expireOldReports();

    const reports = await this.repository.findNearby(
      latitude,
      longitude,
      searchRadius,
    );

    return reports.map((report) => ({
      ...report,
      createdAgo: calculateTimeAgo(report.createdAt),
      distance: Math.round(report.distance * 10) / 10, // Round to 1 decimal
    }));
  }

  async getReportById(id: string) {
    const report = await this.repository.findById(id);
    if (!report) {
      throw new NotFoundException(`Report with ID ${id} not found`);
    }

    return {
      ...report,
      createdAgo: calculateTimeAgo(report.createdAt),
    };
  }

  async rateReport(id: string, dto: RateReportDto, userId?: string) {
    const report = await this.repository.findById(id);
    if (!report) {
      throw new NotFoundException(`Report with ID ${id} not found`);
    }

    if (!report.isActive) {
      throw new BadRequestException('Cannot rate an expired report');
    }

    // Convert isUpvote boolean to rating (-1 or 1)
    const rating = dto.isUpvote ? 1 : -1;

    await this.repository.addRating({
      reportId: id,
      rating,
      userId: userId || null,
    });

    // Get updated report
    const updatedReport = await this.repository.findById(id);
    if (updatedReport) {
      // Broadcast rating update via WebSocket
      this.wsService.broadcastReportRated({
        id: updatedReport.id,
        accuracyRating: updatedReport.accuracyRating,
        totalRatings: updatedReport.totalRatings,
      });

      return {
        ...updatedReport,
        createdAgo: calculateTimeAgo(updatedReport.createdAt),
      };
    }

    throw new NotFoundException(`Failed to retrieve updated report`);
  }
}
