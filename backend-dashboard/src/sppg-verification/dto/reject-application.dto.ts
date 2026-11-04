import { IsString, MaxLength, MinLength } from 'class-validator';

export class RejectApplicationDto {
  @IsString()
  @MinLength(5, { message: 'Alasan penolakan minimal 5 karakter' })
  @MaxLength(500, { message: 'Alasan penolakan maksimal 500 karakter' })
  reason: string;
}
