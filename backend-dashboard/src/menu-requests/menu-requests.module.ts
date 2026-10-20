import { Module } from '@nestjs/common';
import { MenuRequestsController } from './menu-requests.controller';
import { MenuRequestsService } from './menu-requests.service';

@Module({
  controllers: [MenuRequestsController],
  providers: [MenuRequestsService],
})
export class MenuRequestsModule {}
