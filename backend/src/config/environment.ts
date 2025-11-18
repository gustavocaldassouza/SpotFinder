import { z } from 'zod';

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  PORT: z.string().default('3000'),
  DATABASE_URL: z.string(),
  DATABASE_SSL: z.string().default('false'),
  LOG_LEVEL: z.string().default('debug'),
  WEBSOCKET_CORS_ORIGIN: z.string().default('http://localhost:3000'),
  DEFAULT_SEARCH_RADIUS: z.string().default('500'),
  REPORT_EXPIRATION_TIME: z.string().default('1800000'),
});

export type Environment = z.infer<typeof envSchema>;

export const validateEnvironment = () => {
  try {
    return envSchema.parse(process.env);
  } catch (error) {
    console.error('❌ Invalid environment variables:', error);
    throw new Error('Invalid environment configuration');
  }
};
