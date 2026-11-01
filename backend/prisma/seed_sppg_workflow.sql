-- =============================================================================
-- seed_sppg_workflow.sql
-- Deskripsi : Data demo untuk workflow SPPG (akun SPPG_ADMIN, procurement,
--             production_batch, delivery, incident, 1 SPPG PENDING, 1 SUSPENDED).
-- Cara run  : psql -U postgres -d mbg_nutrition_db -f backend/prisma/seed_sppg_workflow.sql
--
-- CATATAN HASH BCRYPT:
--   Password "demo123sppg" di-hash dengan bcryptjs (rounds=12):
--     node -e "const b=require('bcryptjs'); b.hash('demo123sppg',12).then(h=>console.log(h))"
--   Atau dengan Python:
--     python -c "import bcrypt; print(bcrypt.hashpw(b'demo123sppg', bcrypt.gensalt(12)).decode())"
--   Hash yang dipakai di bawah dibuat saat build seed. Untuk produksi, generate
--   hash baru dan ganti nilainya — JANGAN commit password plaintext.
-- =============================================================================

BEGIN;

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. Tambah SPPG berstatus PENDING (untuk demo alur verifikasi)
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO public.sppgs (
  id, kode, nama, provinsi, kabupaten_kota, kecamatan, kelurahan_desa,
  alamat, is_active, verification_status, operational_status,
  penanggung_jawab, kontak, kapasitas_porsi, is_3t
)
SELECT
  'sppg-pending-demo-001', 'SPPG-3276-099',
  'SPPG Percontohan Depok (Menunggu Verifikasi)',
  'Jawa Barat', 'Kota Depok', 'Sukmajaya', 'Abadijaya',
  'Jl. Margonda Raya No. 99, Depok', false,
  'PENDING', 'INACTIVE',
  'Budi Santoso', '081234567890', 500, false
WHERE NOT EXISTS (
  SELECT 1 FROM public.sppgs WHERE id = 'sppg-pending-demo-001'
);

-- ─────────────────────────────────────────────────────────────────────────────
-- 2. Tambah SPPG berstatus APPROVED tapi SUSPENDED
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO public.sppgs (
  id, kode, nama, provinsi, kabupaten_kota, kecamatan, kelurahan_desa,
  alamat, is_active, verification_status, operational_status,
  suspension_reason, suspended_at, penanggung_jawab, kontak, kapasitas_porsi, is_3t
)
SELECT
  'sppg-suspended-demo-001', 'SPPG-3273-088',
  'SPPG Bandung Barat Demo (Dihentikan Sementara)',
  'Jawa Barat', 'Kabupaten Bandung Barat', 'Lembang', 'Jayagiri',
  'Jl. Maribaya No. 88, Lembang', false,
  'APPROVED', 'SUSPENDED',
  'Laporan pelanggaran standar kebersihan dapur — menunggu audit ulang',
  NOW() - INTERVAL '5 days',
  'Siti Rahayu', '082345678901', 300, false
WHERE NOT EXISTS (
  SELECT 1 FROM public.sppgs WHERE id = 'sppg-suspended-demo-001'
);

-- ─────────────────────────────────────────────────────────────────────────────
-- 3. Akun SPPG_ADMIN untuk SPPG pertama dari seed awal (SPPG-3374-001 Semarang)
--    Hash di bawah = bcrypt("demo123sppg", 12)
--    PENTING: ganti hash ini untuk produksi!
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO public.users (
  id, name, email, password_hash, role, account_status,
  sppg_id, created_at, updated_at
)
SELECT
  'user-sppg-admin-demo-001',
  'Admin SPPG Semarang Banyumanik',
  'admin.sppg.smg@mbg.test',
  '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TiGrmKJhJhQYz3KQpNpQ4CqYP1X6',
  'SPPG_ADMIN',
  'ACTIVE',
  (SELECT id FROM public.sppgs WHERE kode = 'SPPG-3374-001' LIMIT 1),
  NOW(),
  NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM public.users WHERE email = 'admin.sppg.smg@mbg.test'
);

-- Akun SPPG_ADMIN ke-2 (masih PENDING, untuk demo verifikasi akun)
INSERT INTO public.users (
  id, name, email, password_hash, role, account_status,
  sppg_id, created_at, updated_at
)
SELECT
  'user-sppg-admin-pending-001',
  'Calon Admin SPPG Depok',
  'calon.sppg.depok@mbg.test',
  '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TiGrmKJhJhQYz3KQpNpQ4CqYP1X6',
  'SPPG_ADMIN',
  'PENDING',
  'sppg-pending-demo-001',
  NOW(),
  NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM public.users WHERE email = 'calon.sppg.depok@mbg.test'
);

-- Pastikan akun admin@mbg.test diperlakukan sebagai BGN_ADMIN
-- (update role jika masih 'admin', tidak merusak password)
UPDATE public.users
SET role = 'BGN_ADMIN'
WHERE email = 'admin@mbg.test'
  AND role = 'admin';

