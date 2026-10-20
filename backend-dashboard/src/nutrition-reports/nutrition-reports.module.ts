import { Module } from '@nestjs/common';
import { NutritionReportsController } from './nutrition-reports.controller';
import { NutritionReportsService } from './nutrition-reports.service';

@Module({
  controllers: [NutritionReportsController],
  providers: [NutritionReportsService],
})
export class NutritionReportsModule {}
