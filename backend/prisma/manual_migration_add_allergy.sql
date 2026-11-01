-- =============================================================================
-- manual_migration_add_allergy.sql
-- Menambah data alergi makanan pada tabel users.
-- Aman dijalankan berulang (idempoten) dan tidak mengubah data lama:
--   pengguna lama otomatis allergies = {} dan allergy_filled = false.
--
-- Jalankan:
--   psql -U postgres -d mbg_nutrition_db -f backend/prisma/manual_migration_add_allergy.sql
-- (simpan file ini sebagai UTF-8 TANPA BOM)
-- =============================================================================

BEGIN;

ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS allergies TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[];

ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS allergy_other VARCHAR(100);

ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS allergy_filled BOOLEAN NOT NULL DEFAULT false;

-- Pengaman di level database: hanya nilai yang diizinkan.
DO $BLOCK$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'users_allergies_allowed_check') THEN
    ALTER TABLE public.users
      ADD CONSTRAINT users_allergies_allowed_check
      CHECK (allergies <@ ARRAY['kacang','telur','susu','ikan','udang','gandum','kedelai','lainnya']::TEXT[]);
  END IF;
END
$BLOCK$;

-- allergy_other hanya boleh terisi jika "lainnya" dipilih.
DO $BLOCK$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'users_allergy_other_check') THEN
    ALTER TABLE public.users
      ADD CONSTRAINT users_allergy_other_check
      CHECK (allergy_other IS NULL OR 'lainnya' = ANY(allergies));
  END IF;
END
$BLOCK$;

COMMIT;