import { Module } from '@nestjs/common';
import { FoodRatingsController } from './food-ratings.controller';
import { FoodRatingsService } from './food-ratings.service';

@Module({
  controllers: [FoodRatingsController],
  providers: [FoodRatingsService],
})
export class FoodRatingsModule {}