-- ─────────────────────────────────────────────────────────────────────────────
-- 4. Contoh Procurement (pengadaan hulu)
--    Gunakan SPPG-3374-001 Semarang Banyumanik
-- ─────────────────────────────────────────────────────────────────────────────
WITH target_sppg AS (
  SELECT id FROM public.sppgs WHERE kode = 'SPPG-3374-001' LIMIT 1
)
INSERT INTO public.procurements (
  id, sppg_id, supplier_name, item_name, quantity, unit, procured_at, notes
)
SELECT * FROM (VALUES
  ('proc-demo-001', (SELECT id FROM target_sppg), 'UD Beras Berkah', 'Beras IR-64', 500, 'kg', NOW() - INTERVAL '3 days', 'Kualitas premium, kadar air <14%'),
  ('proc-demo-002', (SELECT id FROM target_sppg), 'PT Sayur Segar', 'Wortel segar', 200, 'kg', NOW() - INTERVAL '3 days', NULL),
  ('proc-demo-003', (SELECT id FROM target_sppg), 'CV Protein Jaya', 'Ayam potong beku', 300, 'kg', NOW() - INTERVAL '2 days', 'Sudah memiliki sertifikat halal MUI'),
  ('proc-demo-004', (SELECT id FROM target_sppg), 'UD Telur Makmur', 'Telur ayam segar', 1000, 'butir', NOW() - INTERVAL '1 day', NULL)
) AS v(id, sppg_id, supplier_name, item_name, quantity, unit, procured_at, notes)
WHERE NOT EXISTS (SELECT 1 FROM public.procurements WHERE id = 'proc-demo-001');

-- ─────────────────────────────────────────────────────────────────────────────
-- 5. Contoh Production Batches (produksi tengah)
-- ─────────────────────────────────────────────────────────────────────────────
WITH target_sppg AS (
  SELECT id FROM public.sppgs WHERE kode = 'SPPG-3374-001' LIMIT 1
)
INSERT INTO public.production_batches (
  id, sppg_id, batch_date, menu_name,
  portions_planned, portions_produced, qc_status, qc_notes, finished_at
)
SELECT * FROM (VALUES
  ('batch-demo-001', (SELECT id FROM target_sppg), CURRENT_DATE - 2, 'Nasi Ayam Goreng + Sayur Wortel', 450, 448, 'PASSED', 'Semua parameter OK', NOW() - INTERVAL '2 days' + INTERVAL '4 hours'),
  ('batch-demo-002', (SELECT id FROM target_sppg), CURRENT_DATE - 1, 'Nasi Telur Dadar + Tumis Kangkung', 450, 0, 'PENDING', NULL, NULL),
  ('batch-demo-003', (SELECT id FROM target_sppg), CURRENT_DATE, 'Nasi Ayam Rebus + Sup Sayuran', 460, 0, 'PENDING', NULL, NULL)
) AS v(id, sppg_id, batch_date, menu_name, portions_planned, portions_produced, qc_status, qc_notes, finished_at)
WHERE NOT EXISTS (SELECT 1 FROM public.production_batches WHERE id = 'batch-demo-001');

-- ─────────────────────────────────────────────────────────────────────────────
-- 6. Contoh Deliveries (distribusi hilir)
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO public.deliveries (
  id, batch_id, school_id, portions, status, sent_at, received_at
)
SELECT
  'del-demo-001',
  'batch-demo-001',
  (SELECT id FROM public.schools LIMIT 1 OFFSET 0),
  150,
  'RECEIVED',
  NOW() - INTERVAL '2 days' + INTERVAL '6 hours',
  NOW() - INTERVAL '2 days' + INTERVAL '7 hours'
WHERE NOT EXISTS (SELECT 1 FROM public.deliveries WHERE id = 'del-demo-001')
  AND EXISTS (SELECT 1 FROM public.production_batches WHERE id = 'batch-demo-001')
  AND EXISTS (SELECT 1 FROM public.schools LIMIT 1 OFFSET 0);

INSERT INTO public.deliveries (
  id, batch_id, school_id, portions, status, sent_at, received_at
)
SELECT
  'del-demo-002',
  'batch-demo-001',
  (SELECT id FROM public.schools LIMIT 1 OFFSET 1),
  150,
  'RECEIVED',
  NOW() - INTERVAL '2 days' + INTERVAL '6 hours',
  NOW() - INTERVAL '2 days' + INTERVAL '7 hours 30 minutes'
WHERE NOT EXISTS (SELECT 1 FROM public.deliveries WHERE id = 'del-demo-002')
  AND EXISTS (SELECT 1 FROM public.production_batches WHERE id = 'batch-demo-001')
  AND (SELECT COUNT(*) FROM public.schools) >= 2;

-- ─────────────────────────────────────────────────────────────────────────────
-- 7. Contoh Food Safety Incidents
-- ─────────────────────────────────────────────────────────────────────────────
WITH target_sppg AS (
  SELECT id FROM public.sppgs WHERE kode = 'SPPG-3374-001' LIMIT 1
),
reporter AS (
  SELECT id FROM public.users WHERE email = 'admin.sppg.smg@mbg.test' LIMIT 1
)
INSERT INTO public.food_safety_incidents (
  id, sppg_id, school_id, reported_by, incident_date,
  severity, affected_count, description, status, resolved_at
)
SELECT * FROM (VALUES
  (
    'incident-demo-001',
    (SELECT id FROM target_sppg),
    (SELECT id FROM public.schools LIMIT 1 OFFSET 0),
    (SELECT id FROM reporter),
    CURRENT_DATE - 5,
    'LOW', 3,
    'Tiga siswa mengeluh mual setelah makan. Sudah dirujuk ke UKS dan sembuh dalam 2 jam.',
    'RESOLVED',
    NOW() - INTERVAL '4 days'
  ),
  (
    'incident-demo-002',
    (SELECT id FROM target_sppg),
    NULL,
    (SELECT id FROM reporter),
    CURRENT_DATE - 1,
    'MEDIUM', 0,
    'Ditemukan kontaminasi silang pada area persiapan bahan baku hewani. Proses produksi dihentikan sementara untuk pembersihan.',
    'INVESTIGATING',
    NULL
  )
) AS v(id, sppg_id, school_id, reported_by, incident_date, severity, affected_count, description, status, resolved_at)
WHERE NOT EXISTS (SELECT 1 FROM public.food_safety_incidents WHERE id = 'incident-demo-001')
  AND EXISTS (SELECT 1 FROM reporter);

COMMIT;
