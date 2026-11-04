-- =============================================================================
-- 02_sppg_workflow.sql
-- Melengkapi db/init.sql dengan skema yang dipakai kode terbaru:
--   * tabel sppgs (+ kolom verifikasi / operasional)
--   * users.sppg_id, users.account_status, kolom alergi
--   * schools.sppg_id
--   * tabel operasional SPPG (procurements, production_batches, deliveries,
--     food_safety_incidents)
--   * tabel notifications
-- Idempoten (aman dijalankan berulang). Dijalankan otomatis oleh Docker setelah
-- init.sql (lihat docker-compose.yaml). Untuk DB yang SUDAH berjalan, jalankan manual:
--   psql -U postgres -d mbg_nutrition_db -f db/02_sppg_workflow.sql
-- =============================================================================

BEGIN;

-- ─── 1. sppgs ───────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.sppgs (
  id                  TEXT         PRIMARY KEY DEFAULT gen_random_uuid()::text,
  kode                TEXT         UNIQUE,
  nama                TEXT         NOT NULL,
  provinsi            TEXT         NOT NULL,
  kabupaten_kota      TEXT         NOT NULL,
  kecamatan           TEXT         NOT NULL,
  kelurahan_desa      TEXT         NOT NULL,
  alamat              TEXT,
  latitude            DOUBLE PRECISION,
  longitude           DOUBLE PRECISION,
  is_active           BOOLEAN      NOT NULL DEFAULT true,
  created_at          TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at          TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  verification_status TEXT         NOT NULL DEFAULT 'APPROVED',
  rejection_reason    TEXT,
  verified_by         TEXT,
  verified_at         TIMESTAMP(3),
  operational_status  TEXT         NOT NULL DEFAULT 'ACTIVE',
  suspension_reason   TEXT,
  suspended_at        TIMESTAMP(3),
  is_3t               BOOLEAN      NOT NULL DEFAULT false,
  kapasitas_porsi     INTEGER,
  penanggung_jawab    TEXT,
  kontak              TEXT
);

-- Jika tabel sppgs sudah ada dari versi lama, pastikan semua kolom workflow ada
ALTER TABLE public.sppgs ADD COLUMN IF NOT EXISTS verification_status TEXT NOT NULL DEFAULT 'APPROVED';
ALTER TABLE public.sppgs ADD COLUMN IF NOT EXISTS rejection_reason TEXT;
ALTER TABLE public.sppgs ADD COLUMN IF NOT EXISTS verified_by TEXT;
ALTER TABLE public.sppgs ADD COLUMN IF NOT EXISTS verified_at TIMESTAMP(3);
ALTER TABLE public.sppgs ADD COLUMN IF NOT EXISTS operational_status TEXT NOT NULL DEFAULT 'ACTIVE';
ALTER TABLE public.sppgs ADD COLUMN IF NOT EXISTS suspension_reason TEXT;
ALTER TABLE public.sppgs ADD COLUMN IF NOT EXISTS suspended_at TIMESTAMP(3);
ALTER TABLE public.sppgs ADD COLUMN IF NOT EXISTS is_3t BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE public.sppgs ADD COLUMN IF NOT EXISTS kapasitas_porsi INTEGER;
ALTER TABLE public.sppgs ADD COLUMN IF NOT EXISTS penanggung_jawab TEXT;
ALTER TABLE public.sppgs ADD COLUMN IF NOT EXISTS kontak TEXT;

DO $BLOCK$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'sppgs_verification_status_check') THEN
    ALTER TABLE public.sppgs ADD CONSTRAINT sppgs_verification_status_check
      CHECK (verification_status IN ('PENDING', 'APPROVED', 'REJECTED'));
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'sppgs_operational_status_check') THEN
    ALTER TABLE public.sppgs ADD CONSTRAINT sppgs_operational_status_check
      CHECK (operational_status IN ('ACTIVE', 'SUSPENDED', 'INACTIVE'));
  END IF;
END
$BLOCK$;

CREATE INDEX IF NOT EXISTS idx_sppgs_region ON public.sppgs (provinsi, kabupaten_kota);
CREATE INDEX IF NOT EXISTS idx_sppgs_verification_operational
  ON public.sppgs (verification_status, operational_status);

-- ─── 2. users ───────────────────────────────────────────────────────────────
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS sppg_id TEXT;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS account_status TEXT NOT NULL DEFAULT 'ACTIVE';
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS allergies TEXT[] NOT NULL DEFAULT '{}';
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS allergy_other TEXT;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS allergy_filled BOOLEAN NOT NULL DEFAULT FALSE;

DO $BLOCK$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'users_account_status_check') THEN
    ALTER TABLE public.users ADD CONSTRAINT users_account_status_check
      CHECK (account_status IN ('PENDING', 'ACTIVE', 'REJECTED'));
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_users_sppg') THEN
    ALTER TABLE public.users ADD CONSTRAINT fk_users_sppg
      FOREIGN KEY (sppg_id) REFERENCES public.sppgs(id) ON DELETE SET NULL ON UPDATE CASCADE;
  END IF;
END
$BLOCK$;

