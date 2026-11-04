import {
  IsBoolean,
  IsEmail,
  IsInt,
  IsOptional,
  IsString,
  Matches,
  Max,
  MaxLength,
  Min,
  MinLength,
} from 'class-validator';
import { Transform, Type } from 'class-transformer';

/**
 * Pendaftaran akun Admin SPPG Daerah.
 * Sengaja TIDAK ada field `role` / `accountStatus`: keduanya ditentukan server.
 * (ValidationPipe global memakai forbidNonWhitelisted, jadi field tambahan -> 400.)
 */
export class RegisterSppgDto {
  // ── Akun ───────────────────────────────────────────────
  @IsString()
  @MinLength(3, { message: 'Nama minimal 3 karakter' })
  @MaxLength(100)
  name: string;

  @IsEmail({}, { message: 'Email tidak valid' })
  @MaxLength(150)
  email: string;

  @IsString()
  @MinLength(8, { message: 'Password minimal 8 karakter' })
  @MaxLength(72, { message: 'Password maksimal 72 karakter' })
  @Matches(/^(?=.*[A-Za-z])(?=.*\d).+$/, {
    message: 'Password harus mengandung huruf dan angka',
  })
  password: string;

  // ── Data SPPG ──────────────────────────────────────────
  @IsString()
  @MinLength(3, { message: 'Nama SPPG minimal 3 karakter' })
  @MaxLength(200)
  sppgNama: string;

  @IsString()
  @MinLength(2, { message: 'Provinsi tidak boleh kosong' })
  @MaxLength(100)
  provinsi: string;

  @IsString()
  @MinLength(2, { message: 'Kabupaten/Kota tidak boleh kosong' })
  @MaxLength(100)
  kabupatenKota: string;

  @IsString()
  @MinLength(2, { message: 'Kecamatan tidak boleh kosong' })
  @MaxLength(100)
  kecamatan: string;

  @IsString()
  @MinLength(2, { message: 'Kelurahan/Desa tidak boleh kosong' })
  @MaxLength(100)
  kelurahanDesa: string;

  @IsOptional()
  @IsString()
  @MaxLength(300)
  alamat?: string;

  @IsString()
  @MinLength(3, { message: 'Nama penanggung jawab minimal 3 karakter' })
  @MaxLength(100)
  penanggungJawab: string;

  @IsString()
  @Matches(/^[0-9+\-\s]{8,20}$/, {
    message: 'Kontak harus berupa nomor telepon yang valid',
  })
  kontak: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt({ message: 'Kapasitas porsi harus berupa bilangan bulat' })
  @Min(1)
  @Max(100000)
  kapasitasPorsi?: number;

  @IsOptional()
  @IsBoolean()
  @Transform(({ value }) => value === true || value === 'true')
  is3t?: boolean;
}
