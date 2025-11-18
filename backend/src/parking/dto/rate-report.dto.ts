import { z } from 'zod';

export const rateReportSchema = z.object({
  rating: z.union([z.literal(1), z.literal(-1)]),
});

export type RateReportDto = z.infer<typeof rateReportSchema>;