CREATE INDEX IF NOT EXISTS idx_users_role ON public.users (role);
CREATE INDEX IF NOT EXISTS idx_users_account_status ON public.users (account_status);
CREATE INDEX IF NOT EXISTS idx_users_sppg_id ON public.users (sppg_id);

-- ─── 3. schools ─────────────────────────────────────────────────────────────
ALTER TABLE public.schools ADD COLUMN IF NOT EXISTS sppg_id TEXT;

DO $BLOCK$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_schools_sppg') THEN
    ALTER TABLE public.schools ADD CONSTRAINT fk_schools_sppg
      FOREIGN KEY (sppg_id) REFERENCES public.sppgs(id) ON DELETE SET NULL ON UPDATE CASCADE;
  END IF;
END
$BLOCK$;

CREATE INDEX IF NOT EXISTS idx_schools_sppg_id ON public.schools (sppg_id);

-- ─── 4. Tabel operasional SPPG ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.procurements (
  id            TEXT          NOT NULL DEFAULT gen_random_uuid()::text PRIMARY KEY,
  sppg_id       TEXT          NOT NULL REFERENCES public.sppgs(id) ON DELETE CASCADE,
  supplier_name TEXT          NOT NULL,
  item_name     TEXT          NOT NULL,
  quantity      NUMERIC(12,2) NOT NULL,
  unit          TEXT          NOT NULL,
  procured_at   TIMESTAMP(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP,
  notes         TEXT,
  created_at    TIMESTAMP(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_procurements_sppg_procured ON public.procurements (sppg_id, procured_at);

CREATE TABLE IF NOT EXISTS public.production_batches (
  id                TEXT         NOT NULL DEFAULT gen_random_uuid()::text PRIMARY KEY,
  sppg_id           TEXT         NOT NULL REFERENCES public.sppgs(id) ON DELETE CASCADE,
  batch_date        DATE         NOT NULL,
  menu_name         TEXT         NOT NULL,
  portions_planned  INTEGER      NOT NULL DEFAULT 0,
  portions_produced INTEGER      NOT NULL DEFAULT 0,
  qc_status         TEXT         NOT NULL DEFAULT 'PENDING' CHECK (qc_status IN ('PASSED', 'FAILED', 'PENDING')),
  qc_notes          TEXT,
  finished_at       TIMESTAMP(3),
  created_at        TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at        TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_production_batches_sppg_date ON public.production_batches (sppg_id, batch_date);

CREATE TABLE IF NOT EXISTS public.deliveries (
  id          TEXT         NOT NULL DEFAULT gen_random_uuid()::text PRIMARY KEY,
  batch_id    TEXT         NOT NULL REFERENCES public.production_batches(id) ON DELETE CASCADE,
  school_id   TEXT         NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
  portions    INTEGER      NOT NULL DEFAULT 0,
  status      TEXT         NOT NULL DEFAULT 'PREPARED' CHECK (status IN ('PREPARED', 'SENT', 'RECEIVED')),
  sent_at     TIMESTAMP(3),
  received_at TIMESTAMP(3),
  created_at  TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_deliveries_batch_id ON public.deliveries (batch_id);
CREATE INDEX IF NOT EXISTS idx_deliveries_sent_at ON public.deliveries (sent_at);

CREATE TABLE IF NOT EXISTS public.food_safety_incidents (
  id             TEXT         NOT NULL DEFAULT gen_random_uuid()::text PRIMARY KEY,
  sppg_id        TEXT         NOT NULL REFERENCES public.sppgs(id) ON DELETE CASCADE,
  school_id      TEXT         REFERENCES public.schools(id) ON DELETE SET NULL,
  reported_by    TEXT         NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  incident_date  DATE         NOT NULL,
  severity       TEXT         NOT NULL DEFAULT 'LOW' CHECK (severity IN ('LOW', 'MEDIUM', 'HIGH')),
  affected_count INTEGER      NOT NULL DEFAULT 0,
  description    TEXT         NOT NULL,
  status         TEXT         NOT NULL DEFAULT 'OPEN' CHECK (status IN ('OPEN', 'INVESTIGATING', 'RESOLVED')),
  resolved_at    TIMESTAMP(3),
  created_at     TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_incidents_sppg_date ON public.food_safety_incidents (sppg_id, incident_date);
CREATE INDEX IF NOT EXISTS idx_incidents_status ON public.food_safety_incidents (status);

-- ─── 5. notifications ───────────────────────────────────────────────────────
-- Catatan: id & user_id memakai TEXT (bukan UUID) agar cocok dengan users.id (text)
-- dan dengan tipe String pada Prisma. Migrasi lama memakai UUID dan gagal di DB baru.
CREATE TABLE IF NOT EXISTS public.notifications (
  id         TEXT         NOT NULL DEFAULT gen_random_uuid()::text PRIMARY KEY,
  user_id    TEXT         NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  title      TEXT         NOT NULL,
  body       TEXT         NOT NULL,
  type       TEXT         NOT NULL DEFAULT 'distribution',
  data       JSONB,
  is_read    BOOLEAN      NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_notif_user_read ON public.notifications (user_id, is_read);

COMMIT;
