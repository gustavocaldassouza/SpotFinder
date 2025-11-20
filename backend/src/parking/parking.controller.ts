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
} from '@nestjs/common';
import { ParkingService } from './parking.service';
import { ZodValidationPipe } from '../common/pipes/validation.pipe';
import {
  createReportSchema,
  type CreateReportDto,
} from './dto/create-report.dto';
import { rateReportSchema, type RateReportDto } from './dto/rate-report.dto';
import { nearbyQuerySchema, type NearbyQueryDto } from './dto/nearby-query.dto';

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
  @HttpCode(HttpStatus.CREATED)
  @UsePipes(new ZodValidationPipe(createReportSchema))
  async createReport(@Body() dto: CreateReportDto) {
    const result = await this.parkingService.createReport(dto);
    return result;
  }

  @Put(':id/rate')
  async rateReport(
    @Param('id') id: string,
    @Body(new ZodValidationPipe(rateReportSchema)) dto: RateReportDto,
  ) {
    const result = await this.parkingService.rateReport(id, dto);
    return result;
  }
}
