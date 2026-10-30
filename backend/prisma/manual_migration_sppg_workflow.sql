-- =============================================================================
-- manual_migration_sppg_workflow.sql
-- Deskripsi : Menambah kolom workflow ke sppgs & users, membuat tabel operasional
--             baru (procurements, production_batches, deliveries, food_safety_incidents).
-- Database  : mbg_nutrition_db
-- Cara run  : psql -U postgres -d mbg_nutrition_db -f backend/prisma/manual_migration_sppg_workflow.sql
-- Idempoten : Ya — semua perubahan memakai IF NOT EXISTS / DO $$ ... END $$
-- =============================================================================

BEGIN;

-- ─────────────────────────────────────────────────────────────────────────────
-- A. TABEL sppgs — kolom baru
-- ─────────────────────────────────────────────────────────────────────────────

-- A1. verification_status
ALTER TABLE public.sppgs
  ADD COLUMN IF NOT EXISTS verification_status TEXT NOT NULL DEFAULT 'APPROVED';

-- A2. rejection_reason, verified_by, verified_at
ALTER TABLE public.sppgs
  ADD COLUMN IF NOT EXISTS rejection_reason TEXT;
ALTER TABLE public.sppgs
  ADD COLUMN IF NOT EXISTS verified_by TEXT;
ALTER TABLE public.sppgs
  ADD COLUMN IF NOT EXISTS verified_at TIMESTAMP(3);

-- A3. operational_status
ALTER TABLE public.sppgs
  ADD COLUMN IF NOT EXISTS operational_status TEXT NOT NULL DEFAULT 'ACTIVE';

-- A4. suspension_reason, suspended_at
ALTER TABLE public.sppgs
  ADD COLUMN IF NOT EXISTS suspension_reason TEXT;
ALTER TABLE public.sppgs
  ADD COLUMN IF NOT EXISTS suspended_at TIMESTAMP(3);

-- A5. Kolom detail SPPG
ALTER TABLE public.sppgs
  ADD COLUMN IF NOT EXISTS is_3t BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE public.sppgs
  ADD COLUMN IF NOT EXISTS kapasitas_porsi INTEGER;
ALTER TABLE public.sppgs
  ADD COLUMN IF NOT EXISTS penanggung_jawab TEXT;
ALTER TABLE public.sppgs
  ADD COLUMN IF NOT EXISTS kontak TEXT;

-- A6. CHECK constraints (idempoten via DO $BLOCK$ ... END $BLOCK$)
DO $BLOCK$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'sppgs_verification_status_check'
  ) THEN
    ALTER TABLE public.sppgs
      ADD CONSTRAINT sppgs_verification_status_check
      CHECK (verification_status IN ('PENDING', 'APPROVED', 'REJECTED'));
  END IF;
END
$BLOCK$;

DO $BLOCK$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'sppgs_operational_status_check'
  ) THEN
    ALTER TABLE public.sppgs
      ADD CONSTRAINT sppgs_operational_status_check
      CHECK (operational_status IN ('ACTIVE', 'SUSPENDED', 'INACTIVE'));
  END IF;
END
$BLOCK$;

-- A7. Index untuk status
CREATE INDEX IF NOT EXISTS idx_sppgs_verification_operational
  ON public.sppgs (verification_status, operational_status);

-- ─────────────────────────────────────────────────────────────────────────────
-- B. TABEL users — kolom baru
-- ─────────────────────────────────────────────────────────────────────────────

ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS account_status TEXT NOT NULL DEFAULT 'ACTIVE';

DO $BLOCK$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'users_account_status_check'
  ) THEN
    ALTER TABLE public.users
      ADD CONSTRAINT users_account_status_check
      CHECK (account_status IN ('PENDING', 'ACTIVE', 'REJECTED'));
  END IF;
END
$BLOCK$;

CREATE INDEX IF NOT EXISTS idx_users_role
  ON public.users (role);
CREATE INDEX IF NOT EXISTS idx_users_account_status
  ON public.users (account_status);

