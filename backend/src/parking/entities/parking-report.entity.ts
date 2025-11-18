export interface ParkingReportEntity {
  id: string;
  latitude: number;
  longitude: number;
  status: string;
  description: string | null;
  createdAt: Date;
  createdAgo?: string;
  accuracyRating: number;
  totalRatings: number;
  distance?: number;
  isActive: boolean;
  expiresAt: Date;
}

export interface ParkingReportWithDistance extends ParkingReportEntity {
  distance: number;
}
