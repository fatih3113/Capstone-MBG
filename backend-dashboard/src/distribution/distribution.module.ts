import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { DistributionController } from './distribution.controller';
import { DistributionService } from './distribution.service';

@Module({
  imports: [PrismaModule],
  controllers: [DistributionController],
  providers: [DistributionService],
})
export class DistributionModule {}
