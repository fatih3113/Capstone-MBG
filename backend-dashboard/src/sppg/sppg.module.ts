import { Module } from '@nestjs/common';
import { SppgController } from './sppg.controller';
import { SppgService } from './sppg.service';
import { PrismaModule } from '../prisma/prisma.module';

@Module({
  imports: [PrismaModule],
  controllers: [SppgController],
  providers: [SppgService],
  exports: [SppgService],
})
export class SppgModule {}
