import {
  Controller,
  Get,
  Post,
  Put,
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

  @Get(':id')
  async getReportById(@Param('id') id: string) {
    const report = await this.parkingService.getReportById(id);
    return report;
  }

  @Post()
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.CREATED)
  @UsePipes(new ZodValidationPipe(createReportSchema))
  async createReport(@Body() dto: CreateReportDto, @CurrentUser() user: User) {
    const result = await this.parkingService.createReport(dto, user.id);
    return result;
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
