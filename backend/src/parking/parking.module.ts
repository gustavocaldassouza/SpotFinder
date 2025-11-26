import { Module } from '@nestjs/common';
import { ParkingController } from './parking.controller';
import { ParkingService } from './parking.service';
import { ParkingRepository } from './parking.repository';
import { WebSocketModule } from '../websocket/websocket.module';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [WebSocketModule, AuthModule],
  controllers: [ParkingController],
  providers: [ParkingService, ParkingRepository],
  exports: [ParkingService],
})
export class ParkingModule {}