-- ─────────────────────────────────────────────────────────────────────────────
-- C. TABEL BARU — procurements
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.procurements (
  id              TEXT          NOT NULL DEFAULT gen_random_uuid()::text,
  sppg_id         TEXT          NOT NULL,
  supplier_name   TEXT          NOT NULL,
  item_name       TEXT          NOT NULL,
  quantity        NUMERIC(12,2) NOT NULL,
  unit            TEXT          NOT NULL,
  procured_at     TIMESTAMP(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP,
  notes           TEXT,
  created_at      TIMESTAMP(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT procurements_pkey PRIMARY KEY (id),
  CONSTRAINT procurements_sppg_id_fkey
    FOREIGN KEY (sppg_id) REFERENCES public.sppgs(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_procurements_sppg_procured
  ON public.procurements (sppg_id, procured_at);

-- ─────────────────────────────────────────────────────────────────────────────
-- D. TABEL BARU — production_batches
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.production_batches (
  id                TEXT         NOT NULL DEFAULT gen_random_uuid()::text,
  sppg_id           TEXT         NOT NULL,
  batch_date        DATE         NOT NULL,
  menu_name         TEXT         NOT NULL,
  portions_planned  INTEGER      NOT NULL DEFAULT 0,
  portions_produced INTEGER      NOT NULL DEFAULT 0,
  qc_status         TEXT         NOT NULL DEFAULT 'PENDING',
  qc_notes          TEXT,
  finished_at       TIMESTAMP(3),
  created_at        TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at        TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT production_batches_pkey PRIMARY KEY (id),
  CONSTRAINT production_batches_sppg_id_fkey
    FOREIGN KEY (sppg_id) REFERENCES public.sppgs(id) ON DELETE CASCADE,
  CONSTRAINT production_batches_qc_status_check
    CHECK (qc_status IN ('PASSED', 'FAILED', 'PENDING'))
);

CREATE INDEX IF NOT EXISTS idx_production_batches_sppg_date
  ON public.production_batches (sppg_id, batch_date);

-- ─────────────────────────────────────────────────────────────────────────────
-- E. TABEL BARU — deliveries
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.deliveries (
  id          TEXT         NOT NULL DEFAULT gen_random_uuid()::text,
  batch_id    TEXT         NOT NULL,
  school_id   TEXT         NOT NULL,
  portions    INTEGER      NOT NULL DEFAULT 0,
  status      TEXT         NOT NULL DEFAULT 'PREPARED',
  sent_at     TIMESTAMP(3),
  received_at TIMESTAMP(3),
  created_at  TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT deliveries_pkey PRIMARY KEY (id),
  CONSTRAINT deliveries_batch_id_fkey
    FOREIGN KEY (batch_id) REFERENCES public.production_batches(id) ON DELETE CASCADE,
  CONSTRAINT deliveries_school_id_fkey
    FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE CASCADE,
  CONSTRAINT deliveries_status_check
    CHECK (status IN ('PREPARED', 'SENT', 'RECEIVED'))
);

CREATE INDEX IF NOT EXISTS idx_deliveries_batch_id
  ON public.deliveries (batch_id);
CREATE INDEX IF NOT EXISTS idx_deliveries_sent_at
  ON public.deliveries (sent_at);

-- ─────────────────────────────────────────────────────────────────────────────
-- F. TABEL BARU — food_safety_incidents
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.food_safety_incidents (
  id             TEXT         NOT NULL DEFAULT gen_random_uuid()::text,
  sppg_id        TEXT         NOT NULL,
  school_id      TEXT,
  reported_by    TEXT         NOT NULL,
  incident_date  DATE         NOT NULL,
  severity       TEXT         NOT NULL DEFAULT 'LOW',
  affected_count INTEGER      NOT NULL DEFAULT 0,
  description    TEXT         NOT NULL,
  status         TEXT         NOT NULL DEFAULT 'OPEN',
  resolved_at    TIMESTAMP(3),
  created_at     TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT food_safety_incidents_pkey PRIMARY KEY (id),
  CONSTRAINT food_safety_incidents_sppg_id_fkey
    FOREIGN KEY (sppg_id) REFERENCES public.sppgs(id) ON DELETE CASCADE,
  CONSTRAINT food_safety_incidents_school_id_fkey
    FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE SET NULL,
  CONSTRAINT food_safety_incidents_reported_by_fkey
    FOREIGN KEY (reported_by) REFERENCES public.users(id) ON DELETE CASCADE,
  CONSTRAINT food_safety_incidents_severity_check
    CHECK (severity IN ('LOW', 'MEDIUM', 'HIGH')),
  CONSTRAINT food_safety_incidents_status_check
    CHECK (status IN ('OPEN', 'INVESTIGATING', 'RESOLVED'))
);

CREATE INDEX IF NOT EXISTS idx_incidents_sppg_date
  ON public.food_safety_incidents (sppg_id, incident_date);
CREATE INDEX IF NOT EXISTS idx_incidents_status
  ON public.food_safety_incidents (status);

-- ─────────────────────────────────────────────────────────────────────────────
-- G. Trigger updated_at untuk tabel baru
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $FUNC$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$FUNC$ LANGUAGE plpgsql;

DO $BLOCK$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'trg_procurements_updated_at'
  ) THEN
    CREATE TRIGGER trg_procurements_updated_at
      BEFORE UPDATE ON public.procurements
      FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END
$BLOCK$;

DO $BLOCK$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'trg_production_batches_updated_at'
  ) THEN
    CREATE TRIGGER trg_production_batches_updated_at
      BEFORE UPDATE ON public.production_batches
      FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END
$BLOCK$;

DO $BLOCK$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'trg_deliveries_updated_at'
  ) THEN
    CREATE TRIGGER trg_deliveries_updated_at
      BEFORE UPDATE ON public.deliveries
      FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END
$BLOCK$;

DO $BLOCK$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'trg_incidents_updated_at'
  ) THEN
    CREATE TRIGGER trg_incidents_updated_at
      BEFORE UPDATE ON public.food_safety_incidents
      FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END
$BLOCK$;

COMMIT;
