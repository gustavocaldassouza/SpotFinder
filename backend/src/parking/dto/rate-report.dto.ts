import { z } from 'zod';

export const rateReportSchema = z.object({
  isUpvote: z.boolean(),
});

export type RateReportDto = z.infer<typeof rateReportSchema>;
