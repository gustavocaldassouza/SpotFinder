import { z } from 'zod';
import dotenv from 'dotenv';

dotenv.config();

const envSchema = z.object({
  NODE_ENV: z
    .enum(['development', 'production', 'test'])
    .default('development'),
  PORT: z.string().default('3000'),
  DATABASE_URL: z.string().optional(),
  DATABASE_SSL: z.string().default('false'),
  LOG_LEVEL: z.string().default('debug'),
  WEBSOCKET_CORS_ORIGIN: z.string().default('http://localhost:3000'),
  DEFAULT_SEARCH_RADIUS: z.string().default('500'),
  REPORT_EXPIRATION_TIME: z.string().default('1800000'),
  JWT_SECRET: z.string().default('your-secret-key'),
  JWT_REFRESH_SECRET: z.string().default('your-refresh-secret-key'),
});

export type Environment = z.infer<typeof envSchema>;

export const validateEnvironment = (): Environment => {
  const parsed = envSchema.safeParse(process.env);

  if (!parsed.success) {
    console.error('❌ Invalid environment variables:', parsed.error.format());
    throw new Error('Invalid environment configuration');
  }

  const env = parsed.data;

  if (!env.DATABASE_URL) {
    const fallback = 'postgresql://postgres:postgres@localhost:5432/spotfinder';
    console.warn(
      `⚠️  DATABASE_URL not set — falling back to local default: ${fallback}`,
    );
    env.DATABASE_URL = fallback;
  }

  return env;
};
