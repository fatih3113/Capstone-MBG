import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import helmet from 'helmet';
import * as dotenv from 'dotenv';

dotenv.config();

async function bootstrap() {
  const app = await NestFactory.create(AppModule, {
    logger: ['log', 'error', 'warn'],
  });

  const port = process.env.PORT ?? 4000;
  const allowedOrigins = process.env.ALLOWED_ORIGINS?.split(',') ?? [
    'http://localhost:5173',
    'http://localhost:4173',
  ];

  // ── Security ────────────────────────────────────────────────
  app.use(helmet());

  // ── CORS — hanya izinkan frontend-dashboard ──────────────────
  app.enableCors({
    origin: allowedOrigins,
    methods: ['GET', 'POST', 'PATCH', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
    credentials: true,
  });

  // ── Global prefix ────────────────────────────────────────────
  app.setGlobalPrefix('api/v1');

  await app.listen(port);
  console.log(`\n🚀 Foodler Dashboard API berjalan di http://localhost:${port}/api/v1`);
  console.log(`📋 Health check: http://localhost:${port}/api/v1/auth/profile`);
  console.log(`🌐 CORS diizinkan dari: ${allowedOrigins.join(', ')}\n`);
}

bootstrap();
