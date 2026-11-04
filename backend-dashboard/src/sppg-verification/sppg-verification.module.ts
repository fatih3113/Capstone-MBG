import { Module } from '@nestjs/common';
import { SppgVerificationController } from './sppg-verification.controller';
import { SppgVerificationService } from './sppg-verification.service';

@Module({
  controllers: [SppgVerificationController],
  providers: [SppgVerificationService],
})
export class SppgVerificationModule {}
