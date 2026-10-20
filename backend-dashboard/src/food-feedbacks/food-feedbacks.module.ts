import { Module } from '@nestjs/common';
import { FoodFeedbacksController } from './food-feedbacks.controller';
import { FoodFeedbacksService } from './food-feedbacks.service';

@Module({
  controllers: [FoodFeedbacksController],
  providers: [FoodFeedbacksService],
})
export class FoodFeedbacksModule {}
