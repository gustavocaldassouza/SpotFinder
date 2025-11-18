import { Module } from '@nestjs/common';
import { ParkingWebSocketGateway } from './websocket.gateway';
import { WebSocketService } from './websocket.service';

@Module({
  providers: [ParkingWebSocketGateway, WebSocketService],
  exports: [WebSocketService],
})
export class WebSocketModule {}
