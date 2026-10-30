import { PartialType } from '@nestjs/mapped-types';
import { CreateSppgDto } from './create-sppg.dto';

export class UpdateSppgDto extends PartialType(CreateSppgDto) {}
