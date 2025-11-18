import { z } from 'zod';

export const createReportSchema = z.object({
  latitude: z.number().min(-90).max(90),
  longitude: z.number().min(-180).max(180),
  status: z.enum(['available', 'taken']),
  description: z.string().optional(),
});

export type CreateReportDto = z.infer<typeof createReportSchema>;
