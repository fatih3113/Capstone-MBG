import { IsString, IsOptional, IsBoolean, IsNumber, IsUUID, MinLength, MaxLength } from 'class-validator';
import { Transform, Type } from 'class-transformer';

export class CreateSppgDto {
  @IsString()
  @MinLength(3, { message: 'Nama SPPG minimal 3 karakter' })
  @MaxLength(200, { message: 'Nama SPPG maksimal 200 karakter' })
  nama: string;

  @IsOptional()
  @IsString()
  kode?: string;

  @IsString()
  @MinLength(2, { message: 'Provinsi tidak boleh kosong' })
  provinsi: string;

  @IsString()
  @MinLength(2, { message: 'Kabupaten/Kota tidak boleh kosong' })
  kabupatenKota: string;

  @IsString()
  @MinLength(2, { message: 'Kecamatan tidak boleh kosong' })
  kecamatan: string;

  @IsString()
  @MinLength(2, { message: 'Kelurahan/Desa tidak boleh kosong' })
  kelurahanDesa: string;

  @IsOptional()
  @IsString()
  alamat?: string;

  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  latitude?: number;

  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  longitude?: number;

  @IsOptional()
  @IsBoolean()
  @Transform(({ value }) => value === true || value === 'true')
  isActive?: boolean;
}
