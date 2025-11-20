import { Injectable, Logger } from '@nestjs/common';

@Injectable()
export class WebSocketService {
  private readonly logger = new Logger(WebSocketService.name);
  private server: any;

  setServer(server: any) {
    this.server = server;
  }

  broadcastNewReport(report: any) {
    if (!this.server) return;

    this.logger.debug(`Broadcasting new report: ${report.id}`);
    this.server.emit('parking:report:new', report);
  }

  broadcastReportRated(data: {
    id: string;
    accuracyRating: number;
    totalRatings: number;
  }) {
    if (!this.server) return;

    this.logger.debug(`Broadcasting rating update for report: ${data.id}`);
    this.server.emit('parking:report:rated', data);
  }

  broadcastReportExpired(reportId: string) {
    if (!this.server) return;

    this.logger.debug(`Broadcasting expiration for report: ${reportId}`);
    this.server.emit('parking:report:expired', { id: reportId });
  }

  emitToRoom(room: string, event: string, data: any) {
    if (!this.server) return;

    this.server.to(room).emit(event, data);
  }
}
