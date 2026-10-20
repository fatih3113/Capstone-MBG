-- =======================================================
-- Migration: add_reports_and_role
-- Tanggal: 2025-10-13
-- Deskripsi:
--   1. Tambah kolom 'role' ke tabel users (default 'student')
--   2. Tambah kolom 'akg_target' ke tabel scan_history
--   3. Tambah kolom 'weight_input_gram' ke tabel predictions
--   4. Buat tabel baru: menu_requests
--   5. Buat tabel baru: food_ratings
--   6. Buat tabel baru: food_feedbacks
-- =======================================================

-- 1. Tambah kolom role ke users (jika belum ada)
ALTER TABLE users
  ADD COLUMN IF NOT EXISTS role TEXT NOT NULL DEFAULT 'student';

-- 2. Tambah kolom akg_target ke scan_history
ALTER TABLE scan_history
  ADD COLUMN IF NOT EXISTS akg_target TEXT;

-- 3. Tambah kolom weight_input_gram ke predictions
ALTER TABLE predictions
  ADD COLUMN IF NOT EXISTS weight_input_gram FLOAT;

-- 4. Buat tabel menu_requests
CREATE TABLE IF NOT EXISTS menu_requests (
  id            TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
  user_id       TEXT NOT NULL,
  menu_name     TEXT NOT NULL,
  reason        TEXT,
  status        TEXT NOT NULL DEFAULT 'received',
  admin_note    TEXT,
  submitted_at  TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_menu_requests_user FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Trigger untuk auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_menu_requests_updated_at
  BEFORE UPDATE ON menu_requests
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 5. Buat tabel food_ratings
CREATE TABLE IF NOT EXISTS food_ratings (
  id        TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
  user_id   TEXT NOT NULL,
  food_id   TEXT,
  food_name TEXT NOT NULL,
  rating    INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  reason    TEXT,
  rated_at  TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_food_ratings_user FOREIGN KEY (user_id) REFERENCES users(id),
  CONSTRAINT fk_food_ratings_food FOREIGN KEY (food_id) REFERENCES foods(id)
);

-- 6. Buat tabel food_feedbacks
CREATE TABLE IF NOT EXISTS food_feedbacks (
  id                   TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
  user_id              TEXT NOT NULL,
  food_id              TEXT,
  food_name            TEXT NOT NULL,
  taste_rating         INTEGER CHECK (taste_rating >= 1 AND taste_rating <= 5),
  texture_rating       INTEGER CHECK (texture_rating >= 1 AND texture_rating <= 5),
  aroma_rating         INTEGER CHECK (aroma_rating >= 1 AND aroma_rating <= 5),
  portion_rating       INTEGER CHECK (portion_rating >= 1 AND portion_rating <= 5),
  satisfaction_rating  INTEGER CHECK (satisfaction_rating >= 1 AND satisfaction_rating <= 5),
  consumption_status   TEXT CHECK (consumption_status IN ('habis', 'sebagian', 'hampir_tidak')),
  suggestion           TEXT,
  submitted_at         TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_food_feedbacks_user FOREIGN KEY (user_id) REFERENCES users(id),
  CONSTRAINT fk_food_feedbacks_food FOREIGN KEY (food_id) REFERENCES foods(id)
);

-- Index untuk performa query umum
CREATE INDEX IF NOT EXISTS idx_menu_requests_user    ON menu_requests(user_id);
CREATE INDEX IF NOT EXISTS idx_menu_requests_status  ON menu_requests(status);
CREATE INDEX IF NOT EXISTS idx_food_ratings_user     ON food_ratings(user_id);
CREATE INDEX IF NOT EXISTS idx_food_ratings_name     ON food_ratings(food_name);
CREATE INDEX IF NOT EXISTS idx_food_feedbacks_user   ON food_feedbacks(user_id);
CREATE INDEX IF NOT EXISTS idx_food_feedbacks_name   ON food_feedbacks(food_name);
CREATE INDEX IF NOT EXISTS idx_scan_history_akg      ON scan_history(akg_target);

-- Update admin role untuk seed user yang ada
-- (Akan ter-handle oleh seed.ts, ini hanya fallback manual)
UPDATE users SET role = 'admin' WHERE email = 'admin@mbg.test';
