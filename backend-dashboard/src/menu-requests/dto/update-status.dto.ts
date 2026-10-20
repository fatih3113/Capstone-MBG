import { IsIn, IsOptional, IsString, MaxLength } from 'class-validator';

export class UpdateStatusDto {
  @IsIn(['received', 'reviewing', 'considered', 'approved', 'rejected'], {
    message: 'Status tidak valid. Pilih: received, reviewing, considered, approved, atau rejected',
  })
  status: string;

  @IsOptional()
  @IsString()
  @MaxLength(500, { message: 'Catatan admin maksimal 500 karakter' })
  adminNote?: string;
}
