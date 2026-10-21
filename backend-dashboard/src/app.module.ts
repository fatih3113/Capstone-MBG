import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { ThrottlerModule, ThrottlerGuard } from '@nestjs/throttler';
import { APP_GUARD, APP_PIPE } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { DashboardModule } from './dashboard/dashboard.module';
import { MenuRequestsModule } from './menu-requests/menu-requests.module';
import { FoodRatingsModule } from './food-ratings/food-ratings.module';
import { FoodFeedbacksModule } from './food-feedbacks/food-feedbacks.module';
import { NutritionReportsModule } from './nutrition-reports/nutrition-reports.module';
import { DistributionModule } from './distribution/distribution.module';
import { FoodsModule } from './foods/foods.module';
import { SchoolsModule } from './schools/schools.module';

@Module({
  imports: [
    // Load .env
    ConfigModule.forRoot({ isGlobal: true }),

    // Rate limiting: max 100 req per 15 menit per IP
    ThrottlerModule.forRoot([{ ttl: 60000 * 15, limit: 100 }]),

    // Shared Prisma client (global)
    PrismaModule,

    // Feature modules
    AuthModule,
    DashboardModule,
    MenuRequestsModule,
    FoodRatingsModule,
    FoodFeedbacksModule,
    NutritionReportsModule,
    DistributionModule,
    FoodsModule,
    SchoolsModule,
  ],
  providers: [
    // Global rate-limit guard
    { provide: APP_GUARD, useClass: ThrottlerGuard },
    // Global validation pipe
    {
      provide: APP_PIPE,
      useValue: new ValidationPipe({
        whitelist: true,       // strip unknown properties
        transform: true,       // auto-transform types
        forbidNonWhitelisted: true,
        errorHttpStatusCode: 400,
      }),
    },
  ],
})
export class AppModule {}
