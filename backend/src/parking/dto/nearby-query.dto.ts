import { z } from 'zod';

export const nearbyQuerySchema = z.object({
  lat: z.string().transform(Number).pipe(z.number().min(-90).max(90)),
  lng: z.string().transform(Number).pipe(z.number().min(-180).max(180)),
  radius: z.string().transform(Number).pipe(z.number().positive()).optional(),
});

export type NearbyQueryDto = z.infer<typeof nearbyQuerySchema>;
