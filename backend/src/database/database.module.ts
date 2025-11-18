import { Module, Global } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { getDatabase } from './client';
import type { Database } from './client';

const DATABASE_TOKEN = 'DATABASE';

@Global()
@Module({
  providers: [
    {
      provide: DATABASE_TOKEN,
      useFactory: (configService: ConfigService) => {
        const dbUrl = configService.get<string>('DATABASE_URL');
        if (!dbUrl) {
          throw new Error('DATABASE_URL is not defined');
        }
        return getDatabase(dbUrl);
      },
      inject: [ConfigService],
    },
  ],
  exports: [DATABASE_TOKEN],
})
export class DatabaseModule {}

export { DATABASE_TOKEN };
