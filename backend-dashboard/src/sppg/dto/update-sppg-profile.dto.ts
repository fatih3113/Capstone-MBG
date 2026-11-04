import {
  IsInt,
  IsNumber,
  IsOptional,
  IsString,
  Matches,
  Max,
  MaxLength,
  Min,
  MinLength,
} from 'class-validator';
import { Type } from 'class-transformer';

/**
 * Field yang boleh diubah Admin SPPG pada SPPG-nya sendiri.
 * Sengaja tidak memuat nama/wilayah/kode/status — itu hak Super Admin.
 */
export class UpdateSppgProfileDto {
  @IsOptional()
  @IsString()
  @MaxLength(300)
  alamat?: string;

  @IsOptional()
  @IsString()
  @MinLength(3)
  @MaxLength(100)
  penanggungjawab?: string;

  @IsOptional()
  @IsString()
  @Matches(/^[0-9+\-\s]{8,20}$/, { message: 'Kontak harus berupa nomor telepon yang valid' })
  kontak?: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100000)
  kapasitasPorsi?: number;

  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  latitude?: number;

  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  longitude?: number;
}
