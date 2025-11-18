import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { AllExceptionsFilter } from './common/filters/exception.filter';
import { Logger } from 'nestjs-pino';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, { bufferLogs: true });
  
  // Use pino logger
  app.useLogger(app.get(Logger));
  
  // Global exception filter
  app.useGlobalFilters(new AllExceptionsFilter());
  
  // Enable CORS
  app.enableCors({
    origin: process.env.WEBSOCKET_CORS_ORIGIN || '*',
    credentials: true,
  });

  const port = process.env.PORT || 3000;
  await app.listen(port);
  
  console.log(`🚀 SpotFinder API running on port ${port}`);
}
bootstrap();
