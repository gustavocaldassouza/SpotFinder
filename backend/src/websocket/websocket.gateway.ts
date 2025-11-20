import {
  WebSocketGateway as WebSocketGatewayDecorator,
  WebSocketServer,
  SubscribeMessage,
  OnGatewayInit,
  OnGatewayConnection,
  OnGatewayDisconnect,
  MessageBody,
  ConnectedSocket,
} from '@nestjs/websockets';
import { Logger } from '@nestjs/common';
import { Server, Socket } from 'socket.io';
import { WebSocketService } from './websocket.service';

interface NearbySubscription {
  lat: number;
  lng: number;
  radius: number;
}

@WebSocketGatewayDecorator({
  cors: {
    origin: process.env.WEBSOCKET_CORS_ORIGIN || '*',
    credentials: true,
  },
})
export class ParkingWebSocketGateway
  implements OnGatewayInit, OnGatewayConnection, OnGatewayDisconnect
{
  @WebSocketServer()
  server: Server;

  private readonly logger = new Logger(ParkingWebSocketGateway.name);

  constructor(private readonly wsService: WebSocketService) {}

  afterInit(server: Server) {
    this.wsService.setServer(server);
    this.logger.log('WebSocket Gateway initialized');
  }

  handleConnection(client: Socket) {
    this.logger.log(`Client connected: ${client.id}`);
  }

  handleDisconnect(client: Socket) {
    this.logger.log(`Client disconnected: ${client.id}`);
  }

  @SubscribeMessage('parking:nearby')
  handleNearbySubscription(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: NearbySubscription,
  ) {
    try {
      const { lat, lng, radius } = data;
      const roomName = `nearby:${lat.toFixed(3)}:${lng.toFixed(3)}:${radius}`;

      // Join the room for location-based updates
      client.join(roomName);

      this.logger.debug(
        `Client ${client.id} subscribed to nearby updates: ${roomName}`,
      );

      return {
        success: true,
        message: 'Subscribed to nearby parking updates',
        room: roomName,
      };
    } catch (error) {
      this.logger.error('Error handling nearby subscription:', error);
      return {
        success: false,
        message: 'Failed to subscribe',
      };
    }
  }

  @SubscribeMessage('parking:unsubscribe')
  handleUnsubscribe(@ConnectedSocket() client: Socket) {
    // Leave all rooms except the default one
    const rooms = Array.from(client.rooms).filter((room) => room !== client.id);
    rooms.forEach((room) => client.leave(room));

    this.logger.debug(`Client ${client.id} unsubscribed from all rooms`);

    return {
      success: true,
      message: 'Unsubscribed from all updates',
    };
  }
}
