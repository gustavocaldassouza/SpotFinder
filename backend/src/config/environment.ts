import { z } from 'zod';
import dotenv from 'dotenv';

// Load .env (if present) so process.env contains project env for local dev
dotenv.config();

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  PORT: z.string().default('3000'),
  // Make DATABASE_URL optional here and provide a sensible local default below
  DATABASE_URL: z.string().optional(),
  DATABASE_SSL: z.string().default('false'),
  LOG_LEVEL: z.string().default('debug'),
  WEBSOCKET_CORS_ORIGIN: z.string().default('http://localhost:3000'),
  DEFAULT_SEARCH_RADIUS: z.string().default('500'),
  REPORT_EXPIRATION_TIME: z.string().default('1800000'),
});

export type Environment = z.infer<typeof envSchema>;

export const validateEnvironment = (): Environment => {
  const parsed = envSchema.safeParse(process.env);

  if (!parsed.success) {
    // If parsing fails for reasons other than missing DATABASE_URL, surface the error
    console.error('❌ Invalid environment variables:', parsed.error.format());
    throw new Error('Invalid environment configuration');
  }

  const env = parsed.data;

  // Provide a helpful default for local development if DATABASE_URL isn't set.
  // NOTE: For production, you MUST set DATABASE_URL explicitly (e.g. in your deployment environment).
  if (!env.DATABASE_URL) {
    const fallback = 'postgresql://postgres:postgres@localhost:5432/spotfinder';
    console.warn(`⚠️  DATABASE_URL not set — falling back to local default: ${fallback}`);
    env.DATABASE_URL = fallback;
  }

  return env as Environment;
};
