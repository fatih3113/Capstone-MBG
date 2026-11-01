import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { NotificationsModule } from '../notifications/notifications.module';
import { DistributionController } from './distribution.controller';
import { DistributionService } from './distribution.service';

@Module({
  imports: [PrismaModule, NotificationsModule],
  controllers: [DistributionController],
  providers: [DistributionService],
})
export class DistributionModule {}