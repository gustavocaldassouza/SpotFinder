import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
  UsePipes,
  HttpCode,
  HttpStatus,
  UseGuards,
} from '@nestjs/common';
import { ParkingService } from './parking.service';
import { ZodValidationPipe } from '../common/pipes/validation.pipe';
import {
  createReportSchema,
  type CreateReportDto,
} from './dto/create-report.dto';
import { rateReportSchema, type RateReportDto } from './dto/rate-report.dto';
import { nearbyQuerySchema, type NearbyQueryDto } from './dto/nearby-query.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import type { User } from '../database/schema';

@Controller('api/parking-reports')
export class ParkingController {
  constructor(private readonly parkingService: ParkingService) {}

  @Get('nearby')
  async getNearbyReports(
    @Query(new ZodValidationPipe(nearbyQuerySchema)) query: NearbyQueryDto,
  ) {
    const reports = await this.parkingService.getNearbyReports(
      query.lat,
      query.lng,
      query.radius,
    );

    return reports;
  }

  @Get('favorites')
  @UseGuards(JwtAuthGuard)
  async getFavorites(@CurrentUser() user: User) {
    return this.parkingService.getFavorites(user.id);
  }

  @Get('favorites/ids')
  @UseGuards(JwtAuthGuard)
  async getFavoriteIds(@CurrentUser() user: User) {
    return this.parkingService.getFavoriteIds(user.id);
  }

  @Get(':id')
  async getReportById(@Param('id') id: string) {
    const report = await this.parkingService.getReportById(id);
    return report;
  }

  @Get(':id/favorite')
  @UseGuards(JwtAuthGuard)
  async isFavorite(@Param('id') id: string, @CurrentUser() user: User) {
    const isFavorite = await this.parkingService.isFavorite(id, user.id);
    return { isFavorite };
  }

  @Post()
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.CREATED)
  async createReport(
    @Body(new ZodValidationPipe(createReportSchema)) dto: CreateReportDto,
    @CurrentUser() user: User,
  ) {
    const result = await this.parkingService.createReport(dto, user.id);
    return result;
  }

  @Post(':id/favorite')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.CREATED)
  async addFavorite(@Param('id') id: string, @CurrentUser() user: User) {
    return this.parkingService.addFavorite(id, user.id);
  }

  @Delete(':id/favorite')
  @UseGuards(JwtAuthGuard)
  async removeFavorite(@Param('id') id: string, @CurrentUser() user: User) {
    return this.parkingService.removeFavorite(id, user.id);
  }

  @Put(':id/rate')
  @UseGuards(JwtAuthGuard)
  async rateReport(
    @Param('id') id: string,
    @Body(new ZodValidationPipe(rateReportSchema)) dto: RateReportDto,
    @CurrentUser() user: User,
  ) {
    const result = await this.parkingService.rateReport(id, dto, user.id);
    return result;
  }
}
