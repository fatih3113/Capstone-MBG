-- Migration: add_allergy_fields
-- Menambah kolom alergi makanan pada tabel users.
-- Aman untuk pengguna lama: allergies default kosong, allergyFilled default false.
-- Idempoten: pakai IF NOT EXISTS agar bisa dijalankan ulang tanpa error.
--
-- Cara menjalankan:
--   psql -U postgres -d mbg_nutrition_db -f prisma/migrations/20261031_add_allergy_fields/migration.sql
-- Atau dari pgAdmin: buka Query Tool, paste isi file ini, lalu Execute.

BEGIN;

-- 1. Kolom allergies (array teks, default array kosong)
ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS allergies TEXT[] NOT NULL DEFAULT '{}';

-- 2. Kolom allergy_other (teks opsional, diisi hanya jika "lainnya" dipilih)
ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS allergy_other TEXT;

-- 3. Kolom allergy_filled (boolean, membedakan "belum diisi" dari "tidak alergi")
ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS allergy_filled BOOLEAN NOT NULL DEFAULT FALSE;

COMMIT;

