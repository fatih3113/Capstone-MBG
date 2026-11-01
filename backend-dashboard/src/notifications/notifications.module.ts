import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { NotificationsService } from './notifications.service';

@Module({
  imports: [PrismaModule], // PrismaService disediakan oleh PrismaModule milik proyek Anda
  providers: [NotificationsService],
  exports: [NotificationsService],
})
export class NotificationsModule {}